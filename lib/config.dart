import 'package:flutter/material.dart';

import 'data.dart';

class AppConfig {
  static String appTitle = "桂工助手N";
  static bool login = false;
  static int pageIndex = 0;
  static PageController pageControl = PageController(
    initialPage: 0,
    keepPage: true,
  );
  static String timeOutError = "教务无响应!";
  static String socketError = "网络错误!";
  static String dataError = "教务未知错误!";
  static String notLoginError = "请先登录!";
  static String retryError = "未知错误,请重试!";
  static int timeOutSec = 12;
  static double listLeftIconSize = 18;
  static Map cookie = {};
  static String jwUrl = "jw.glutnn.cn";
  static String authorUrl = "nano71.com";
  static String controlUrl = "/gan/control.json";
  static String updateApiUrl = "api.github.com";
  static Uri getCodeUrl = httpUri("/academic/getCaptcha.do");
  static Uri loginUrl = httpUri("/academic/j_acegi_security_check");
  static Uri loginUrl2 = httpUri("/academic/index_new.jsp");
  static Uri getWeekUrl = httpUri("/academic/listLeft.do");
  static String getRecentExam = "/academic/student/exam/index.jsdo";
  static Uri getExamUrl = httpUri("/academic/manager/examstu/studentQueryAllExam.do");
  static Uri getNameUrl = httpUri("/academic/student/studentinfo/studentInfoModifyIndex.do", {"frombase": "0", "wantTag": "0"});
  static Uri getScoreUrl = httpUri("/academic/manager/score/studentOwnScore.do");
  static Uri getCareerUrl = httpUri("/academic/manager/studyschedule/studentSelfSchedule.jsdo");
  static Uri getUpdateUrl = Uri.https(updateApiUrl, "/repos/nano71/GlutAssistantN/releases/latest");
  static Uri getUpdateUrl2 = Uri.https(authorUrl, "/gan/check");
  static Uri getEmptyClassroomUrl = httpUri("/academic/teacher/teachresource/roomschedulequery.jsdo");
  static Uri getEmptyClassroomUrl2 = httpUri("/academic/teacher/teachresource/roomschedule_week.jsdo");
  static List<String> getScheduleUrl = [jwUrl, "/academic/student/currcourse/currcourse.jsdo"];
  static List<String> getScheduleNextUrl = [jwUrl, "/academic/manager/coursearrange/showTimetable.do"];
  static List<String> codeCheckUrl = [jwUrl, "/academic/checkCaptcha.do"];
  static Uri checkLoginValidityUri = httpUri("/academic/showPersonalInfo.do");
  static double schedulePageTouchMovesMinValue = 70.0;
  static double schedulePageGridHeight = 60.0;
  static String careerErrorText = "用户名不能为空";
  static String examErrorText = "<title>提示信息</title>";
  static String scheduleErrorText = "j_username";
  static String reLoginErrorText = "请重新登录";
}

Uri httpUri(
  path, [
  Map<String, dynamic>? queryParameters,
]) {
  return Uri.http(AppConfig.jwUrl, path, queryParameters);
}

readBackgroundColor() {
  if (AppData.persistentData["color"] == "dark") {
    return Color(0xFF101014);
  }
  return Color(0xFFFAFAFA);
}

readTextColor() {
  if (AppData.persistentData["color"] == "dark") {
    return Colors.white;
  }
  return Colors.black;
}

readArrowIconColor() {
  if (AppData.persistentData["color"] == "dark") {
    return Colors.white60;
  }
  return Colors.black26;
}

readCardBackgroundColor() {
  if (AppData.persistentData["color"] == "dark") {
    return Color(0xFF18181c);
  }
  return Colors.white;
}

List<String> colorTexts = ["dark", "purple", "red", "pink", "blue", "cyan", "yellow"];

LinearGradient readGradient() {
  switch (AppData.persistentData["color"]) {
    case "purple":
      return setTemplate([Color(0xfff0abfc), Color(0xff4f46e5)]);
    case "red":
      return setTemplate([Color(0xFFfbab66), Color(0xFFf7418c)]);
    case "pink":
      return setTemplate([Color(0xfff0abfc), Color(0xff4f46e5)]);
    case "blue":
      return setTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
    case "yellow":
      return setTemplate([Color(0xfffbef66), Color(0xfff7a841)]);
    case "cyan":
      return setTemplate([Color(0xff66fbce), Color(0xff16bbb4)]);
    default:
      return setTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
  }
}

