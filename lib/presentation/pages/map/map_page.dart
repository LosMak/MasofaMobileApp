import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:map_launcher/map_launcher.dart';

import 'map_view.dart';

class Location {
  final double lat;
  final double long;

  const Location({required this.lat, required this.long});
}

@RoutePage()
class MapPage extends StatelessWidget {
  final String title;
  final Location location;
  final String regionId;

  const MapPage({
    super.key,
    required this.title,
    required this.location,
    required this.regionId,
  });

  @override
  Widget build(BuildContext context) => MapView(
        title,
        Coords(location.lat, location.long),
        regionId,
      );
}
