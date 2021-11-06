import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Global {
  static String appTitle = "桂工助手";
  static bool logined = false;
  static int pageIndex = 0;
  static PageController pageControl = PageController(
    initialPage: 0,
    keepPage: true,
  );
  static Map<String, String> cookie = {};
  static String jwUrl = "jw.glutnn.cn";
  static Uri getCodeUrl = Uri.http(jwUrl, "/academic/getCaptcha.do");
  static Uri loginUrl = Uri.http(jwUrl, "/academic/j_acegi_security_check");
  static Uri loginUrl2 = Uri.http(jwUrl, "/academic/index_new.jsp");
  static Uri getWeekUrl = Uri.http(jwUrl, "/academic/listLeft.do");
  static Uri getScoreUrl = Uri.http(jwUrl, "/academic/manager/score/studentOwnScore.do");
  static List<String> getScheduleUrl = [jwUrl, "/academic/student/currcourse/currcourse.jsdo"];
  static List<String> codeCheckUrl = [jwUrl, "/academic/checkCaptcha.do"];

}
