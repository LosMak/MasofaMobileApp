import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/common/helpers/template_helper.dart';
import 'package:dala_ishchisi/common/helpers/template_helper.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'block_item.dart';

typedef OnAddBlock = void Function(
  int blockIndex,
  int controlIndex,
  List<ControlModel> controls,
);

class SampleBlockList extends StatelessWidget {
  final BidModel bid;
  final TemplateModel template;
  final bool checkValidate;
  final bool canEdit;
  final Function(TemplateModel template)? onChanged;
  final String lang;

  const SampleBlockList({
    super.key,
    required this.bid,
    required this.template,
    required this.checkValidate,
    required this.canEdit,
    this.onChanged,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      padding: EdgeInsets.zero,
      itemCount: template.blocks.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, blockIndex) {
        final model = template.blocks[blockIndex];
        if (model.isStep) return const SizedBox();

        return BlockItem(
          bid: bid,
          title: model.localizedName,
          checkValidate: checkValidate,
          controls: model.controls,
          block: model,
          disabledFields: TemplateHelper.getDisabledFieldsByBlock(model),
          readOnly: !canEdit,
          onChanged: (control, index) {
            final newTemplate = template.updateTemplate(
              control: control,
              blockIndex: blockIndex,
              controlIndex: index,
            );
            onChanged?.call(newTemplate);
          },
          onDublicateControls: (controlIndex, controls) {
            final newTemplate =
                template.addControlsToBlock(blockIndex, controls);
            onChanged?.call(newTemplate);
          },
          onDeleteControls:
              (startIndexControl, endIndexControl, controls) async {
            final result = await showDeleteBlockDialog(context);

            if (result != null && result) {
              final newTemplate = template.removeControlsFromBlock(
                  blockIndex, startIndexControl, endIndexControl);

              onChanged?.call(newTemplate);
            }
          },
          lang: lang,
        );
      },
    );
  }

  Future<bool?> showDeleteBlockDialog(BuildContext context) {
    return showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) {
        return CupertinoAlertDialog(
          title: Text(Words.warning.str),
          content: Text(Words.deleteBlock.str),
          actions: [
            CupertinoDialogAction(
              isDefaultAction: true,
              onPressed: () => Navigator.of(context).pop(false),
              child: Text(Words.no.str),
            ),
            CupertinoDialogAction(
              isDestructiveAction: true,
              onPressed: () => Navigator.of(context).pop(true),
              child: Text(Words.yes.str),
            ),
          ],
        );
      },
    );
  }
}
