import 'package:flutter/material.dart';

class RegionInheritedWidget extends InheritedWidget {
  final String regionId;

  const RegionInheritedWidget({
    super.key,
    required super.child,
    required this.regionId,
  });

  @override
  bool updateShouldNotify(covariant RegionInheritedWidget oldWidget) {
    return regionId != oldWidget.regionId;
  }

  static RegionInheritedWidget of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<RegionInheritedWidget>()
          as RegionInheritedWidget;
}
