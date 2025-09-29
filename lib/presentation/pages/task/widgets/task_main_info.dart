import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/common/extensions/string_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/meta_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:heroicons/heroicons.dart';

class TaskMainInfo extends StatelessWidget {
  const TaskMainInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BidBloc, BidState>(
      buildWhen: (old, e) => old.bid != e.bid,
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// Task name
            Text(
              Words.taskName.str,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.bid.description,
              style: TextStyle(
                color: AppColors.gray.shade7,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            /// Task short info
            Text(
              Words.shortInfo.str,
              style: TextStyle(
                color: Theme.of(context).hintColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.bid.comment,
              style: TextStyle(
                color: AppColors.gray.shade7,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 16),

            /// Crop
            if (state.bid.crop.nameStr.isNotEmpty)
              Row(
                spacing: 6,
                children: [
                  HeroIcon(
                    HeroIcons.cubeTransparent,
                    style: HeroIconStyle.mini,
                    color: AppColors.gray.shade5,
                    size: 18,
                  ),
                  Expanded(
                    child: Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(text: "${Words.crop.str}: "),
                          TextSpan(
                            text: state.bid.crop.nameStr,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.gray.shade9,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ],
              ),
            if (state.bid.crop.nameStr.isNotEmpty) const SizedBox(height: 16),

            /// Date
            Row(
              spacing: 10,
              children: [
                Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      HeroIcon(
                        HeroIcons.calendarDays,
                        color: AppColors.gray.shade5,
                        size: 20,
                      ),
                      Expanded(
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Words.dateStart.str,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              state.bid.startDate.dateFormat,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    spacing: 8,
                    children: [
                      HeroIcon(
                        HeroIcons.calendarDays,
                        color: AppColors.gray.shade5,
                        size: 20,
                      ),
                      Expanded(
                        child: Column(
                          spacing: 3,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              Words.dateEnd.str,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            Text(
                              state.bid.deadlineDate.dateFormat,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
