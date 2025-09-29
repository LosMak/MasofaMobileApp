import 'dart:math';

import 'package:auto_route/auto_route.dart';
import 'package:dala_ishchisi/application/bid/bid_bloc.dart';
import 'package:dala_ishchisi/common/extensions/archive_state_color.dart';
import 'package:dala_ishchisi/common/extensions/string_extensions.dart';
import 'package:dala_ishchisi/common/localization/localization.dart';
import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:dala_ishchisi/domain/models/archive_model.dart';
import 'package:dala_ishchisi/presentation/routes/app_router.gr.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:heroicons/heroicons.dart';

class ArchiveTaskItem extends StatelessWidget {
  final ArchiveModel archive;
  final ArchiveModel? currentArchiveUpload;
  final VoidCallback? onSendPressed;
  final VoidCallback? onDeletePressed;
  const ArchiveTaskItem({
    super.key,
    required this.archive,
    this.onSendPressed,
    this.onDeletePressed,
    this.currentArchiveUpload,
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoButton(
      minSize: 0,
      onPressed: () => context.router.push(
        TaskRoute(
          bidBloc: context.read<BidBloc>(),
          bid: archive.bid,
        ),
      ),
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
                    color: ArchiveStatus.archiveChipColor(archive.status),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(100),
                    ),
                  ),
                  child: Text(
                    ArchiveStatus.archiveStatus(archive.status),
                    style: TextStyle(
                      color: ArchiveStatus.archiveTextColor(archive.status),
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
                const Spacer(),
                const HeroIcon(
                  HeroIcons.chevronRight,
                  size: 24,
                  style: HeroIconStyle.mini,
                  color: Color(0xFF67BF2B),
                ),
              ],
            ),
            Text(
              "ID: ${archive.bid.number}",
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Theme.of(context).textTheme.bodyMedium?.color,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (archive.bid.description.isNotEmpty)
              Text(
                archive.bid.description,
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
                  HeroIcons.circleStack,
                  color: AppColors.green.shade5,
                  size: 18,
                ),
                Expanded(
                  child: Text(
                    'Размер: ${archive.size} MB',
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
                    "${archive.bid.startDate.dateFormat} - ${archive.bid.deadlineDate.dateFormat}",
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
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: currentArchiveUpload != null &&
                      currentArchiveUpload?.bid.id == archive.bid.id &&
                      currentArchiveUpload?.status == ArchiveSendStatus.loading
                  ? CupertinoButton(
                      minSize: 0,
                      padding: EdgeInsets.zero,
                      onPressed: null,
                      child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          alignment: Alignment.center,
                          decoration: ShapeDecoration(
                            color: const Color(0xFF00155A),
                            shape: RoundedRectangleBorder(
                              side: const BorderSide(color: Color(0xFF00155A)),
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              value: currentArchiveUpload?.progress,
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )),
                    )
                  : Row(
                      spacing: 12,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Expanded(
                          child: CupertinoButton(
                            minSize: 0,
                            padding: EdgeInsets.zero,
                            onPressed: onDeletePressed,
                            child: Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              alignment: Alignment.center,
                              decoration: ShapeDecoration(
                                color: Colors.white,
                                shape: RoundedRectangleBorder(
                                  side: const BorderSide(
                                      color: Color(0xFFDEE0E3)),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                              ),
                              child: Row(
                                spacing: 2,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  SvgPicture.asset(
                                    'assets/icons/trash.svg',
                                    colorFilter: const ColorFilter.mode(
                                      Color(0xFF0F1324),
                                      BlendMode.srcIn,
                                    ),
                                  ),
                                  Text(
                                    Words.delete.str,
                                    style: const TextStyle(
                                      color: Color(0xFF14151A),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Opacity(
                            opacity: archive.status == ArchiveSendStatus.sent
                                ? 0.4
                                : 1,
                            child: IgnorePointer(
                              ignoring:
                                  archive.status == ArchiveSendStatus.sent,
                              child: CupertinoButton(
                                minSize: 0,
                                padding: EdgeInsets.zero,
                                onPressed: onSendPressed,
                                child: Container(
                                  width: double.infinity,
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8),
                                  alignment: Alignment.center,
                                  decoration: ShapeDecoration(
                                    color: const Color(0xFF00155A),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  child: Row(
                                    spacing: 2,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Transform.rotate(
                                        angle: pi / 4,
                                        child: const Icon(
                                          Icons.navigation_outlined,
                                          color: Colors.white,
                                        ),
                                      ),
                                      Text(
                                        Words.send.str,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
