import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/common/helpers/template_helper.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'dynamic_field.dart';

class BlockItem extends StatelessWidget {
  final BidModel bid;
  final List<String> disabledFields;
  final String title;
  final bool checkValidate;
  final bool readOnly;
  final BlockModel block;
  final List<ControlModel> controls;
  final Function(ControlModel control, int index)? onChanged;
  final void Function(
    int controlIndex,
    List<ControlModel> controls,
  )? onDublicateControls;

  final void Function(
    int startIndexControl,
    int endIndexControl,
    List<ControlModel> controls,
  )? onDeleteControls;
  final String lang;

  const BlockItem({
    super.key,
    required this.bid,
    required this.title,
    required this.checkValidate,
    required this.block,
    this.readOnly = false,
    this.controls = const [],
    this.onChanged,
    required this.lang,
    this.disabledFields = const [],
    this.onDublicateControls,
    this.onDeleteControls,
  });

  @override
  Widget build(BuildContext context) {
    final length = controls.length;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: ShapeDecoration(
        color: Theme.of(context).cardColor,
        shape: Theme.of(context).cardTheme.shape!,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              color: AppColors.gray.shade9,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 24),
          ListView.builder(
            shrinkWrap: true,
            padding: EdgeInsets.zero,
            itemCount: length,
            physics: const NeverScrollableScrollPhysics(),
            itemBuilder: (_, i) {
              final model = controls[i];

              if (model.auto) return const SizedBox();

              if (i > 0 && model.type == ControlType.photo) {
                final prev = controls[i - 1];
                if (prev.type == ControlType.checklist) {
                  final disabled = prev.resultValues.isEmpty;
                  return _Item(
                    bid: bid,
                    control: model,
                    checkValidate: !disabled ? checkValidate : false,
                    index: i,
                    length: length,
                    disabled: disabled,
                    readOnly: readOnly,
                    onChanged: onChanged,
                    lang: lang,
                  );
                }
              }

              if (block.blockType == 'fertilizers_pesticides_input' &&
                  model.name == 'delete_button') {
                return Align(
                  alignment: Alignment.centerRight,
                  child: CupertinoButton(
                    minSize: 0,
                    padding: const EdgeInsets.all(3),
                    onPressed: () {
                      final currentIndex = i - 1;
                      onDeleteControls?.call(
                        currentIndex,
                        i + 7,
                        controls,
                      );
                    },
                    child: Icon(
                      CupertinoIcons.delete,
                      color: AppColors.red.shade4,
                      size: 20,
                    ),
                  ),
                );
              }

              if (model.name == 'separator') {
                return const Column(
                  children: [
                    SizedBox(height: 20),
                    Divider(),
                    SizedBox(height: 20),
                  ],
                );
              }

              if (block.blockType == 'fertilizers_pesticides_input') {
                if (i == 1) {
                  return Column(
                    children: [
                      _Item(
                        bid: bid,
                        control: model,
                        checkValidate: checkValidate,
                        index: i,
                        length: length,
                        readOnly: readOnly,
                        onChanged: onChanged,
                        lang: lang,
                        disabled: disabledFields.contains(model.name),
                      ),
                      const Divider(),
                      const SizedBox(height: 20),
                    ],
                  );
                } else if (length != i + 1) {
                  return _Item(
                    bid: bid,
                    control: model,
                    checkValidate: checkValidate,
                    index: i,
                    length: length,
                    readOnly: readOnly,
                    onChanged: onChanged,
                    lang: lang,
                    disabled: disabledFields.contains(model.name),
                  );
                }
                return Column(
                  children: [
                    _Item(
                      bid: bid,
                      control: model,
                      checkValidate: checkValidate,
                      index: i,
                      length: length,
                      readOnly: readOnly,
                      onChanged: onChanged,
                      lang: lang,
                      disabled: disabledFields.contains(model.name),
                    ),
                    const SizedBox(height: 20),
                    Opacity(
                      opacity: disabledFields.isNotEmpty ? 0.4 : 1,
                      child: IgnorePointer(
                        ignoring: disabledFields.isNotEmpty,
                        child: CupertinoButton(
                          minSize: 0,
                          padding: EdgeInsets.zero,
                          onPressed: () {
                            final controls =
                                TemplateHelper.getPestecides(block);
                            onDublicateControls?.call(i, controls);
                          },
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            alignment: Alignment.center,
                            decoration: ShapeDecoration(
                              color: AppColors.gray.shade9,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: Text(
                              Words.add.str,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                );
              }

              if (model.type == ControlType.checklist) {
                return _Item(
                  bid: bid,
                  control: model,
                  checkValidate: checkValidate,
                  index: i,
                  length: length,
                  readOnly: readOnly,
                  onChanged: onChanged,
                  lang: lang,
                  disabledFields:
                      TemplateHelper.getDisabledFieldsByControl(model),
                );
              }

              return _Item(
                bid: bid,
                control: model,
                checkValidate: checkValidate,
                index: i,
                length: length,
                readOnly: readOnly,
                onChanged: onChanged,
                lang: lang,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _Item extends StatelessWidget {
  final BidModel bid;
  final ControlModel control;
  final bool checkValidate;
  final int index;
  final int length;
  final bool readOnly;
  final bool disabled;
  final Function(ControlModel control, int index)? onChanged;
  final String lang;
  final List<String> disabledFields;

  const _Item({
    required this.bid,
    required this.control,
    required this.checkValidate,
    required this.index,
    required this.length,
    required this.readOnly,
    this.disabled = false,
    this.onChanged,
    required this.lang,
    this.disabledFields = const [],
  });

  @override
  Widget build(BuildContext context) {
    final hasError = checkValidate && control.controlError != null && !disabled;
    return Opacity(
      opacity: disabled ? 0.4 : 1,
      child: IgnorePointer(
        ignoring: disabled,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(text: control.localizedLabel(lang)),
                  if (control.required)
                    TextSpan(
                      text: ' *',
                      style: TextStyle(
                        color: AppColors.red.shade5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                ],
                style: TextStyle(
                  color:
                      hasError ? AppColors.red.shade5 : AppColors.gray.shade9,
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            const SizedBox(height: 4),
            DynamicField(
              bid: bid,
              control: control,
              readOnly: readOnly,
              onChange: (control) => onChanged?.call(control, index),
              lang: lang,
              disabledFields: disabledFields,
            ),
            if (index != length - 1) const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}
