import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'meta_model.freezed.dart';
part 'meta_model.g.dart';

@freezed
class MetaModel with _$MetaModel {
  const factory MetaModel({
    @Default([]) List<TypeModel> bidStates,
    @Default([]) List<TypeModel> bidTypes,
    @Default([]) List<CropTypeModel> diseases,
    @Default([]) List<CropTypeModel> pests,
    @Default([]) List<TypeModel> soilTypes,
    @Default([]) List<TypeModel> userTypes,
    @Default([]) List<TypeModel> wateringTypes,
    @Default([]) List<TypeModel> crops,
    @Default([]) List<TypeModel> regions,
    @JsonKey(name: 'regions3') @Default([]) List<ParentTypeModel> districts,
    @Default([]) List<TypeModel> contents,
  }) = _MetaModel;

  factory MetaModel.fromJson(Map<String, dynamic> json) =>
      _$MetaModelFromJson(json);
}

/// Base type model for commonly used fields
@freezed
class TypeModel with _$TypeModel {
  const factory TypeModel({
    @Default('') String id,
    @Default('') String name,
    @Default('') String nameRu,
    @Default('') String nameEn,
    @Default('') String nameUz,
  }) = _TypeModel;

  factory TypeModel.fromJson(Map<String, dynamic> json) =>
      _$TypeModelFromJson(json);
}

/// Extended type model with parentId field
@freezed
class ParentTypeModel with _$ParentTypeModel {
  const factory ParentTypeModel({
    @Default('') String id,
    @Default('') String parentId,
    @Default('') String name,
    @Default('') String nameRu,
    @Default('') String nameEn,
    @Default('') String nameUz,
  }) = _ParentTypeModel;

  factory ParentTypeModel.fromJson(Map<String, dynamic> json) =>
      _$ParentTypeModelFromJson(json);
}

/// Extended type model with cropId field
@freezed
class CropTypeModel with _$CropTypeModel {
  const factory CropTypeModel({
    @Default('') String id,
    @Default('') String cropId,
    @Default('') String name,
    @Default('') String nameEn,
    @Default('') String nameUz,
  }) = _CropTypeModel;

  factory CropTypeModel.fromJson(Map<String, dynamic> json) =>
      _$CropTypeModelFromJson(json);
}

extension TypeModelExtension on TypeModel {
  String get nameStr {
    // Для обратной совместимости с другими данными, которых вместо nameRu приходит просто name
    if (AppGlobals.lang == 'ru' && name.isEmpty) {
      return nameRu;
    }
    switch (AppGlobals.lang) {
      case 'uz':
        return nameUz;
      case 'en':
        return nameEn;
      default:
        return name;
    }
  }
}

extension ParentTypeModelExtension on ParentTypeModel {
  String get nameStr {
    if (AppGlobals.lang == 'ru' && name.isEmpty) {
      return nameRu;
    }
    switch (AppGlobals.lang) {
      case 'uz':
        return nameUz;
      case 'en':
        return nameEn;
      default:
        return name;
    }
  }
}

extension CropTypeModelExtension on CropTypeModel {
  String get nameStr {
    switch (AppGlobals.lang) {
      case 'uz':
        return nameUz;
      case 'en':
        return nameEn;
      default:
        return name;
    }
  }
}
