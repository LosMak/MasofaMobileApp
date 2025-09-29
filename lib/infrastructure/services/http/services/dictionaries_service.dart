import 'package:api_client_dictionaries/api_client_dictionaries.dart';
import 'package:dala_ishchisi/common/constants/app_constants.dart';
import 'package:dala_ishchisi/infrastructure/services/http/interceptors/connection_checker_interceptor.dart';
import 'package:dala_ishchisi/infrastructure/services/http/interceptors/dictionaries_interceptor.dart';
import 'package:dala_ishchisi/infrastructure/services/http/interceptors/my_log_interceptor.dart';
import 'package:dala_ishchisi/infrastructure/services/http/interceptors/token_interceptor.dart';
import 'package:dala_ishchisi/infrastructure/services/http/services/model/params.dart';
import 'package:dio/dio.dart';
import 'package:dio_cache_interceptor/dio_cache_interceptor.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class DictionariesService {
  final MyLogInterceptor _logInterceptor;
  final ConnectionCheckerInterceptor _connectionCheckerInterceptor;
  final TokenInterceptor _tokenInterceptor;
  final CacheOptions _cacheOptions;
  final DictionariesInterceptor _dictionariesInterceptor;
  ApiClientDictionaries? _client;
  Params? _params;

  DictionariesService(
    this._logInterceptor,
    this._connectionCheckerInterceptor,
    this._tokenInterceptor,
    this._cacheOptions,
    this._dictionariesInterceptor,
  );

  ApiClientDictionaries client({
    String? baseUrl,
    required bool requiredToken,
    required bool requiredRemote,
    Duration? cacheDuration,
  }) {
    final params = Params(
        baseUrl: baseUrl ?? AppConstants.baseUrl,
        requiredToken: requiredToken,
        requiredRemote: requiredRemote,
        cacheDuration: cacheDuration);
    if (_params != null && _params == params && _client != null) {
      return _client!;
    }
    _params = params;
    _client = _getClient(
      baseUrl: baseUrl ?? AppConstants.baseUrl,
      requiredToken: requiredToken,
      requiredRemote: requiredRemote,
    );
    return _client!;
  }

  ApiClientDictionaries _getClient({
    required String baseUrl,
    required bool requiredToken,
    required bool requiredRemote,
    Duration? cacheDuration,
  }) {
    final Dio dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        validateStatus: (status) => status != null && status < 400,
      ),
    );
    final client = ApiClientDictionaries(
      basePathOverride: baseUrl,
      dio: dio,
      interceptors: [
        if (requiredToken) _tokenInterceptor,
        _logInterceptor,
        _connectionCheckerInterceptor,
        if (requiredRemote)
          DioCacheInterceptor(
            options: _cacheOptions.copyWith(
              policy: requiredRemote
                  ? CachePolicy.refreshForceCache
                  : CachePolicy.forceCache,
              maxStale: Nullable(cacheDuration),
            ),
          ),
        _dictionariesInterceptor
      ],
    );
    return client;
  }
}