readColor([String? color]) {
  color ??= AppData.persistentData["color"];

  switch (color) {
    case "dark":
      return Color(0xFF06f7a1);
    case "purple":
      return Colors.deepPurpleAccent;
    case "red":
      return Colors.pinkAccent;
    case "pink":
      return Colors.pinkAccent;
    case "blue":
      return Colors.blue;
    case "yellow":
      return Color(0xFFFFC107);
    case "cyan":
      return Colors.cyan[600];
    default:
      return Colors.blue;
  }
}

LinearGradient readCardGradient() {
  switch (AppData.persistentData["color"]) {
    case "purple":
      return setCardTemplate([Color(0xffd978ff), Color(0xFF8a41f7)]);
    case "red":
      return setCardTemplate([Color(0xFFfbab66), Color(0xFFf7418c)]);
    case "pink":
      return setCardTemplate([Color(0xfff479dc), Color(0xffff60cd)]);
    case "blue":
      return setCardTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
    case "yellow":
      return setCardTemplate([Color(0xfffbef66), Color(0xfff7a841)]);
    case "cyan":
      return setCardTemplate([Color(0xff66fbce), Color(0xff16bbb4)]);
    default:
      return setCardTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
  }
}

LinearGradient readCardGradient2() {
  switch (AppData.persistentData["color"]) {
    case "purple":
      return setCardTemplate2([Color(0x12AE66FB), Color(0x4E8A41F7)]);
    case "red":
      return setCardTemplate2([Color(0x12fbab66), Color(0x4Ef7418c)]);
    case "pink":
      return setCardTemplate2([Color(0x12f479dc), Color(0x4Eff60cd)]);
    case "blue":
      return setCardTemplate2([Color(0x1266cefb), Color(0x4E419bff)]);
    case "yellow":
      return setCardTemplate2([Color(0x12fbef66), Color(0x4Ef7a841)]);
    case "cyan":
      return setCardTemplate2([Color(0x1266fbce), Color(0x4E16bbb4)]);
    default:
      return setCardTemplate2([Color(0x1266cefb), Color(0x4E419bff)]);
  }
}

Color readColorBegin() {
  switch (AppData.persistentData["color"]) {
    case "dark":
      return Color(0x1a029cde);
    case "purple":
      return Color(0x2adbcfff);
    case "red":
    case "pink":
      // A=42, R=255, G=229, B=253
      return Color(0x2AFAD4F8);

    case "blue":
      // A=42, R=199, G=229, B=253
      return Color(0x2AC7E5FD);

    case "yellow":
      // A=42, R=253, G=249, B=199
      return Color(0x2AFFF76C);

    case "cyan":
      // A=42, R=199, G=251, B=253
      return Color(0x2AC7FBFD);

    default:
      return Color(0x2AC7E5FD);
  }
}

Color readColorEnd() {
  switch (AppData.persistentData["color"]) {
    case "purple":
      return Color(0x6ECFBCFD);
    case "red":
      // A=110, R=253, G=199, B=199
      return Color(0x6EFDC7C7);
    case "pink":
      // A=110, R=253, G=199, B=228
      return Color(0x6EFDC7E4);
    case "blue":
      // A=110, R=199, G=229, B=253
      return Color(0x6EC7E5FD);
    case "yellow":
      // A=110, R=253, G=246, B=199
      return Color(0x6EFDF6C7);
    case "cyan":
      // A=110, R=199, G=251, B=253
      return Color(0x6EC7FBFD);
    default:
      return Color(0x6EC7E5FD);
  }
}

LinearGradient setCardTemplate(List<Color> colors) {
  return LinearGradient(
    colors: colors,
    begin: Alignment.centerLeft,
    end: Alignment.topRight,
  );
}

LinearGradient setCardTemplate2(List<Color> colors) {
  return LinearGradient(
    colors: colors,
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
}

LinearGradient setTemplate(List<Color> colors) {
  return LinearGradient(
    colors: colors,
    begin: Alignment.topLeft,
    end: Alignment.centerRight,
  );
}
