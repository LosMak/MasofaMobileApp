import 'package:dala_ishchisi/domain/models/region_model.dart';

extension RegionExtension on RegionModel {
  String getName(String lang) {
    return switch (lang) {
      'ru' => nameRu,
      'uz' => nameUz,
      _ => nameEn,
    };
  }
}
