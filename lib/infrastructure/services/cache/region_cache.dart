import 'package:dala_ishchisi/infrastructure/services/cache/cache_service.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class RegionCache {
  final CacheService _hiveBase;
  late final Box _box;

  RegionCache(this._hiveBase) {
    _box = _hiveBase.regionBox;
  }
  Future<void> setRegion(String regionId, String region) =>
      _box.put(regionId, region);

  Future<void> setRegions(Map<String, String> regions) async {
    _box.putAll(regions);
  }

  Future<void> deleteRegion(String regionId) => _box.delete(regionId);

  Future<Map<String, String>> getRegions() async {
    final data = Map<String, String>.from(_box.toMap());
    return data;
  }

  Future<String> getRegion(String regionId) async {
    final data = _box.get(regionId) ?? '';
    return data as String;
  }
}
