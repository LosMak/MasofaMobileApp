import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/image_model.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:dala_ishchisi/domain/models/user_info_model.dart';

enum DateType { start, end }

String _lang = AppGlobals.lang;

extension ValidateGeneralTemplate on TemplateModel {
  String? validateGeneral() {
    for (final block in blocks) {
      if (block.isStep) continue;
      if (block.blockType == 'fertilizers_pesticides_input') {
        final checkbox =
            block.controls.where((e) => e.name == 'skip_data_input').first;
        final hasPesticides = checkbox.resultValues == 'checked';
        if (!hasPesticides) continue;
      }

      for (final control in block.controls) {
        if (control.source == SourceType.local) continue;
        final error = control.controlError;
        if (error != null) {
          return error;
        }
      }
    }
    return null;
  }
}

extension ValidateStepTemplate on TemplateModel {
  String? validateStep(int blockIndex, List<int> stepIndexes) {
    int c = -1;
    for (final block in blocks) {
      if (!block.isStep) continue;
      c++;
      if (c == blockIndex) {
        for (int i = 0; i < stepIndexes.length; i++) {
          final step = block.steps[stepIndexes[i]];
          for (int j = 0; j < step.controls.length; j++) {
            final control = step.controls[j];
            if (j > 0 && control.type == ControlType.photo) {
              if (step.controls[j - 1].type == ControlType.checklist) {
                if (step.controls[j - 1].resultValues.isEmpty) {
                  return null;
                }
              }
            }

            final error = control.controlError;
            if (error != null) {
              return error;
            }
          }
        }

        return null;
      }
    }

    return null;
  }
}

extension ValidateStepsTemplate on TemplateModel {
  String? validateSteps(List<int> stepIndexes) {
    final countSteps = blocks.where((block) => block.isStep).length;
    for (var i = 0; i < countSteps; i++) {
      final validatedData = validateStep(i, stepIndexes);
      if (validatedData != null) {
        return validatedData;
      }
    }
    return null;
  }
}

extension ValidateControl on ControlModel {
  String? get controlError {
    // Skip validation if control is not required
    final label = localizedLabel(_lang);
    final values = localizedValues(_lang);

    if (readonly || auto || resultValues == '-') {
      return null;
    }

    // Check if required field is empty
    if (required && resultValues.isEmpty) {
      return label;
    }

    if (required &&
        type == ControlType.checkbox &&
        resultValues == 'unchecked') {
      return label;
    }

    // Validate numeric values
    if ((type == ControlType.int ||
            type == ControlType.float ||
            type == ControlType.decimal) &&
        source == SourceType.user &&
        values.isNotEmpty &&
        resultValues.isNotEmpty) {
      final limits = values.split(';');
      if (limits.length == 2) {
        try {
          final min = double.parse(limits[0]);
          final max = double.parse(limits[1]);
          final value = double.parse(resultValues);

          // Check if value is within range
          if (value < min || value > max) {
            return label;
          }
        } catch (e) {
          // Parse error
          return label;
        }
      }
    }

    return null;
  }
}

extension DateTimeFunctionsTemplate on TemplateModel {
  DateTime? get startDate {
    final info = dateControl(DateType.start);
    if (info != null && info.control.resultValues.isNotEmpty) {
      return DateTime.tryParse(info.control.resultValues);
    }
    return null;
  }

  DateTime? get endDate {
    final info = dateControl(DateType.end);
    if (info != null && info.control.resultValues.isNotEmpty) {
      return DateTime.tryParse(info.control.resultValues);
    }
    return null;
  }
}

extension SomeFunctionsTemplate on TemplateModel {
  bool get canEdit {
    final info = dateControl(DateType.start);
    return DateTime.tryParse("${info?.control.localizedValues(_lang)}") != null;
  }

  ({int blockIndex, int controlIndex, ControlModel control})? dateControl(
    DateType dateType,
  ) {
    final blockIndex = blocks.indexWhere((e) => e.blockType == 'general_data');
    if (blockIndex != -1) {
      final controls = blocks[blockIndex].controls;
      final controlIndex = controls.indexWhere(
        (e) => e.name == 'measurements_${dateType.name}',
      );
      if (controlIndex != -1) {
        return (
          blockIndex: blockIndex,
          controlIndex: controlIndex,
          control: controls[controlIndex],
        );
      }
    }

    return null;
  }

  TemplateModel get trim {
    final updatedBlocks = blocks.map((block) {
      final filteredControls = block.controls
          .where((control) => control.source != SourceType.local)
          .toList();
      return block.copyWith(controls: filteredControls);
    }).toList();

    return copyWith(blocks: updatedBlocks);
  }

