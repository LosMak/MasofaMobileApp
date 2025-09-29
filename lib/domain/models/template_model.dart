// ignore_for_file: invalid_annotation_target

import 'package:freezed_annotation/freezed_annotation.dart';

part 'template_model.freezed.dart';
part 'template_model.g.dart';

enum SourceType { app, api, user, local }

enum ControlType {
  string,
  uuid,
  date,
  datetime,
  decimal,
  dropdown,
  int,
  checkbox,
  photo,
  float,
  checklist,
}

@freezed
class TemplateModel with _$TemplateModel {
  const factory TemplateModel({
    @Default('1.1') String version,
    @Default([]) List<BlockModel> blocks,
  }) = _TemplateModel;

  factory TemplateModel.fromJson(Map<String, dynamic> json) =>
      _$TemplateModelFromJson(json);
}

@freezed
class BlockModel with _$BlockModel {
  const factory BlockModel({
    @Default('') String blockType,
    @JsonKey(name: 'blockName_uz') @Default('') String blockNameUz,
    @JsonKey(name: 'blockName_en') @Default('') String blockNameEn,
    @JsonKey(name: 'blockName_ru') @Default('') String blockNameRu,
    @Default([]) List<ControlModel> controls,
    @Default([]) List<StepModel> steps,
  }) = _BlockModel;

  factory BlockModel.fromJson(Map<String, dynamic> json) =>
      _$BlockModelFromJson(json);
}

@freezed
class ControlModel with _$ControlModel {
  const factory ControlModel({
    @Default(ControlType.string)
    @JsonKey(fromJson: _controlTypeFromJson)
    ControlType type,
    @Default('') String name,
    @Default(false) bool auto,
    @Default(true) bool required,
    @Default(SourceType.app) SourceType source,
    @Default(false) bool readonly,
    // @Default('') String label,
    @JsonKey(name: 'label_en') @Default('') String labelEn,
    @JsonKey(name: 'label_ru') @Default('') String labelRu,
    @JsonKey(name: 'label_uz') @Default('') String labelUz,
    // @Default('') String descr,
    @JsonKey(name: 'descr_en') @Default('') String descrEn,
    @JsonKey(name: 'descr_ru') @Default('') String descrRu,
    @JsonKey(name: 'descr_uz') @Default('') String descrUz,
    // @Default('') String values,
    @JsonKey(name: 'values_en') @Default('') String valuesEn,
    @JsonKey(name: 'values_ru') @Default('') String valuesRu,
    @JsonKey(name: 'values_uz') @Default('') String valuesUz,
    @Default('') String resultValues,
    @Default('') String days,
  }) = _ControlModel;

  factory ControlModel.fromJson(Map<String, dynamic> json) =>
      _$ControlModelFromJson(json);
}

@freezed
class StepModel with _$StepModel {
  const factory StepModel({
    @Default('') String num,
    // @Default('') String name,
    @JsonKey(name: 'name_en') @Default('') String nameEn,
    @JsonKey(name: 'name_ru') @Default('') String nameRu,
    @JsonKey(name: 'name_uz') @Default('') String nameUz,
    // @Default('') String description,
    @JsonKey(name: 'description_en') @Default('') String descriptionEn,
    @JsonKey(name: 'description_ru') @Default('') String descriptionRu,
    @JsonKey(name: 'description_uz') @Default('') String descriptionUz,
    @Default('') String days,
    @Default([]) List<ControlModel> controls,
  }) = _StepModel;

  factory StepModel.fromJson(Map<String, dynamic> json) =>
      _$StepModelFromJson(json);
}

ControlType _controlTypeFromJson(dynamic value) {
  if (value == null) return ControlType.string;

  final String typeStr = value.toString();

  if (typeStr == 'cheсklist' || typeStr == 'checklist') {
    return ControlType.checklist;
  }

  for (final type in ControlType.values) {
    if (typeStr == type.toString().split('.').last) {
      return type;
    }
  }

  return ControlType.string;
}
