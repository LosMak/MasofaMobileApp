import 'package:dala_ishchisi/infrastructure/services/cache/auth_cache.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';

import 'di.config.dart';

/// This file is used to [setup some method]
/// (EasyLocalization.ensureInitialized(), EasyLocalization.logger.enableBuildModes = [])
/// And [setup GetIT] with [injectable]
/// If you need some information how to use injectable [https://pub.dev/packages/injectable]

final di = GetIt.instance;

@InjectableInit(initializerName: 'init')
Future<void> configureDependencies() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  EasyLocalization.logger.enableBuildModes = [];
  EasyLoading.instance
    ..displayDuration = const Duration(milliseconds: 2000)
    ..indicatorType = EasyLoadingIndicatorType.fadingCircle
    ..loadingStyle = EasyLoadingStyle.dark
    ..indicatorSize = 45.0
    ..radius = 10.0
    ..userInteractions = false
    ..dismissOnTap = false;

  await di.init();
  if (kDebugMode) {
    print("Token ${di<AuthCache>().token}");
    // print("Login ${di<AuthCacheService>().login}");
    // print("Password ${di<AuthCacheService>().password}");
  }
}
