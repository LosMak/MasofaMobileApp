import 'package:dala_ishchisi/common/constants/app_constants.dart';
import 'package:dala_ishchisi/infrastructure/services/http/interceptors/exception_interceptor.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:injectable/injectable.dart';

import 'interceptors/connection_checker_interceptor.dart';
import 'interceptors/my_log_interceptor.dart';
import 'interceptors/token_interceptor.dart';

@Singleton()
class HttpService {
  final MyLogInterceptor _logInterceptor;
  final ConnectionCheckerInterceptor _connectionCheckerInterceptor;
  final TokenInterceptor _tokenInterceptor;
  final CustomExceptionInterceptor _customExceptionInterceptor;
  final CacheOptions _cacheOptions;

  const HttpService(
    this._logInterceptor,
    this._connectionCheckerInterceptor,
    this._tokenInterceptor,
    this._customExceptionInterceptor,
    this._cacheOptions,
  );

  Dio client({
    required bool requiredRemote,
    required bool requiredToken,
    Duration? cacheDuration,
    String? baseUrl,
    Duration? receiveTimeout,
    Duration? sendTimeout,
    Duration? connectTimeout,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? AppConstants.baseUrl,
        receiveTimeout: receiveTimeout ?? const Duration(seconds: 60),
        connectTimeout: connectTimeout ?? const Duration(seconds: 60),
        sendTimeout: sendTimeout ?? const Duration(seconds: 600),
      ),
    );

    final interceptors = [
      _logInterceptor,
      if (requiredRemote) _connectionCheckerInterceptor,
      if (requiredToken) _tokenInterceptor,
      if (cacheDuration != null)
        DioCacheInterceptor(
          options: _cacheOptions.copyWith(
            policy: requiredRemote
                ? CachePolicy.refreshForceCache
                : CachePolicy.forceCache,
            maxStale: Nullable(cacheDuration),
          ),
        ),
    ];

    dio.interceptors.addAll(interceptors);
    return dio;
  }

  Future<void> clearCache() async => await _cacheOptions.store?.clean();
}
