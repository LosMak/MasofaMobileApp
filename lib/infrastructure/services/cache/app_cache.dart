import 'dart:convert';

import 'package:dala_ishchisi/domain/models/template_model.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'cache_service.dart';

@Injectable()
class AppCache {
  final CacheService _hiveBase;
  late final Box _box;

  AppCache(this._hiveBase) {
    _box = _hiveBase.appBox;
  }

  String get locale => _box.get('locale') ?? '';

  TemplateModel template(String bidId) {
    final string = _box.get("bid:$bidId") ?? '{}';
    return TemplateModel.fromJson(jsonDecode(string));
  }

  Future<void> setLocale(String locale) => _box.put('locale', locale);

  Future<void> setTemplate(String bidId, TemplateModel template) =>
      _box.put("bid:$bidId", jsonEncode(template.toJson()));

  Future<void> deleteTemplate(String bidId) => _box.delete("bid:$bidId");
}
