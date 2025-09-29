import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

/// These services are used to manage cache[auth, language, theme]
///
/// Examples:
/// ```dart
/// final value = di<AuthCacheService>().token;
/// await di<AuthCacheService>().setToken(token);
/// final value = di<LanguageService>().locale;
/// ```
@Singleton()
class CacheService {
  late Box _authBox;
  late Box _appBox;
  late Box _locationBox;
  late Box _regionBox;
  late Box _archiveBox;

  @PostConstruct(preResolve: true)
  Future<void> init() async {
    if (kIsWeb) {
      Hive.init('/');
    } else {
      Hive.init((await getTemporaryDirectory()).path);
    }
    _authBox = await Hive.openBox('auth');
    _appBox = await Hive.openBox('app');
    _locationBox = await Hive.openBox('location');
    _regionBox = await Hive.openBox('region');
    _archiveBox = await Hive.openBox('archive');
  }

  Box get authBox => _authBox;

  Box get appBox => _appBox;

  Box get locationBox => _locationBox;

  Box get regionBox => _regionBox;

  Box get archiveBox => _archiveBox;
}
