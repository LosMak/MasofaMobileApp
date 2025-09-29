import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';

class TemplateHelper {


  static List<String> getDisabledFieldsByBlock(BlockModel model) {
    if (model.blockType == 'fertilizers_pesticides_input') {
      final skipDataInput =
          model.controls.where((e) => e.name == 'skip_data_input').firstOrNull;
      final disabledFields = model.controls
          .where((e) => e != skipDataInput)
          .map((e) => e.name)
          .toList();
      if (skipDataInput == null) return [];
      if (skipDataInput.resultValues.isEmpty ||
          skipDataInput.resultValues == 'unchecked') {
        return disabledFields;
      }
    }
    return [];
  }

  static List<String> getDisabledFieldsByControl(ControlModel model) {
    if (model.type == ControlType.checklist) {
      final noProblemText =
          model.localizedValues(AppGlobals.lang).split('; ').first;
      if (model.resultValues.isEmpty) return [];
      if (model.resultValues.contains(noProblemText)) {
        return model
            .localizedValues(AppGlobals.lang)
            .replaceFirst(noProblemText, '')
            .trim()
            .split('; ');
      } else if (!model.resultValues.contains(noProblemText)) {
        return [noProblemText];
      }
    }
    return [];
  }

  static List<ControlModel> getPestecides(BlockModel model) {
    if (model.blockType == 'fertilizers_pesticides_input') {
      final pestecides = model.controls
          .where(
            (e) => e.name != 'skip_data_input' && e.source != SourceType.local,
          )
          .map(
            (e) => e.copyWith(resultValues: ''),
          )
          .toSet()
          .toList();
      const deleteButton =
          ControlModel(name: 'delete_button', source: SourceType.local);
      const separator =
          ControlModel(name: 'separator', source: SourceType.local);
      return [separator, deleteButton, ...pestecides];
    }
    return [];
  }
}
