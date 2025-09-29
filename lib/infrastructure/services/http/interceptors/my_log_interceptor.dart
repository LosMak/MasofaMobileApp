import 'dart:developer';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class MyLogInterceptor extends Interceptor {
  const MyLogInterceptor();

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    if (kDebugMode) {
      var logMessage = "Request | ${options.method}"
          " | ${options.uri}";
      if (options.queryParameters.isNotEmpty) {
        logMessage += " | ${options.queryParameters}";
      }
      log(logMessage);
    }
    super.onRequest(options, handler);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    if (kDebugMode) {
      var logMessage = "${response.statusCode}"
          " | ${response.requestOptions.method}"
          " | ${response.requestOptions.path}";
      if (response.requestOptions.queryParameters.isNotEmpty) {
        logMessage += " | ${response.requestOptions.queryParameters}";
      }
      log(logMessage);
    }
    super.onResponse(response, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (kDebugMode) {
      log(
        'ERROR:',
        error: "${err.response?.requestOptions.method} "
            "${err.response?.statusCode} "
            "${err.response?.requestOptions.path} "
            "${err.response?.statusMessage}",
      );
    }
    super.onError(err, handler);
  }
}
