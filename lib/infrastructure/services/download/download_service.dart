import 'dart:async';
import 'dart:developer';
import 'dart:isolate';
import 'dart:ui';
import 'package:dala_ishchisi/domain/models/download_status_model.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:injectable/injectable.dart';
import 'package:permission_handler/permission_handler.dart';

@Singleton()
@pragma('vm:entry-point')
class DownloadService {
  final ReceivePort _port = ReceivePort();
  final StreamController<DownloadStatusModel> _progressController =
      StreamController.broadcast();
  final Map<String, String> _taskToFileName = {};

  DownloadService() {
    init();
  }

  Stream<DownloadStatusModel> get progressStream => _progressController.stream;

  @pragma('vm:entry-point')
  static void _downloadCallback(String id, int status, int progress) {
    final SendPort? send =
        IsolateNameServer.lookupPortByName('downloader_send_port');
    if (send != null) {
      send.send([id, status, progress]);
    }
  }

  Future<void> init() async {
    await FlutterDownloader.initialize(debug: true);
    FlutterDownloader.registerCallback(_downloadCallback);
    _bindBackgroundIsolate();
  }

  Future<void> sync() async {
    final tasks = await FlutterDownloader.loadTasksWithRawQuery(
            query: "SELECT * FROM task WHERE status in (1, 2)") ??
        [];
    for (final task in tasks) {
      log(task.toString());
      final filename = _getFileName(task.filename ?? '');
      _taskToFileName.addAll({task.taskId: filename});
      _progressController.add(DownloadStatusModel(
        taskId: task.taskId,
        filename: filename,
        ext: _getExt(task.filename ?? ''),
        status: _transformStatus(task.status),
        progress: task.progress.toDouble(),
      ));
    }
  }

  Future<List<DownloadStatusModel>> loadTasks() async {
    final tasks = await FlutterDownloader.loadTasks() ?? [];
    return tasks
        .map(
          (e) => DownloadStatusModel(
            taskId: e.taskId,
            filename: _getFileName(e.filename ?? ''),
            ext: _getExt(e.filename ?? ''),
            status: _transformStatus(e.status),
            progress: e.progress.toDouble(),
            path: e.savedDir,
          ),
        )
        .toList();
  }

  Future<void> requestPermissions() async {
    await Permission.storage.request();
    await Permission.notification.request();
  }

  Future<void> tasksRawQuery(String q) async {
    await FlutterDownloader.loadTasksWithRawQuery(query: q);
  }

  Future<String> startDownload({
    required String fileName,
    required String savePath,
    required String url,
    Map<String, String> headers = const {},
  }) async {
    final taskId = await FlutterDownloader.enqueue(
      url: url,
      savedDir: savePath,
      headers: headers,
      fileName: fileName,
      showNotification: true,
    );
    _taskToFileName[taskId!] = fileName;
    _progressController.add(DownloadStatusModel(
      taskId: taskId,
      filename: _getFileName(fileName),
      ext: _getExt(fileName),
      status: DownloadStatus.enqueued,
    ));
    return taskId;
  }

  void cancelDownload(String taskId) async {
    await FlutterDownloader.cancel(taskId: taskId);
    _taskToFileName.remove(taskId);
  }

  String _getFileName(String file) => file.split('.').first;

  String _getExt(String file) {
    final filename = _getFileName(file);
    return file.replaceAll(filename, '');
  }

  void _bindBackgroundIsolate() {
    IsolateNameServer.removePortNameMapping('downloader_send_port');

    final success = IsolateNameServer.registerPortWithName(
      _port.sendPort,
      'downloader_send_port',
    );

    if (!success) {
      return;
    }

    _port.listen((data) {
      final String id = data[0];
      final int status = data[1];
      final int progress = data[2];

      final fileName = _getFileName(_taskToFileName[id] ?? '');
      final ext = _getExt(_taskToFileName[id] ?? '');

      final downloadStatus = DownloadStatusModel(
          taskId: id,
          filename: fileName,
          ext: ext,
          status: _transformStatus(status),
          progress: progress.toDouble());

      _progressController.add(downloadStatus);
    });
  }

  DownloadStatus _transformStatus(Object status) {
    if (status is DownloadTaskStatus) {
      return switch (status) {
        DownloadTaskStatus.failed => DownloadStatus.failed,
        DownloadTaskStatus.enqueued => DownloadStatus.enqueued,
        DownloadTaskStatus.complete => DownloadStatus.complete,
        DownloadTaskStatus.canceled => DownloadStatus.canceled,
        DownloadTaskStatus.running => DownloadStatus.running,
        _ => DownloadStatus.undefined,
      };
    }

    if (status is int) {
      return switch (status) {
        -1 => DownloadStatus.failed,
        1 => DownloadStatus.enqueued,
        2 => DownloadStatus.running,
        3 => DownloadStatus.complete,
        5 => DownloadStatus.canceled,
        _ => DownloadStatus.undefined,
      };
    }
    return DownloadStatus.undefined;
  }

  void dispose() {
    _progressController.close();
  }
}
