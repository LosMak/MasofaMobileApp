import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class ActionButtons extends StatelessWidget {
  final Function()? onCancel;
  final Function()? onSave;

  const ActionButtons({super.key, this.onCancel, this.onSave});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 74,
      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 20, top: 8),
      child: Row(
        spacing: 8,
        children: [
          Expanded(
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: onCancel,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      width: 1,
                      color: AppColors.gray.shade2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  Words.cancel.str,
                  style: TextStyle(
                    color: AppColors.gray.shade9,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: CupertinoButton(
              minSize: 0,
              padding: EdgeInsets.zero,
              onPressed: onSave,
              child: Container(
                width: double.infinity,
                height: double.infinity,
                alignment: Alignment.center,
                decoration: ShapeDecoration(
                  color: AppColors.gray.shade9,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Text(
                  Words.save.str,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
