import 'dart:async';

import 'package:dala_ishchisi/domain/models/download_status_model.dart';
import 'package:dala_ishchisi/domain/models/region_model.dart';
import 'package:dartz/dartz.dart';

abstract class RegionFacade {
  Stream<DownloadStatusModel> get progressStream;
  Future<Either<dynamic, List<RegionModel>>> regions();
  Future<Either<dynamic, Map<String, String>>> regionsCache();
  Future<Either<dynamic, void>> syncRegionsCache();
  Future<Either<dynamic, String>> regionCache(String regionId);
  Future<Either<dynamic, dynamic>> downloadRegion(String regionId);
  Future<Either<dynamic, void>> putRegionCache(String regionId);
  Future<Either<dynamic, void>> deleteRegionCache(String regionId);
  Future<Either<dynamic, void>> cancelDownload(String regionId);
  void dispose();
}
