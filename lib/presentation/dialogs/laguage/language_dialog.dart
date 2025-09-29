import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/material.dart';

import 'language_view.dart';

class LanguageDialog extends StatelessWidget {
  const LanguageDialog({super.key});

  Future<dynamic> show(BuildContext context) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => this,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 30),
      decoration: const ShapeDecoration(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(16),
            topRight: Radius.circular(16),
          ),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 20),
          Container(
            width: 42,
            height: 6,
            decoration: ShapeDecoration(
              color: AppColors.gray.shade3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
            ),
          ),
          const SizedBox(height: 20),
          const LanguageView(),
        ],
      ),
    );
  }
}
