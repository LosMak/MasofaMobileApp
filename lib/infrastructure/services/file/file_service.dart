import 'dart:io';
import 'dart:isolate';
import 'dart:typed_data';

import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@Singleton()
class FileService {
  Future<String> save(String filename, Uint8List bytes) async {
    final ReceivePort receivePort = ReceivePort();

    await Isolate.spawn(
        _saveFileInIsolate, [receivePort.sendPort, bytes, filename]);

    return await receivePort.first as String;
  }


  Future<int> getFileSize(File file) async {
    if (await file.exists()) {
      return await file.length();
    }
    return -1;
  }

  void deleteFile(File file) async {
    if (await file.exists()) {
      await file.delete();
    }
  }

  void deleteFiles(List<File> files) async {
    for (var file in files) {
      deleteFile(file);
    }
  }

  void deleteDirectory(Directory dir, {bool recursive = false}) async {
    if (await dir.exists()) {
      dir.delete(recursive: recursive);
    }
  }

  void _saveFileInIsolate(List args) async {
    final SendPort sendPort = args[0];
    Uint8List bytes = args[1];
    final String filename = args[2];

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$filename');
    await file.writeAsBytes(bytes);

    sendPort.send(file.path);
  }
}
