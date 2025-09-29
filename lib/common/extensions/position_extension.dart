import 'dart:math';

import 'package:dala_ishchisi/domain/models/bid_model.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

extension DistancePosition on Position {
  bool isNear(Position other) => distanceTo(other) <= 1000;

  int distanceTo(Position other) {
    const earthRadius = 6378137.0;

    // Convert degrees to radians
    double lat1Rad = latitude * (pi / 180);
    double lon1Rad = longitude * (pi / 180);
    double lat2Rad = other.latitude * (pi / 180);
    double lon2Rad = other.longitude * (pi / 180);

    // Get differences
    double dLat = lat2Rad - lat1Rad;
    double dLon = lon2Rad - lon1Rad;

    // Haversine formula
    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) * sin(dLon / 2) * sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return (earthRadius * c).round();
  }
}

extension BidPosition on BidModel {
  Position get position => Position(
        latitude: lat,
        longitude: lng,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        altitudeAccuracy: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        headingAccuracy: 0,
      );
}

extension LatLngListSerializable on List<LatLng> {
  /// `[[lat,lng],[lat,lng],...]`
  String toLatLngString() {
    if (isEmpty) return "[]";

    StringBuffer buffer = StringBuffer("[[");

    for (int i = 0; i < length; i++) {
      LatLng point = this[i];
      buffer.write("${point.latitude}, ${point.longitude}");

      if (i < length - 1) {
        buffer.write("], [");
      }
    }

    buffer.write("]]");
    return buffer.toString();
  }
}

extension MyLatLngString on String {
  List<LatLng> toLatLngList() {
    if (isEmpty) return [];

    String cleanedString = trim();
    try {
      if (!cleanedString.startsWith("[[") || !cleanedString.endsWith("]]")) {
        return [];
      }

      cleanedString = cleanedString.substring(2, cleanedString.length - 2);
      if (cleanedString.isEmpty) return [];

      List<String> coordinatePairs = cleanedString.split("], [");
      List<LatLng> result = [];

      for (String pair in coordinatePairs) {
        List<String> values = pair.split(", ");
        if (values.length < 2) continue;

        double? lat = double.tryParse(values[0]);
        double? lng = double.tryParse(values[1]);
        if (lat == null || lng == null) continue;

        result.add(LatLng(lat, lng));
      }

      return result;
    } catch (e) {
      return [];
    }
  }
}
