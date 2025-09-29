import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:dio_cache_interceptor_hive_store/dio_cache_interceptor_hive_store.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:internet_connection_checker_plus/internet_connection_checker_plus.dart';
import 'package:path_provider/path_provider.dart';

@module
abstract class Module {
  @Singleton()
  InternetConnection get connectionChecker => InternetConnection();

  @Singleton()
  @preResolve
  Future<CacheOptions> get cacheOptions async {
    return CacheOptions(
      store: await hiveCacheStore,
      policy: CachePolicy.forceCache,
      priority: CachePriority.normal,
      hitCacheOnErrorExcept: [401, 403, 404, 500, 502],
      keyBuilder: (request) => "${request.uri}-${request.data}",
      allowPostMethod: true,
    );
  }

  @Singleton()
  @preResolve
  Future<HiveCacheStore> get hiveCacheStore async {
    if (kIsWeb) {
      return HiveCacheStore('/');
    }
    final tempDir = await getTemporaryDirectory();
    return HiveCacheStore(tempDir.path);
  }

  @Singleton()
  ImagePicker get imagePicker => ImagePicker();
}
