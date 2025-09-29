import 'package:encrypt/encrypt.dart';
import 'package:injectable/injectable.dart';

@Singleton()
class Crypt {
  final String _secretKey = "created_by_abbos2101_bobomurodov";
  late final _key = Key.fromUtf8(_secretKey);
  late final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  String encrypt(String data) {
    final randomIv = IV.fromSecureRandom(16);
    final encrypted = _encrypter.encrypt(data, iv: randomIv);
    return '${randomIv.base64}:${encrypted.base64}';
  }

  String? decrypt(String data) {
    final parts = data.split(':');
    if (parts.length != 2) return null;

    final iv = IV.fromBase64(parts[0]);
    final encrypted = Encrypted.fromBase64(parts[1]);
    try {
      return _encrypter.decrypt(encrypted, iv: iv);
    } catch (_) {
      return null;
    }
  }
}
