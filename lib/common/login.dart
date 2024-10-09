import 'dart:async';
import 'dart:io';

import 'package:glutassistantn/common/get.dart';

import '/common/cookie.dart';
import 'package:http/http.dart';

import '../config.dart';
import 'encode.dart';

Future<String> codeCheck(String code) async {
  print("codeCheck...");
  final _url = Uri.http(AppConfig.codeCheckUrl[0], AppConfig.codeCheckUrl[1], {"captchaCode": code});
  var postData = {
    "captchaCode": code,
  };
  try {
    var response = await post(_url, body: postData, headers: {"cookie": mapCookieToString()}).timeout(Duration(seconds: 3));
    String result = "success";
    if (response.body != "true") result = "fail";
    return result;
  } on TimeoutException catch (e) {
    print("getExam Error");
    print(e);
    return AppConfig.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
    print(e);
    return AppConfig.socketError;
  }
}

Future<String> login(String username, String password, String code) async {
  try {
    print("loginJW...");
    var postData = {"j_username": username, "j_password": submitHexMd5(password), "j_captcha": code};
    var response = await post(AppConfig.loginUrl, body: postData, headers: {"cookie": mapCookieToString()}).timeout(Duration(seconds: 3));
    if (response.headers['location'] == "/academic/index_new.jsp") {
      await parseRawCookies(response.headers['set-cookie']);
      await getWeek();
      return "success";
    } else {
      return "fail";
    }
  } on TimeoutException catch (e) {
    print("getExam Error");
    print(e);
    return AppConfig.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
    print(e);
    return AppConfig.socketError;
  }
}
