import 'dart:math';

import 'package:dala_ishchisi/domain/models/polygon_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class LocationService {
  const LocationService();

  Future<bool> requestPermission() async {
    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.always ||
        permission == LocationPermission.whileInUse) {
      return true;
    }
    return false;
  }

  Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }

  Stream<Position> position() => Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          distanceFilter: 2,
        ),
      );

  bool isInCounter(PolygonModel polygon, Position position) {
    for (var polygonCoords in polygon.coordinates) {
      for (var ring in polygonCoords) {
        if (_PointInsidePolygon(position: position, polygon: ring).check()) {
          return true;
        }
      }
    }
    return false;
  }

  double? calculateDistance(PolygonModel polygon, Position position) {
    final list = <double>[];
    for (var polygonCoords in polygon.coordinates) {
      for (var ring in polygonCoords) {
        list.add(
          _PointDistancePolygon(position: position, polygon: ring)
              .nearestDistance(),
        );
      }
    }
    if (list.isNotEmpty) return list.reduce(min);
    return null;
  }
}

class _PointInsidePolygon {
  final Position position;
  final List<({double lng, double lat})> polygon;

  const _PointInsidePolygon({
    required this.position,
    required this.polygon,
  });

  bool check() {
    int intersections = 0;

    // Loop through each edge of the polygon
    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      // Check if the line segment crosses the ray
      if (_rayIntersectsSegment(
          position.latitude, position.longitude, p1, p2)) {
        intersections++;
      }
    }

    // If intersections are odd, the point is inside the polygon
    return (intersections % 2 == 1);
  }

  // Helper method to check if a ray from (lat, lng) intersects with the edge (p1, p2)
  bool _rayIntersectsSegment(
    double lat,
    double lng,
    ({double lng, double lat}) p1,
    ({double lng, double lat}) p2,
  ) {
    final double lat1 = p1.lat;
    final double lng1 = p1.lng;
    final double lat2 = p2.lat;
    final double lng2 = p2.lng;

    if ((lat1 > lat) != (lat2 > lat)) {
      final double intersectionLng =
          lng1 + (lat - lat1) * (lng2 - lng1) / (lat2 - lat1);
      if (lng < intersectionLng) {
        return true;
      }
    }
    return false;
  }
}

class _PointDistancePolygon {
  static const double earthRadius = 6371000;
  final Position position;
  final List<({double lng, double lat})> polygon;

  const _PointDistancePolygon({required this.position, required this.polygon});

  // Method to calculate the nearest distance from a point to a polygon in meters
  double nearestDistance() {
    double minDistance = double.infinity;

    // Loop through each edge of the polygon
    for (int i = 0; i < polygon.length; i++) {
      final p1 = polygon[i];
      final p2 = polygon[(i + 1) % polygon.length];

      // Calculate the distance from the point to the current edge
      double distance = _distanceToSegment(
        position.latitude,
        position.longitude,
        p1.lat,
        p1.lng,
        p2.lat,
        p2.lng,
      );
      minDistance = min(minDistance, distance);
    }

    return minDistance;
  }

  // Method to calculate the distance between two geographic points using the Haversine formula
  double _haversineDistance(
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    double dLat = _degreesToRadians(lat2 - lat1);
    double dLng = _degreesToRadians(lng2 - lng1);
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_degreesToRadians(lat1)) *
            cos(_degreesToRadians(lat2)) *
            sin(dLng / 2) *
            sin(dLng / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  // Helper method to calculate the shortest distance from a point to a line segment
  double _distanceToSegment(
    double lat,
    double lng,
    double lat1,
    double lng1,
    double lat2,
    double lng2,
  ) {
    double distanceToStart = _haversineDistance(lat, lng, lat1, lng1);
    double distanceToEnd = _haversineDistance(lat, lng, lat2, lng2);

    // Project the point onto the line (lat1, lng1) - (lat2, lng2)
    double projection = _projectionFactor(lat, lng, lat1, lng1, lat2, lng2);

    if (projection < 0) {
      // Closest point is p1
      return distanceToStart;
    } else if (projection > 1) {
      // Closest point is p2
      return distanceToEnd;
    } else {
      // Closest point is somewhere along the segment
      double latProjection = lat1 + projection * (lat2 - lat1);
      double lngProjection = lng1 + projection * (lng2 - lng1);
      return _haversineDistance(lat, lng, latProjection, lngProjection);
    }
  }

  // Helper method to calculate the projection factor of the point onto the line segment
  double _projectionFactor(double lat, double lng, double lat1, double lng1,
      double lat2, double lng2) {
    double dLat = lat2 - lat1;
    double dLng = lng2 - lng1;
    if (dLat == 0 && dLng == 0) return 0.0; // p1 and p2 are the same point

    double projection = ((lat - lat1) * dLat + (lng - lng1) * dLng) /
        (dLat * dLat + dLng * dLng);
    return projection;
  }

  // Helper method to convert degrees to radians
  double _degreesToRadians(double degrees) => degrees * pi / 180;
}
