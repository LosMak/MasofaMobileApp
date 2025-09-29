import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class DragMarkerController {
  final Map<String, Marker> _markers = {};

  Set<Marker> get markers => _markers.values.toSet();

  void add(String id, Marker marker) => _markers[id] = marker;

  void remove(String id) => _markers.remove(id);

  void clear() => _markers.clear();

  void update(String id, Marker Function(Marker) updater) {
    final marker = _markers[id];
    if (marker != null) {
      _markers[id] = updater(marker);
    }
  }
}
