import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:flutter/material.dart';

import 'block_item.dart';

class StepBlockList extends StatelessWidget {
  final BidModel bid;
  final TemplateModel template;
  final List<int> stepIndexes;
  final bool canEdit;
  final bool checkValidate;
  final int blocStepIndex;
  final Function(TemplateModel template)? onChanged;
  final String lang;

  const StepBlockList({
    super.key,
    required this.bid,
    required this.template,
    required this.stepIndexes,
    required this.canEdit,
    required this.checkValidate,
    required this.blocStepIndex,
    this.onChanged,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: template.blocks.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (_, blockIndex) {
        final model = template.blocks[blockIndex];
        if (model.isStep) {
          final beginningStepIndex = template.blocks.indexWhere((e) => e.isStep);
          if (beginningStepIndex == -1) {
            return const SizedBox();
          }
          if (blockIndex != blocStepIndex + beginningStepIndex) {
            return const SizedBox();
          }

          return ListView.builder(
            shrinkWrap: true,
            itemCount: model.steps.length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, stepIndex) {
              final step = model.steps[stepIndex];
              if (!stepIndexes.contains(stepIndex)) {
                return const SizedBox();
              }
              return BlockItem(
                bid: bid,
                title: step.localizedName(lang),
                checkValidate: checkValidate,
                block: model,
                controls: step.controls,
                readOnly: !canEdit,
                onChanged: (control, controlIndex) {
                  final newTemplate = template.updateTemplateWithStep(
                    control: control,
                    blockIndex: blockIndex,
                    controlIndex: controlIndex,
                    stepIndex: stepIndex,
                  );
                  onChanged?.call(newTemplate);
                },
                lang: lang,
              );
            },
          );
        }
        return const SizedBox();
      },
    );
  }
}