  List<ImageModel> get imagePaths {
    final list = <ImageModel>[];
    var blockImageIndex = 0;

    final stepImageIndices = <String, int>{};

    for (int blockIndex = 0; blockIndex < blocks.length; blockIndex++) {
      final block = blocks[blockIndex];
      for (int controlIndex = 0;
          controlIndex < block.controls.length;
          controlIndex++) {
        final control = block.controls[controlIndex];
        if (control.type == ControlType.photo &&
            control.resultValues.isNotEmpty) {
          blockImageIndex++;
          final path = control.resultValues;
          list.add(ImageModel(
            name: 'block_$blockImageIndex',
            type: path.substring(path.lastIndexOf('.') + 1),
            path: path,
          ));
        }
      }

      for (int stepIndex = 0; stepIndex < block.steps.length; stepIndex++) {
        final step = block.steps[stepIndex];
        for (int controlIndex = 0;
            controlIndex < step.controls.length;
            controlIndex++) {
          final control = step.controls[controlIndex];
          if (control.type == ControlType.photo &&
              control.resultValues.isNotEmpty) {
            final stepNum = step.num;
            stepImageIndices[stepNum] = (stepImageIndices[stepNum] ?? 0) + 1;
            final stepImageIndex = stepImageIndices[stepNum]!;

            final path = control.resultValues;
            list.add(ImageModel(
              name: 'step_${step.num}_$stepImageIndex',
              type: path.substring(path.lastIndexOf('.') + 1),
              path: path,
            ));
          }
        }
      }
    }

    return list;
  }

  List<int> stepIndexes() {
    final index = blocks.indexWhere((e) => e.isStep);
    if (index != -1) {
      return blocks[index].stepIndexes(plantingDate);
    }
    return [];
  }
}

extension CacheFunctionsTemplate on TemplateModel {
  TemplateModel updateTemplateCache({
    required UserInfoModel user,
    required BidModel bid,
  }) {
    final newBlocks = blocks.map((block) {
      final newControls = block.controls.map((control) {
        switch (control.name) {
          case 'task':
            return control.copyWithValues(values: bid.description);
          case 'contour':
            return control.copyWithValues(values: bid.contourId);
          case 'user':
            return control.copyWithValues(values: user.id);
          case 'field':
            return control.copyWithValues(values: bid.fieldId);
          case 'crop':
            return control.copyWithValues(values: bid.crop.nameStr);
          case 'point_lat':
            return control.copyWithValues(values: bid.lat.toString());
          case 'point_lng':
            return control.copyWithValues(values: bid.lng.toString());
          case 'planting_date':
            if (control.localizedValues(_lang).isEmpty ||
                control.resultValues.isEmpty) {
              return control.copyWithValues(values: bid.fieldPlantingDate);
            }
            return control;
          default:
            return control;
        }
      }).toList();

      return block.copyWith(controls: newControls);
    }).toList();

    return copyWith(blocks: newBlocks);
  }

  String get plantingDate {
    final blockIndex = blocks.indexWhere((e) => e.blockType == 'field_data');
    if (blockIndex != -1) {
      final controlIndex = blocks[blockIndex]
          .controls
          .indexWhere((e) => e.name == 'planting_date');
      if (controlIndex != -1) {
        return blocks[blockIndex].controls[controlIndex].resultValues;
      }
    }
    return '';
  }
}

extension UpdateFunctionsTemplate on TemplateModel {
  TemplateModel addControlsToBlock(
    int blockIndex,
    List<ControlModel> controls,
  ) {
    if (blocks.isEmpty || blockIndex >= blocks.length) return this;

    final updatedBlocks = List<BlockModel>.from(blocks);
    final targetBlock = updatedBlocks[blockIndex];

    updatedBlocks[blockIndex] = targetBlock.copyWith(
      controls: [
        ...targetBlock.controls,
        ...controls,
      ],
    );

    return copyWith(blocks: updatedBlocks);
  }

  TemplateModel removeControlsFromBlock(
    int blockIndex,
    int start,
    int end,
  ) {
    if (blocks.isEmpty || blockIndex >= blocks.length) return this;

    final updatedBlocks = List<BlockModel>.from(blocks);
    final targetBlock = updatedBlocks[blockIndex];

    final updatedControls = List<ControlModel>.from(targetBlock.controls)
      ..removeRange(start, end);

    updatedBlocks[blockIndex] = targetBlock.copyWith(
      controls: updatedControls,
    );

    return copyWith(blocks: updatedBlocks);
  }

