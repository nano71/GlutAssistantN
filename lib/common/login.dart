import 'dart:async';
import 'dart:io';

import 'package:glutassistantn/common/get.dart';
import 'package:http/http.dart';

import '/common/cookie.dart';
import '../config.dart';
import 'encode.dart';

Future<String> checkCaptcha(String code) async {
  print("checkCaptcha");
  final _url = Uri.http(AppConfig.serverHost, AppConfig.captchaCheckPath, {"captchaCode": code});
  var postData = {
    "captchaCode": code,
  };
  try {
    var response =
        await post(_url, body: postData, headers: {"cookie": mapCookieToString()}).timeout(Duration(seconds: 3));
    String result = "success";
    if (response.body != "true") result = "fail";
    print('checkCaptcha End');
    return result;
  } on TimeoutException catch (e) {
    print("getExam Error");
    print(e);
    return AppConfig.timeoutErrorMessage;
  } on SocketException catch (e) {
    print("getExam Error 2");
    print(e);
    return AppConfig.networkErrorMessage;
  } catch (e) {
    print("getExam Error 3");
    print(e);
    return "未知异常";
  }
}

Future<String> login(String studentId, String password, String code) async {
  try {
    print("login");
    var postData = {"j_username": studentId, "j_password": submitHexMd5(password), "j_captcha": code};
    var response = await post(AppConfig.loginUri, body: postData, headers: {"cookie": mapCookieToString()})
        .timeout(Duration(seconds: 3));
    print('login End');
    if (response.headers['location'] == "/academic/index_new.jsp") {
      await parseRawCookies(response.headers['set-cookie']);
      await getWeek();
      return "success";
    } else {
      return "fail";
    }
  } on TimeoutException catch (e) {
    print("login Error");
    print(e);
    return AppConfig.timeoutErrorMessage;
  } on SocketException catch (e) {
    print("login Error 2");
    print(e);
    return AppConfig.networkErrorMessage;
  }
}
