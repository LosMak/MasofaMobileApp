import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/cupertino.dart';
import 'package:heroicons/heroicons.dart';

// use leadingWidth: 100 in app bar
class CustomAppbarBack extends StatelessWidget {
  final Function()? onPressed;

  const CustomAppbarBack({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      padding: EdgeInsets.zero,
      onPressed: onPressed ?? () => Navigator.pop(context),
      child: Row(
        children: [
          const SizedBox(width: 4),
          HeroIcon(HeroIcons.chevronLeft, color: AppColors.blue.shade5),
          Text(
            Words.back.str,
            style: TextStyle(
              color: AppColors.blue.shade5,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
