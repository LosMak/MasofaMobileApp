import 'package:flutter/material.dart';

import 'custom_shimmer.dart';

class CustomShimmerText extends StatelessWidget {
  final double width;
  final double height;
  final double radius;
  final Color? baseColor;
  final Color? highlightColor;

  const CustomShimmerText({
    super.key,
    this.width = 56,
    this.height = 20,
    this.radius = 4,
    this.baseColor,
    this.highlightColor,
  });

  @override
  Widget build(BuildContext context) {
    return CustomShimmer(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      ),
    );
  }
}
