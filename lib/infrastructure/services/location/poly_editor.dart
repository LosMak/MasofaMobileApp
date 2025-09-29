import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

import 'map_marker_controller.dart';

class PolyEditor {
  final List<LatLng> points;
  final BitmapDescriptor pointIcon;
  final BitmapDescriptor? firstPointIcon;
  final void Function(LatLng? updatePoint)? onChanged;
  final bool addClosePathMarker;
  final DragMarkerController markerController;
  final Color openFillColor;
  final Color openStrokeColor;
  final Color closedFillColor;
  final Color closedStrokeColor;
  final Color errorStrokeColor;
  final int strokeWidth;
  final int longPressDelay;
  final VoidCallback? onContourClosed;
  final Function(Set<Polygon> polygons)? onPolygonUpdated;
  final Function(String message, bool isError)? onValidationMessage;

  final Map<String, int> _markerIdToIndex = {};
  final Map<String, DateTime> _markerTapTime = {};
  bool _isContourClosed = false;
  bool _hasIntersections = false;

  PolyEditor({
    required this.points,
    required this.pointIcon,
    required this.markerController,
    this.firstPointIcon,
    this.onChanged,
    this.onContourClosed,
    this.onPolygonUpdated,
    this.onValidationMessage,
    this.addClosePathMarker = false,
    this.longPressDelay = 700,
    this.openFillColor = const Color(0x4D4ADE80),
    this.openStrokeColor = const Color(0xFF22C55E),
    this.closedFillColor = const Color(0x4D3B82F6),
    this.closedStrokeColor = const Color(0xFF2563EB),
    this.errorStrokeColor = const Color(0xFFEF4444),
    this.strokeWidth = 2,
  });

  void _updateMarkerPosition(String markerId, LatLng point) {
    final index = _markerIdToIndex[markerId];
    if (index != null) {
      points[index] = point;
      onChanged?.call(point);
      _validateContour();
      _updatePolygons();
    }
  }

  List<LatLng> add(List<LatLng> pointsList, LatLng point) {
    // If contour is closed, new points cannot be added
    if (_isContourClosed) {
      onValidationMessage?.call(
          "Contour is closed. Reopen it first to add new points", true);
      return pointsList;
    }

    pointsList.add(point);
    onChanged?.call(point);
    _validateContour();
    _updateMarkers();
    _updatePolygons();
    return pointsList;
  }

  LatLng remove(int index) {
    final point = points.removeAt(index);
    onChanged?.call(point);
    _updateContourStatus();
    _validateContour();
    _updateMarkers();
    _updatePolygons();
    return point;
  }

  bool undoLastPoint() {
    if (points.isEmpty) {
      return false;
    }

    if (_isContourClosed && points.length > 1) {
      final firstPoint = points.first;
      final lastPoint = points.last;

      if (firstPoint.latitude == lastPoint.latitude &&
          firstPoint.longitude == lastPoint.longitude) {
        points.removeLast();
        _isContourClosed = false;
        onChanged?.call(null);
        _validateContour();
        _updateMarkers();
        _updatePolygons();
        return true;
      }
    }

    final point = points.removeLast();
    onChanged?.call(point);

    _updateContourStatus();
    _validateContour();
    _updateMarkers();
    _updatePolygons();
    return true;
  }

  void _updateContourStatus() {
    final bool wasClosed = _isContourClosed;
    _isContourClosed = isContourClosed();

    if (!wasClosed && _isContourClosed) {
      onContourClosed?.call();
    }
  }

  void closeContour() {
    if (points.isEmpty || points.length < 3) {
      onValidationMessage?.call(
          "At least 3 points are required to close the contour", true);
      return;
    }

    final firstPoint = points.first;
    final lastPoint = points.last;

    if (firstPoint.latitude != lastPoint.latitude ||
        firstPoint.longitude != lastPoint.longitude) {
      points.add(LatLng(firstPoint.latitude, firstPoint.longitude));
      onChanged?.call(firstPoint);

      _isContourClosed = true;

      _validateContour();
      _updateMarkers();
      _updatePolygons();

      if (!_hasIntersections) {
        onContourClosed?.call();
      }
    }
  }

  void reopenContour() {
    if (_isContourClosed && points.length > 1) {
      points.removeLast();
      _isContourClosed = false;
      _hasIntersections = false;

      onChanged?.call(null);
      _validateContour();
      _updateMarkers();
      _updatePolygons();
    }
  }

  void _updateMarkers() {
    markerController.clear();
    _markerIdToIndex.clear();
    _markerTapTime.clear();

    _createMainMarkers();
  }

