import 'dart:developer';
import 'dart:io';

import 'package:dala_ishchisi/application/device_info/device_info_bloc.dart';
import 'package:dala_ishchisi/common/extensions/image_extensions.dart';
import 'package:dala_ishchisi/common/extensions/position_extension.dart';
import 'package:dala_ishchisi/common/extensions/template_extensions.dart';
import 'package:dala_ishchisi/common/helpers/remove_leading_zero_formatter.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:dala_ishchisi/main.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:heroicons/heroicons.dart';
import 'package:image_picker/image_picker.dart';

class DynamicField extends StatefulWidget {
  final BidModel bid;
  final ControlModel control;
  final bool readOnly;
  final Function(ControlModel control)? onChange;
  final String lang;
  final List<String> disabledFields;

  const DynamicField({
    super.key,
    required this.bid,
    required this.control,
    required this.readOnly,
    this.onChange,
    required this.lang,
    this.disabledFields = const [],
  });

  @override
  State<DynamicField> createState() => _DynamicFieldState();
}

class _DynamicFieldState extends State<DynamicField> {
  final controller = TextEditingController();
  var keyboardType = TextInputType.text;
  var readOnly = true;
  var values = <String>[];
  List<String> disabledFields = [];

  final style = TextStyle(
    color: AppColors.gray.shade9,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );
  final hintStyle = TextStyle(
    color: AppColors.gray.shade4,
    fontSize: 15,
    fontWeight: FontWeight.w400,
  );

  @override
  void initState() {
    setValue(widget.control, widget.bid);
    setKeyboardType(widget.control);
    setReadOnly(widget.control);
    setValues(widget.control);
    disabledFields = widget.disabledFields;
    setState(() {});

    controller.addListener(() {
      if (controller.text != widget.control.resultValues) {
        widget.onChange?.call(widget.control.copyWith(
          resultValues: controller.text,
        ));
      }
      setState(() {});
    });
    super.initState();
  }

  void setValue(ControlModel control, BidModel bid) {
    if (control.resultValues.isNotEmpty) {
      controller.text = control.resultValues;
    } else if (control.type == ControlType.checkbox) {
      controller.text = control.localizedValues(widget.lang);
    }
  }

  void setKeyboardType(ControlModel control) {
    switch (control.type) {
      case ControlType.int:
        keyboardType = const TextInputType.numberWithOptions(signed: true);
        break;
      case ControlType.decimal:
      case ControlType.float:
        keyboardType = const TextInputType.numberWithOptions(
          decimal: true,
          signed: true,
        );
        break;
      default:
        keyboardType = TextInputType.text;
        break;
    }
  }

  void setReadOnly(ControlModel control) {
    switch (control.type) {
      case ControlType.string:
      case ControlType.int:
      case ControlType.decimal:
      case ControlType.float:
        readOnly = false;
        break;
      default:
        readOnly = true;
        break;
    }
  }