  TemplateModel updateTemplateWith10Steps() {
    final blocksCopy = List<BlockModel>.from(blocks);
    final stepBlocks = blocksCopy.where((block) => block.isStep).toList();

    if (stepBlocks.isEmpty) {
      return this;
    }

    final templateBlock = stepBlocks.last;

    while (blocksCopy.where((block) => block.isStep).length < 10) {
      blocksCopy.add(templateBlock);
    }

    return copyWith(blocks: blocksCopy);
  }

  TemplateModel updateTemplateStartDate() {
    final dateStr = DateTime.now().toUtc().toIso8601String();
    final newBlocks = blocks.map((block) {
      final newControls = block.controls.map((control) {
        if (control.name == 'measurements_start') {
          return control.copyWith(
            valuesEn: dateStr,
            valuesRu: dateStr,
            valuesUz: dateStr,
            resultValues: dateStr,
          );
        }
        return control;
      }).toList();

      return block.copyWith(controls: newControls);
    }).toList();

    return copyWith(blocks: newBlocks);
  }

  TemplateModel updateTemplateEndDate() {
    final dateStr = DateTime.now().toUtc().toIso8601String();
    final newBlocks = blocks.map((block) {
      final newControls = block.controls.map((control) {
        if (control.name == 'measurements_stop') {
          return control.copyWith(
            valuesEn: dateStr,
            valuesRu: dateStr,
            valuesUz: dateStr,
            resultValues: dateStr,
          );
        }
        return control;
      }).toList();

      return block.copyWith(controls: newControls);
    }).toList();

    return copyWith(blocks: newBlocks);
  }

  TemplateModel updateTemplate({
    required ControlModel control,
    required int blockIndex,
    required int controlIndex,
  }) {
    final newTemplate = copyWith(blocks: List.from(blocks));
    if (blockIndex < 0 || blockIndex >= newTemplate.blocks.length) return this;

    final block = newTemplate.blocks[blockIndex];
    if (controlIndex < 0 || controlIndex >= block.controls.length) return this;

    final newControls = List<ControlModel>.from(block.controls);
    newControls[controlIndex] = control;
    final newBlock = block.copyWith(controls: newControls);
    final newBlocks = List<BlockModel>.from(newTemplate.blocks);
    newBlocks[blockIndex] = newBlock;

    return newTemplate.copyWith(blocks: newBlocks);
  }

  TemplateModel updateTemplateWithStep({
    required ControlModel control,
    required int blockIndex,
    required int controlIndex,
    required int stepIndex,
  }) {
    final newTemplate = copyWith(blocks: List.from(blocks));
    if (blockIndex < 0 || blockIndex >= newTemplate.blocks.length) return this;

    final block = newTemplate.blocks[blockIndex];
    if (stepIndex < 0 || stepIndex >= block.steps.length) return this;

    final step = block.steps[stepIndex];
    if (controlIndex < 0 || controlIndex >= step.controls.length) return this;

    final newStepControls = List<ControlModel>.from(step.controls);
    newStepControls[controlIndex] = control;

    final newStep = step.copyWith(controls: newStepControls);

    final newSteps = List<StepModel>.from(block.steps);
    newSteps[stepIndex] = newStep;

    final newBlock = block.copyWith(steps: newSteps);
    final newBlocks = List<BlockModel>.from(newTemplate.blocks);
    newBlocks[blockIndex] = newBlock;

    return newTemplate.copyWith(blocks: newBlocks);
  }

  TemplateModel updateTemplateResultValues() {
    final newBlocks = blocks.map((block) {
      final newControls = block.controls.map((control) {
        // if (control.resultValues.isEmpty) return control;

        final index = control.resultValues.lastIndexOf('/');
        if (index == -1) {
          return control.copyWithValues(values: control.resultValues);
        }

        return control.copyWithValues(
          values: control.resultValues.substring(index + 1),
        );
      }).toList();

      final newSteps = block.steps.map((step) {
        final newStepControls = step.controls.map((control) {
          final index = control.resultValues.lastIndexOf('/');

          if (index == -1) {
            return control.copyWithValues(values: control.resultValues);
          }

          return control.copyWithValues(
            values: control.resultValues.substring(index + 1),
          );
        }).toList();

        return step.copyWith(controls: newStepControls);
      }).toList();

      return block.copyWith(controls: newControls, steps: newSteps);
    }).toList();

    return copyWith(blocks: newBlocks);
  }
}

extension UploadFunctionsTemplate on TemplateModel {
  TemplateModel uploadTemplate() {
    final indexes = stepIndexes();
    final images = imagePaths;

    final newBlocks = blocks.map((block) {
      if (block.isStep && indexes.isNotEmpty) {
        final filteredSteps = indexes
            .map((i) {
              if (i >= 0 && i < block.steps.length) {
                return block.steps[i];
              }
              return null;
            })
            .whereType<StepModel>()
            .toList();

        return block.copyWith(steps: filteredSteps);
      }

      return block;
    }).toList();

    return copyWith(blocks: newBlocks).updateTemplateImageResultValues(images);
  }
}

