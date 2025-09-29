import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:dala_ishchisi/domain/facades/region_facade.dart';
import 'package:dala_ishchisi/domain/models/download_status_model.dart';
import 'package:dala_ishchisi/domain/models/region_model.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/region_cache.dart';
import 'package:dala_ishchisi/infrastructure/services/download/download_service.dart';
import 'package:dartz/dartz.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

@Injectable(as: RegionFacade)
class RegionDatasource implements RegionFacade {
  final RegionCache _cache;
  final DownloadService _downloadService;

  RegionDatasource(this._cache, this._downloadService);

  @override
  Future<Either<dynamic, List<RegionModel>>> regions() async {
    try {
      return right([]);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> putRegionCache(String regionId) async {
    try {
      final directory = await _directory;
      final path = "$directory/$regionId.mbtiles";
      await _cache.setRegion(regionId, path);
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> syncRegionsCache() async {
    try {
      await _downloadService.sync();
      final tasks = await _downloadService.loadTasks();
      final targetTasks =
          tasks.where((e) => e.status == DownloadStatus.complete).toList();
      final tasksAsMap = Map.fromEntries(targetTasks
          .map((e) => MapEntry(e.filename, "${e.path}/${e.filename}.mbtiles")));
      _cache.setRegions(tasksAsMap);
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, Map<String, String>>> regionsCache() async {
    try {
      final regions = await _cache.getRegions();
      return right(regions);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, String>> regionCache(
    String regionId,
  ) async {
    try {
      final data = await _cache.getRegion(regionId);
      return right(data);
    } catch (e) {
      return left(e);
    }
  }

  @override
  Stream<DownloadStatusModel> get progressStream =>
      _downloadService.progressStream;

  @override
  Future<Either<dynamic, dynamic>> downloadRegion(String regionId) async {
    // const baseUrl = 'https://masofa-yer.agro.uz/api/v1';
    // final path = '$baseUrl/region-tiles/$regionId';

    try {
      // final pathToFile = await _directory;
      // final fileName = "$regionId.mbtiles";
      // final headers = {'Authorization': "Bearer ${AppGlobals.token}"};

      // await _downloadService.requestPermissions();
      // await _downloadService.startDownload(
      //   fileName: fileName,
      //   savePath: pathToFile,
      //   url: path,
      //   headers: headers,
      // );
      return right(null);
    } catch (e) {
      log(e.toString());
      return left(e);
    }
  }

  @override
  Future<Either<dynamic, void>> cancelDownload(String regionId) async {
    try {
      _downloadService.cancelDownload(regionId);
      return right(null);
    } catch (e) {
      log(e.toString());
      return left(e);
    }
  }

  Future<String> get _directory async {
    final dir = await getApplicationDocumentsDirectory();
    return dir.path;
  }

  @override
  Future<Either<dynamic, void>> deleteRegionCache(String regionId) async {
    try {
      await _downloadService.tasksRawQuery(
          "DELETE FROM task WHERE file_name = '$regionId.mbtiles'");
      await _cache.deleteRegion(regionId);
      final directory = await _directory;
      final path = "$directory/$regionId.mbtiles";
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
      return right(null);
    } catch (e) {
      return left(e);
    }
  }

  @override
  void dispose() {
    _downloadService.dispose();
  }
}
