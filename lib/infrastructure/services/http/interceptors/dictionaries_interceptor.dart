import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class DictionariesInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    options.data ??= jsonEncode({});
    super.onRequest(options, handler);
  }
}
