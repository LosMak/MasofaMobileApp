import 'package:device_preview/device_preview.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

class CustomApp extends StatelessWidget {
  final Widget child;
  final bool enabledPreview;

  const CustomApp({
    super.key,
    required this.child,
    this.enabledPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    return EasyLocalization(
      supportedLocales: const [Locale("uz"), Locale("ru"), Locale("en")],
      path: 'assets/tr',
      fallbackLocale: const Locale("ru"),
      startLocale: const Locale("ru"),
      useOnlyLangCode: true,
      saveLocale: true,
      child: DevicePreview(
        enabled: enabledPreview && MediaQuery.of(context).size.width > 600,
        builder: (_) => child,
      ),
    );
  }
}
