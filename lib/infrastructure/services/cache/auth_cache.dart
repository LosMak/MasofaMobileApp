import 'package:dala_ishchisi/common/constants/app_globals.dart';
import 'package:dala_ishchisi/infrastructure/services/crypt/crypt.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';

import 'cache_service.dart';

@Injectable()
class AuthCache {
  final CacheService _hiveBase;
  final Crypt _crypt;
  late final Box _box;

  AuthCache(this._hiveBase, this._crypt) {
    _box = _hiveBase.authBox;
  }

  String get token {
    if (AppGlobals.token.isEmpty) {
      /// Every api request uses token. So, cached token value
      /// If user logout, clear cache and AppGlobals.token value
      final token = _getValue('token');
      AppGlobals.token = token;
    }
    return AppGlobals.token;
  }

  String get login => _getValue('login');

  String get password => _getValue('password');

  Future<void> setToken(String value) async {
    AppGlobals.token = value;
    await _setValue('token', value);
  }

  Future<void> setLogin(String value) => _setValue('login', value);

  Future<void> setPassword(String value) => _setValue('password', value);

  Future<void> clear() async {
    AppGlobals.token = '';
    _box.clear();
  }

  /// Private methods
  String _getValue(String key) {
    final data = _box.get(key) ?? '';
    return _crypt.decrypt(data) ?? '';
  }

  Future<void> _setValue(String key, String value) async {
    final encrypt = _crypt.encrypt(value);
    await _box.put(key, encrypt);
  }
}
