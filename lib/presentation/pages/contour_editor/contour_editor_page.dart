import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'contour_editor_view.dart';

@RoutePage()
class ContourEditorPage extends StatelessWidget {
  final String title;
  final LatLng initialPosition;
  final List<LatLng>? initialPoints;
  final double zoom;
  final bool isPolygon;
  final Function(List<LatLng> points)? onResult;
  final String regionId;

  const ContourEditorPage({
    super.key,
    required this.title,
    required this.initialPosition,
    this.initialPoints,
    this.zoom = 19,
    this.isPolygon = false,
    this.onResult,
    required this.regionId,
  });

  @override
  Widget build(BuildContext context) {
    return ContourEditorView(
      title: title,
      initialPosition: initialPosition,
      initialPoints: initialPoints,
      zoom: zoom,
      isPolygon: isPolygon,
      onResult: onResult,
      regionId: regionId,
    );
  }
}