  void _createMainMarkers() {
    for (var i = 0; i < points.length; i++) {
      final point = points[i];
      final markerId = 'point_$i';
      _markerIdToIndex[markerId] = i;

      final isFirstPoint = i == 0;
      final isLastPoint = i == points.length - 1 && i > 0;
      final isFirstPointRepeated = i == points.length - 1 &&
          points.length > 1 &&
          points.first.latitude == points.last.latitude &&
          points.first.longitude == points.last.longitude;

      final icon =
          (isFirstPoint || isFirstPointRepeated) && firstPointIcon != null
              ? firstPointIcon!
              : pointIcon;

      markerController.add(
        markerId,
        Marker(
          markerId: MarkerId(markerId),
          position: point,
          draggable: !isFirstPointRepeated,
          icon: icon,
          onDragEnd: (newPosition) {
            _updateMarkerPosition(markerId, newPosition);
          },
          onTap: () {
            if (isFirstPoint && points.length > 2 && !_isContourClosed) {
              closeContour();
              return;
            }

            if (isLastPoint && !isFirstPointRepeated) {
              undoLastPoint();
              return;
            }

            if (isFirstPointRepeated) {
              return;
            }

            final now = DateTime.now();

            if (_markerTapTime.containsKey(markerId)) {
              final lastTap = _markerTapTime[markerId]!;
              final difference = now.difference(lastTap).inMilliseconds;

              if (difference < longPressDelay) {
                remove(i);
                return;
              }
            }

            _markerTapTime[markerId] = now;
          },
        ),
      );
    }
  }

  bool isContourClosed() {
    if (points.length < 2) return false;

    final firstPoint = points.first;
    final lastPoint = points.last;

    return firstPoint.latitude == lastPoint.latitude &&
        firstPoint.longitude == lastPoint.longitude;
  }

  void _validateContour() {
    if (points.length < 3) {
      _hasIntersections = false;
      return;
    }

    // Check for polygon correctness
    _hasIntersections = _checkForSelfIntersections();

    if (_hasIntersections) {
      onValidationMessage?.call(
          "Error: contour has intersections, which creates multiple areas",
          true);
    }
  }

  bool _checkForSelfIntersections() {
    // Not enough points for intersections
    if (points.length < 4) return false;

    for (int i = 0; i < points.length - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];

      // Check against all other segments in the list
      for (int j = i + 2; j < points.length - 1; j++) {
        // Skip checking the last segment against the first segment
        if (i == 0 && j == points.length - 2) continue;

        final p3 = points[j];
        final p4 = points[j + 1];

        if (_doSegmentsIntersect(p1, p2, p3, p4)) {
          return true;
        }
      }
    }
    return false;
  }

  bool _doSegmentsIntersect(LatLng p1, LatLng p2, LatLng p3, LatLng p4) {
    // Check line intersection
    final d1 = _direction(p3, p4, p1);
    final d2 = _direction(p3, p4, p2);
    final d3 = _direction(p1, p2, p3);
    final d4 = _direction(p1, p2, p4);

    // If opposite directions and intersection exists
    if (((d1 > 0 && d2 < 0) || (d1 < 0 && d2 > 0)) &&
        ((d3 > 0 && d4 < 0) || (d3 < 0 && d4 > 0))) {
      return true;
    }

    // Check collinear cases
    if (d1 == 0 && _onSegment(p3, p4, p1)) return true;
    if (d2 == 0 && _onSegment(p3, p4, p2)) return true;
    if (d3 == 0 && _onSegment(p1, p2, p3)) return true;
    if (d4 == 0 && _onSegment(p1, p2, p4)) return true;

    return false;
  }

  int _direction(LatLng p1, LatLng p2, LatLng p3) {
    // Calculate direction
    final val = (p3.longitude - p1.longitude) * (p2.latitude - p1.latitude) -
        (p2.longitude - p1.longitude) * (p3.latitude - p1.latitude);

    if (val.abs() < 1e-10) return 0; // Epsilon value for precision
    return val > 0 ? 1 : -1;
  }

  bool _onSegment(LatLng p1, LatLng p2, LatLng p) {
    // Check if point is on the segment
    return p.longitude <=
            (p1.longitude > p2.longitude ? p1.longitude : p2.longitude) &&
        p.longitude >=
            (p1.longitude < p2.longitude ? p1.longitude : p2.longitude) &&
        p.latitude <= (p1.latitude > p2.latitude ? p1.latitude : p2.latitude) &&
        p.latitude >= (p1.latitude < p2.latitude ? p1.latitude : p2.latitude);
  }

  void _updatePolygons() {
    if (points.length < 3 || onPolygonUpdated == null) {
      onPolygonUpdated?.call({});
      return;
    }

    final polygonPoints = List<LatLng>.from(points);

    // Choose colors based on sector state and validation state
    final fillColor = _isContourClosed ? closedFillColor : openFillColor;
    final strokeColor = _hasIntersections
        ? errorStrokeColor
        : (_isContourClosed ? closedStrokeColor : openStrokeColor);

    final Set<Polygon> polygons = {
      Polygon(
        polygonId: const PolygonId('edit_polygon'),
        points: polygonPoints,
        fillColor: fillColor,
        strokeColor: strokeColor,
        strokeWidth: strokeWidth,
      ),
    };

    onPolygonUpdated?.call(polygons);
  }

  void edit() {
    _isContourClosed = isContourClosed();
    _validateContour();
    _updateMarkers();
    _updatePolygons();
  }

  bool get isClosed => _isContourClosed;

  bool get hasIntersections => _hasIntersections;
}
