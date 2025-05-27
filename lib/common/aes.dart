import 'package:encrypt/encrypt.dart';


class AESHelper {
  static const String _DSN = String.fromEnvironment('SENTRY_DSN');
  static final _key = Key.fromUtf8(_DSN.substring(_DSN.length - 16));
  static final _iv = IV.fromUtf8("1234567890abcdef");
  static final _encrypter = Encrypter(AES(_key, mode: AESMode.cbc));

  /// 加密明文为 Base64 字符串
  static String encryptText(String plainText) {
    final encrypted = _encrypter.encrypt(plainText, iv: _iv);
    return encrypted.base64;
  }

  /// 解密 Base64 密文为明文
  static String decryptText(String base64Encrypted) {
    final encrypted = Encrypted.fromBase64(base64Encrypted);
    return _encrypter.decrypt(encrypted, iv: _iv);
  }
}
