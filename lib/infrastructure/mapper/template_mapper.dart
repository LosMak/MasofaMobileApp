import 'package:api_client_crop/api_client_crop.dart' as api;
import 'package:built_collection/built_collection.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';

class TemplateMapper {
  static TemplateModel transform(api.BidTemplateModel? model) {
    if (model == null) {
      return const TemplateModel();
    }
    final data = model.data;
    return TemplateModel(blocks: _blockListTransform(data?.blocks));
  }

  static List<TemplateModel> transformList(
      BuiltList<api.BidTemplateModel>? list) {
    if (list == null) {
      return [];
    }
    return list.map(transform).toList();
  }

  static _blockListTransform(BuiltList<api.BlockModel>? list) {
    if (list == null) {
      return [];
    }
    return list.map((e) => _blockTransform(e)).toList();
  }

  static BlockModel _blockTransform(api.BlockModel model) {
    return BlockModel(
        blockType: _toSnackCase(model.blockType.name),
        controls: _controlListTransform(model.controls),
        steps: _stepListTransform(model.steps));
  }

  static List<StepModel> _stepListTransform(BuiltList<api.StepModel>? list) {
    if (list == null) {
      return [];
    }
    return list.map(_stepTransform).toList();
  }

  static StepModel _stepTransform(api.StepModel model) {
    return StepModel(
      controls: _controlListTransform(model.controls),
      days: model.days,
      descriptionEn: model.descriptionEn,
      descriptionRu: model.descriptionRu,
      nameEn: model.nameEn,
      nameRu: model.nameRu,
      num: model.num_,
    );
  }

  static List<ControlModel> _controlListTransform(
      BuiltList<api.ControlModel>? list) {
    if (list == null) {
      return [];
    }
    return list.map(_controlTransform).toList();
  }

  static ControlModel _controlTransform(api.ControlModel model) {
    return ControlModel(
      auto: model.auto,
      name: model.name,
      required: model.required_,
      type: _controlTypeFromString(model.type.name),
      source: _sourceTypeFromString(model.source_.name),
      // days: model.days, //Добавить поле
      labelEn: model.labelEn,
      labelRu: model.labelRu,
      descrEn: model.descrEn ?? '',
      descrRu: model.descrRu ?? '',
      valuesEn: model.valuesEn ?? '',
      valuesRu: model.valuesRu ?? '',
    );
  }

  static SourceType _sourceTypeFromString(String source) {
    return switch (source) {
      'Api' => SourceType.api,
      'User' => SourceType.user,
      'App' => SourceType.app,
      _ => SourceType.app,
    };
  }

  static ControlType _controlTypeFromString(String value) {
    final val = value.toLowerCase();
    return switch (val) {
      'checklist' => ControlType.checklist,
      'dropdown' => ControlType.dropdown,
      'checkbox' => ControlType.checkbox,
      'string' => ControlType.string,
      'int_' => ControlType.int,
      'decimal' => ControlType.decimal,
      'date' => ControlType.date,
      'datetime' => ControlType.datetime,
      'uuid' => ControlType.uuid,
      'photo' => ControlType.photo,
      'float' => ControlType.float,
      _ => throw ArgumentError('Unknown ControlType: $value'),
    };
  }

  static String _toSnackCase(String value) {
    final snakeCaseRegex = RegExp(r'^[a-z]+(_[a-z]+)*$');
    if (snakeCaseRegex.hasMatch(value)) {
      return value;
    }
    return value
        .replaceAllMapped(
            RegExp(r'([a-z0-9])([A-Z])'), (match) => '${match[1]}_${match[2]}')
        .toLowerCase();
  }
}
