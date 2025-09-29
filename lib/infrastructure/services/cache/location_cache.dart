import 'dart:convert';

import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'cache_service.dart';

@Injectable()
class LocationCache {
  final CacheService _hiveBase;
  late final Box _box;

  LocationCache(this._hiveBase) {
    _box = _hiveBase.locationBox;
  }

  List<Position> get locations {
    return _box.values.map((e) => Position.fromMap(jsonDecode(e))).toList();
  }

  Future<void> addLocation(
    Position? location, {
    bool checkMinUpdateInterval = true,
  }) async {
    if (location == null) return;

    const maxLocationsCount = 2000;
    const deleteOldItemsCount = 1000;
    const minLocationUpdateInterval = Duration(seconds: 5);

    if (checkMinUpdateInterval && _box.values.isNotEmpty) {
      final lastLocation = Position.fromMap(jsonDecode(_box.values.last));
      final timeDifference = DateTime.now().difference(
        DateTime.fromMillisecondsSinceEpoch(
          lastLocation.timestamp.millisecondsSinceEpoch,
        ),
      );

      if (timeDifference < minLocationUpdateInterval) {
        return;
      }
    }

    if (_box.values.length >= maxLocationsCount) {
      // delete old items
      for (int i = 0; i < deleteOldItemsCount; i++) {
        await _box.deleteAt(0); // delete the first item
      }
    }

    final str = jsonEncode(location.toJson());
    await _box.add(str);
  }
}
