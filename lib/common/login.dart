import 'dart:async';
import 'dart:io';

import 'package:glutassistantn/common/cookie.dart';
import 'package:http/http.dart';

import '../config.dart';

Future<String> codeCheck(String code) async {
  print("codeCheck...");
  final _url = Uri.http(Global.codeCheckUrl[0], Global.codeCheckUrl[1], {"captchaCode": code});
  var postData = {
    "captchaCode": code,
  };
  try {
    var response = await post(_url, body: postData, headers: {"cookie": mapCookieToString()})
        .timeout(const Duration(seconds: 3));
    String result = "success";
    if (response.body != "true") result = "fail";
    return result;
  } on TimeoutException catch (e) {
    print("getExam Error");
    return Global.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
    return Global.socketError;
  }
}

Future<String> login(String username, String password, String code) async {
  try {
    print("loginJW...");
    var postData = {"j_username": username, "j_password": password, "j_captcha": code};
    var response =
        await post(Global.loginUrl, body: postData, headers: {"cookie": mapCookieToString()})
            .timeout(const Duration(seconds: 3));
    if (response.headers['location'] == "/academic/index_new.jsp") {
      parseRawCookies(response.headers['set-cookie']);
      return "success";
    } else {
      return "fail";
    }
  } on TimeoutException catch (e) {
    print("getExam Error");
    return Global.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
    return Global.socketError;
  }
}
