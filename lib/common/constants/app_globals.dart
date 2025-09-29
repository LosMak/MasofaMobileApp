import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:geolocator/geolocator.dart';

/// Don't recommend this way(static global variable)
/// If you need to add variables be careful
/// The variable is global and they are used in model.fromJson without context
/// Token is used in interceptor, lang is used in localization
abstract class AppGlobals {
  static String lang = 'ru';
  static MetaModel meta = const MetaModel();
  static String token = '';
  static Position? position;
}
