import '/config.dart';

import 'io.dart';

String mapCookieToString() {
  String result = '';
  AppConfig.cookie.forEach((key, value) {
    result += '$key=$value; ';
  });
  return result;
}

//
Future<void> parseRawCookies(dynamic rawCookie) async {
  for (var item in rawCookie.split(',')) {
    List<String> cookie = item.split(';')[0].split('=');
    AppConfig.cookie[cookie[0]] = cookie[1];
    await writeCookie();
  }
  return await writeConfig();
}
