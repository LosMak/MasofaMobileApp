import 'package:dala_ishchisi/common/extensions/bid_state_colors.dart';
import 'package:dala_ishchisi/common/extensions/bid_state_extension.dart';
import 'package:dala_ishchisi/common/extensions/string_extensions.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:heroicons/heroicons.dart';

class TaskItem extends StatelessWidget {
  final BidModel bid;
  final Function()? onTap;

  const TaskItem({super.key, required this.bid, this.onTap});

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      onPressed: onTap,
      padding: EdgeInsets.zero,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: ShapeDecoration(
          color: Theme.of(context).cardColor,
          shape: Theme.of(context).cardTheme.shape!,
        ),
        child: Column(
          spacing: 12,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 4,
                  ),
                  decoration: ShapeDecoration(
                    color: bidStateBGColor(bid.bidState),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    bid.bidState.value,
                    style: TextStyle(
                      color: bidStateTextColor(bid.bidState),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Spacer(),
                HeroIcon(
                  HeroIcons.chevronRight,
                  size: 24,
                  style: HeroIconStyle.mini,
                  color: bidStateTextColor(bid.bidState),
                ),
              ],
            ),
            Text(
              "ID: ${bid.number}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (bid.description.isNotEmpty)
              Text(
                bid.description,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            Row(
              spacing: 6,
              children: [
                HeroIcon(
                  HeroIcons.cubeTransparent,
                  style: HeroIconStyle.mini,
                  color: AppColors.green.shade5,
                  size: 18,
                ),
                Expanded(
                  child: Text(
                    bid.crop.nameStr,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray.shade5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
            if (bid.district.nameStr.isNotEmpty)
              Row(
                spacing: 6,
                children: [
                  HeroIcon(
                    HeroIcons.mapPin,
                    color: AppColors.green.shade5,
                    size: 18,
                  ),
                  Expanded(
                    child: Text(
                      "${bid.region.nameStr}, ${bid.district.nameStr}",
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.gray.shade5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            Row(
              spacing: 6,
              children: [
                HeroIcon(
                  HeroIcons.calendarDays,
                  color: AppColors.green.shade5,
                  size: 18,
                ),
                Expanded(
                  child: Text(
                    "${bid.startDate.dateFormat} - ${bid.deadlineDate.dateFormat}",
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 14,
                      color: AppColors.gray.shade5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
