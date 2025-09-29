import 'package:dala_ishchisi/infrastructure/services/cache/cache_service.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

@Injectable()
class ArchiveCache {
  final CacheService _hiveBase;
  late final Box _box;

  ArchiveCache(this._hiveBase) {
    _box = _hiveBase.archiveBox;
  }
  Future<void> setArchive(String bidId, String value) => _box.put(bidId, value);

  Future<void> setArchives(Map<String, String> archives) async {
    _box.putAll(archives);
  }

  Future<void> deleteArchive(String bidId) => _box.delete(bidId);

  Future<Map<String, String>> getArchives() async {
    final data = Map<String, String>.from(_box.toMap());
    return data;
  }

  Future<String> getArchive(String bidId) async {
    final data = _box.get(bidId) ?? '';
    return data as String;
  }
}
