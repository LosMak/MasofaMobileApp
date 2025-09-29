import 'package:dala_ishchisi/common/theme/app_colors.dart';
import 'package:flutter/material.dart';

class WidgetIndicator extends StatelessWidget {
  final int pageCount;
  final int currentPage;
  final Duration duration;

  const WidgetIndicator({
    super.key,
    required this.pageCount,
    required this.currentPage,
    this.duration = const Duration(milliseconds: 300),
  });

  @override
  Widget build(BuildContext context) {
    const spacing = 4.0;
    const dotSize = 6.0;
    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(pageCount, (index) {
        return AnimatedContainer(
          duration: duration,
          margin: const EdgeInsets.symmetric(horizontal: spacing / 2),
          width: index == currentPage ? dotSize * 3 : dotSize,
          height: dotSize,
          decoration: BoxDecoration(
            color: index == currentPage
                ? AppColors.gray.shade9
                : AppColors.gray.shade2,
            borderRadius: BorderRadius.circular(dotSize / 2),
          ),
        );
      }),
    );
  }
}
