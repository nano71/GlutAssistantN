import 'package:glutassistantn/config.dart';

String mapCookieToString() {
  String result = '';
  Global.cookie.forEach((key, value) {
    result += '$key=$value; ';
  });
  return result;
}
//
void parseRawCookies(dynamic rawCookie) {
  for (var item in rawCookie.split(',')) {
    List<String> cookie = item.split(';')[0].split('=');
    Global.cookie[cookie[0]] = cookie[1];
  }
}
