import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class CustomExceptionInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.type == DioExceptionType.connectionError) {
      handler.reject(
        NoInternetConnection(requestOptions: err.requestOptions),
      );
    }

    super.onError(err, handler);
  }
}

class NoInternetConnection extends DioException {
  NoInternetConnection({required super.requestOptions});
}
