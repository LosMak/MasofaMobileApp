import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final bool loading;
  final bool enabled;
  final Function()? onTap;

  const CustomButton({
    super.key,
    required this.text,
    this.loading = false,
    this.enabled = true,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      onPressed: enabled ? onTap : null,
      color: AppColors.gray.shade9,
      disabledColor: AppColors.gray.shade3,
      padding: EdgeInsets.zero,
      borderRadius: BorderRadius.circular(8),
      minSize: 52,
      child: SizedBox(
        width: double.infinity,
        child: loading
            ? const CupertinoActivityIndicator(color: Colors.white)
            : Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
      ),
    );
  }
}