  void setValues(ControlModel control) {
    values = control
        .localizedValues(widget.lang)
        .split(';')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.control.type == ControlType.dropdown) {
      return DropdownButtonFormField<String>(
        isExpanded: true,
        elevation: 1,
        value: controller.text.isNotEmpty &&
                values.contains(controller
                    .text) // ! values.contains(controller.text) - Временное решение
            ? controller.text
            : null,
        dropdownColor: Colors.white,
        borderRadius: BorderRadius.circular(8),
        onChanged: (value) {
          if (widget.readOnly) return;
          if (value != null) controller.text = value;
        },
        hint:
            Text(widget.control.localizedLabel(widget.lang), style: hintStyle),
        items: widget.readOnly
            ? []
            : values
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Text(
                      item,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: style,
                    ),
                  ),
                )
                .toList(),
      );
    }

    if (widget.control.type == ControlType.checkbox) {
      return CupertinoButton(
        minSize: 0,
        padding: EdgeInsets.zero,
        onPressed: () {
          if (widget.readOnly) return;
          controller.text =
              controller.text == 'unchecked' ? 'checked' : 'unchecked';
        },
        child: Row(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (controller.text == 'unchecked')
              Icon(Icons.check_box_outline_blank, color: AppColors.gray.shade5),
            if (controller.text == 'checked')
              Icon(Icons.check_box_outlined, color: AppColors.green.shade5),
            Expanded(child: Text(Words.accept.str, style: style)),
          ],
        ),
      );
    }

    if (widget.control.type == ControlType.checklist) {
      return ListView.separated(
        shrinkWrap: true,
        itemCount: values.length,
        padding: EdgeInsets.zero,
        physics: const NeverScrollableScrollPhysics(),
        separatorBuilder: (_, i) => const SizedBox(height: 4),
        itemBuilder: (_, i) {
          final checkedValues = controller.text
              .split(';')
              .map((e) => e.trim())
              .where((e) => e.isNotEmpty)
              .toList();
          final checked = checkedValues.contains(values[i]);
          final listDisabledFields = widget.disabledFields;
          final disabled = listDisabledFields.contains(values[i]);
          return IgnorePointer(
            ignoring: disabled,
            child: Opacity(
              opacity: disabled ? 0.4 : 1,
              child: CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (widget.readOnly) return;
                  if (checked) {
                    checkedValues.remove(values[i]);
                  } else {
                    checkedValues.add(values[i]);
                  }
                  controller.text = checkedValues.join(';');
                },
                child: Row(
                  spacing: 4,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    checked
                        ? Icon(
                            Icons.check_box_outlined,
                            color: AppColors.green.shade5,
                          )
                        : Icon(
                            Icons.check_box_outline_blank,
                            color: AppColors.gray.shade5,
                          ),
                    Expanded(child: Text(values[i], style: style)),
                  ],
                ),
              ),
            ),
          );
        },
      );
    }

    if (widget.control.type == ControlType.photo) {
      final file = File(controller.text);
      final exist = file.existsSync();
      return Row(
        spacing: 8,
        mainAxisSize: MainAxisSize.min,
        children: [
          BlocBuilder<DeviceInfoBloc, DeviceInfoState>(
            builder: (context, state) {
              return CupertinoButton(
                minSize: 0,
                padding: EdgeInsets.zero,
                onPressed: () {
                  if (widget.readOnly) return;
                  pickImage(
                    source: state.statusRealDevice.isSuccess
                        ? ImageSource.camera
                        : ImageSource.gallery,
                  ).then((path) {
                    if (path != null) controller.text = path;
                  });
                },
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: ShapeDecoration(
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                      side: BorderSide(width: 1, color: AppColors.gray.shade2),
                    ),
                  ),
                  child: !exist
                      ? Icon(
                          CupertinoIcons.camera,
                          color: AppColors.gray.shade3,
                          size: 28,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(controller.text),
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              );
            },
          ),
          if (exist && !widget.readOnly)
            CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: () => controller.text = '',
              child: Icon(CupertinoIcons.delete, color: AppColors.red.shade5),
            ),
        ],
      );
    }

    if (widget.control.type == ControlType.int ||
        widget.control.type == ControlType.float ||
        widget.control.type == ControlType.decimal) {
      String? error;
      if (controller.text.isNotEmpty) {
        error = widget.control.controlError;
        if (error != null) {
          error = '$values';
        }
      }
      return SizedBox(
        height: 40 + (error == null ? 0 : 20),
        child: TextField(
          controller: controller,
          scrollPadding: EdgeInsets.zero,
          keyboardType: keyboardType,
          readOnly: readOnly || widget.readOnly,
          style: style,
          inputFormatters: [
            if (widget.control.type == ControlType.int)
              RemoveLeadingZeroFormatter(),
          ],
          decoration: InputDecoration(
            hintText: widget.control.localizedLabel(widget.lang),
            hintStyle: hintStyle,
            errorText: error,
          ),
        ),
      );
    }

    if (widget.control.type == ControlType.string &&
        widget.control.name == 'polygon') {
      return CupertinoButton(
        minSize: 0,
        padding: EdgeInsets.zero,
        onPressed: () {
          router.push(ContourEditorRoute(
            title: widget.control.localizedLabel(widget.lang),
            initialPosition: LatLng(
              widget.bid.position.latitude,
              widget.bid.position.longitude,
            ),
            initialPoints: controller.text.toLatLngList(),
            onResult: (positions) =>
                controller.text = positions.toLatLngString(),
            regionId: widget.bid.regionId,
          ));
        },
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: ShapeDecoration(
            color: AppColors.gray.shade0,
            shape: RoundedRectangleBorder(
              side: BorderSide(
                width: 1,
                color: AppColors.gray.shade2,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: Row(
            spacing: 10,
            mainAxisSize: MainAxisSize.min,
            children: [
              HeroIcon(
                HeroIcons.map,
                color: controller.text.isNotEmpty
                    ? AppColors.blue.shade5
                    : AppColors.gray.shade5,
              ),
              Text(
                widget.control.localizedLabel(widget.lang),
                style: TextStyle(
                  color: controller.text.isNotEmpty
                      ? AppColors.blue.shade5
                      : AppColors.gray.shade5,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 40,
      child: TextField(
        controller: controller,
        scrollPadding: EdgeInsets.zero,
        keyboardType: keyboardType,
        readOnly: readOnly || widget.readOnly,
        style: style,
        decoration: InputDecoration(
          hintText: widget.control.localizedLabel(widget.lang),
          hintStyle: hintStyle,
        ),
        onTap: widget.control.type == ControlType.date
            ? () async {
                if (widget.readOnly) return;

                final date = DateTime.tryParse(controller.text);
                final selectedDate = await showDatePicker(
                  context: context,
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                  currentDate: date,
                );
                if (selectedDate != null) {
                  controller.text = DateFormat('yyyy-MM-dd').format(
                    selectedDate,
                  );
                }
              }
            : null,
      ),
    );
  }
}
