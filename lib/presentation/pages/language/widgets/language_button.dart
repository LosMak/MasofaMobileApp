import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class LanguageButton extends StatelessWidget {
  final String langCode;
  final bool isSelected;
  final Function(String langCode)? onTap;

  const LanguageButton({
    super.key,
    required this.langCode,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: () => onTap?.call(langCode),
      padding: EdgeInsets.zero,
      child: Container(
        margin: isSelected ? const EdgeInsets.all(0) : const EdgeInsets.all(1),
        padding: const EdgeInsets.all(16),
        decoration: ShapeDecoration(
          color: isSelected ? AppColors.gray.shade1 : Colors.white,
          shape: RoundedRectangleBorder(
            side: isSelected
                ? BorderSide(width: 2, color: AppColors.gray.shade9)
                : BorderSide(width: 1, color: AppColors.gray.shade2),
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Row(
          children: [
            SvgPicture.asset('assets/icons/$langCode.svg', height: 24),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                str(langCode),
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.gray.shade9,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
