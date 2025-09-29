import 'package:dala_ishchisi/common/constants/app_constants.dart';
import 'package:dala_ishchisi/infrastructure/services/cache/auth_cache.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class TokenInterceptor extends Interceptor {
  final AuthCache _cache;

  const TokenInterceptor(this._cache);

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.headers.addAll({'Authorization': 'Bearer ${_cache.token}'});
    handler.next(options);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      if (_cache.login.isNotEmpty && _cache.password.isNotEmpty) {
        final dio = Dio(BaseOptions(baseUrl: AppConstants.baseUrl));
        const path = 'identity/Account/LoginByLoginPassword';
        const headers = {'Content-Type': ' application/json'};
        final data = {
          "userName": _cache.login,
          "password": _cache.password,
        };
        try {
          final response = await dio.post(
            path,
            data: data,
            options: Options(headers: headers),
          );

          if (response.data != null && response.data is String) {
            final token = response.data as String;
            await _cache.setToken(token);

            final options = err.requestOptions;
            options.headers["Authorization"] = "Bearer ${_cache.token}";

            final retryDio = Dio();
            final retryResponse = await retryDio.fetch(options);
            return handler.resolve(retryResponse);
          } else {
            await _cache.clear();
            router.pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
            handler.reject(err);
          }
        } catch (e) {
          await _cache.clear();
          router.pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
          handler.reject(err);
        }
        return;
      } else {
        await _cache.clear();
        router.pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
        handler.reject(err);
      }
    }
    super.onError(err, handler);
  }
}