extension ResultValuesFunctionsTemplate on TemplateModel {
  TemplateModel updateTemplateImageResultValues(List<ImageModel> images) {
    final newBlocks = blocks.map((block) {
      final newControls = block.controls.map((control) {
        if (control.resultValues.isNotEmpty) {
          if (control.type == ControlType.photo) {
            final imageModel = images.firstWhere(
              (img) => img.path == control.resultValues,
              orElse: () => const ImageModel(),
            );

            if (imageModel.path.isNotEmpty) {
              return control.copyWithValues(
                  values: "${imageModel.name}.${imageModel.type}");
            }
          } else {
            final index = control.resultValues.lastIndexOf('/');
            if (index != -1) {
              return control.copyWithValues(
                values: control.resultValues.substring(index + 1),
              );
            }
          }
        }

        return control;
      }).toList();

      final newSteps = block.steps.map((step) {
        final newStepControls = step.controls.map((control) {
          if (control.resultValues.isNotEmpty) {
            if (control.type == ControlType.photo) {
              final imageModel = images.firstWhere(
                (img) => img.path == control.resultValues,
                orElse: () => const ImageModel(),
              );

              if (imageModel.path.isNotEmpty) {
                return control.copyWithValues(
                    values: "${imageModel.name}.${imageModel.type}");
              }
            } else {
              final index = control.resultValues.lastIndexOf('/');
              if (index != -1) {
                return control.copyWithValues(
                  values: control.resultValues.substring(index + 1),
                );
              }
            }
          }

          return control;
        }).toList();

        return step.copyWith(controls: newStepControls);
      }).toList();

      return block.copyWith(controls: newControls, steps: newSteps);
    }).toList();

    return copyWith(blocks: newBlocks);
  }
}

extension BlockBlock on BlockModel {
  bool get isStep => steps.isNotEmpty;

  String get localizedName {
    final data = switch (AppGlobals.lang) {
      'ru' => blockNameRu,
      'uz' => blockNameUz,
      _ => blockNameEn,
    };
    if (data.isEmpty) {
      return str(blockType);
    }
    return data;
  }

  List<int> stepIndexes(String startDate) {
    final date = DateTime.tryParse(startDate);
    final today = DateTime.now();
    if (date == null) return [];

    final diff = today.difference(date).inDays;
    final list = <int>[];

    for (int i = 0; i < steps.length; i++) {
      final days = steps[i]
          .days
          .split('-')
          .map((e) => int.tryParse(e))
          .where((e) => e != null)
          .toList();
      if (days.length == 2) {
        if (diff >= days[0]! && diff <= days[1]!) {
          list.add(i);
        }
      }
    }

    return list;
  }

  List<StepModel> getSteps(List<int> indexes) =>
      indexes.map((i) => steps[i]).toList();
}

extension ControlLocalizationValues on ControlModel {
  String localizedLabel(String lang) => switch (lang) {
        'ru' => labelRu,
        'uz' => labelUz,
        _ => labelEn,
      };

  String localizedDescr(String lang) => switch (lang) {
        'ru' => descrRu,
        'uz' => descrUz,
        _ => descrEn,
      };

  String localizedValues(String lang) => switch (lang) {
        'ru' => valuesRu,
        'uz' => valuesUz,
        _ => valuesEn,
      };
}

extension StepLocalizationValues on StepModel {
  String localizedName(String lang) => switch (lang) {
        'ru' => nameRu,
        'uz' => nameUz,
        _ => nameEn,
      };

  String localizedDescription(String lang) => switch (lang) {
        'ru' => descriptionRu,
        'uz' => descriptionUz,
        _ => descriptionEn,
      };
}

extension ControlModelCopyWithHelper on ControlModel {
  ControlModel copyWithValues({required String values}) {
    return switch (_lang) {
      'ru' => copyWith(valuesRu: values),
      'uz' => copyWith(valuesUz: values),
      _ => copyWith(valuesEn: values),
    };
  }

  ControlModel copyWithValuesByLang({required String values}) {
    return switch (_lang) {
      'ru' => copyWith(valuesRu: values),
      'uz' => copyWith(valuesUz: values),
      _ => copyWith(valuesEn: values),
    };
    // return copyWith(
    //   valuesEn: values,
    //   valuesRu: values,
    //   valuesUz: values,
    // );
  }
}
