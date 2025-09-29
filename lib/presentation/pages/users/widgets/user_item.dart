import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/user_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class UserItem extends StatelessWidget {
  final UserModel user;
  final bool isSelected;
  final bool isFirst;
  final bool isLast;
  final Function()? onTap;

  const UserItem({
    super.key,
    required this.user,
    required this.isSelected,
    required this.isFirst,
    required this.isLast,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gray.shade1,
        border: Border.all(width: 1, color: AppColors.gray.shade3),
        borderRadius: BorderRadius.vertical(
          top: isFirst ? const Radius.circular(8) : Radius.zero,
          bottom: isLast ? const Radius.circular(8) : Radius.zero,
        ),
      ),
      child: CupertinoButton(
        minSize: 0,
        padding: EdgeInsets.zero,
        onPressed: onTap,
        child: Row(
          spacing: 16,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                spacing: 2,
                children: [
                  Text(
                    user.name,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 15,
                      color: AppColors.gray.shade9,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    user.parentId.isNotEmpty
                        ? Words.worker.str
                        : Words.foreman.str,
                    style: TextStyle(
                      color: AppColors.gray.shade5,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              HeroIcon(
                HeroIcons.check,
                style: HeroIconStyle.mini,
                color: Theme.of(context).textTheme.bodyMedium?.color,
              ),
          ],
        ),
      ),
    );
  }
}
