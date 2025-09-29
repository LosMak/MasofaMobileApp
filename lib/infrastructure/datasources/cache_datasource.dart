import 'dart:async';
import 'dart:io';

import 'package:dala_ishchisi/domain/facades/cache_facade.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@Injectable(as: CacheFacade)
class CacheDatasource implements CacheFacade {
  Future<Directory> get _directory => getApplicationCacheDirectory();

  @override
  Future<int> getSize() async {
    int totalSize = 0;

    final dir = await _directory;

    final files = await _getFiles(
      (File file) =>
          file.path.split(Platform.pathSeparator).last.startsWith('bid_'),
      (Directory dir) =>
          dir.path.split(Platform.pathSeparator).last.startsWith('bid_'),
      dir,
    );

    for (final file in files) {
      totalSize += await file.length();
    }

    return totalSize;
  }

  Future<List<File>> _getFiles(
    bool Function(File) getFileIf,
    bool Function(Directory) getFileInFolderIf,
    Directory root,
  ) async {
    final result = <File>[];

    Future<void> traverse(FileSystemEntity entity) async {
      if (entity is File) {
        if (await entity.exists() && getFileIf(entity)) {
          result.add(entity);
        }
      } else if (entity is Directory) {
        if (await entity.exists()) {
          if (getFileInFolderIf(entity)) {
            await for (final fsEntity
                in entity.list(recursive: true, followLinks: false)) {
              if (fsEntity is File && await fsEntity.exists()) {
                result.add(fsEntity);
              }
            }
          } else {
            await for (final fsEntity in entity.list(followLinks: false)) {
              await traverse(fsEntity);
            }
          }
        }
      }
    }

    if (await root.exists()) {
      await for (final entity in root.list(followLinks: false)) {
        await traverse(entity);
      }
    }

    return result;
  }

  @override
  Future<void> deleteAll() async {
    final dir = await _directory;

    final files = await _getFiles(
      (File file) =>
          file.path.split(Platform.pathSeparator).last.startsWith('bid_'),
      (Directory dir) =>
          dir.path.split(Platform.pathSeparator).last.startsWith('bid_'),
      dir,
    );

    for (final file in files) {
      await file.delete();
    }
  }
}
