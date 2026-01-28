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

Uri httpUri(path, [
  Map<String, dynamic>? queryParameters,
]) {
  return Uri.http(AppConfig.jwUrl, path, queryParameters);
}

LinearGradient readGradient() {
  if (AppData.persistentData["color"] == "red") {
    return setCardTemplate([Color(0xFFfbab66), Color(0xFFf7418c)]);
  } else if (AppData.persistentData["color"] == "pink") {
    return setCardTemplate([Color(0xffeca299), Color(0xfffc6caa)]);
  } else if (AppData.persistentData["color"] == "blue") {
    return setCardTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
  } else if (AppData.persistentData["color"] == "yellow") {
    return setCardTemplate([Color(0xfffbef66), Color(0xfff7a841)]);
  } else if (AppData.persistentData["color"] == "cyan") {
    return setCardTemplate([Color(0xff66fbce), Color(0xff16bbb4)]);
  } else {
    return setCardTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
  }
}

readColor() {
  if (AppData.persistentData["color"] == "blue") {
    return Colors.blue;
  } else if (AppData.persistentData["color"] == "pink") {
    return Colors.pink[300];
  } else if (AppData.persistentData["color"] == "red") {
    return Colors.redAccent;
  } else if (AppData.persistentData["color"] == "yellow") {
    return Color(0xFFFFC107);
  } else if (AppData.persistentData["color"] == "cyan") {
    return Colors.cyan[600];
  } else {
    return Colors.blue;
  }
}

readBackgroundColor() {
  return Color(0xFFFBFBFB);
}

readCardBackgroundColor(){
  return Colors.white;

}

LinearGradient readCardGradient() {
  if (AppData.persistentData["color"] == "red") {
    return setCardTemplate([Color(0xFFfbab66), Color(0xFFf7418c)]);
  } else if (AppData.persistentData["color"] == "pink") {
    return setCardTemplate([Color(0xffeca299), Color(0xfffc6caa)]);
  } else if (AppData.persistentData["color"] == "blue") {
    return setCardTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
  } else if (AppData.persistentData["color"] == "yellow") {
    return setCardTemplate([Color(0xfffbef66), Color(0xfff7a841)]);
  } else if (AppData.persistentData["color"] == "cyan") {
    return setCardTemplate([Color(0xff66fbce), Color(0xff16bbb4)]);
  } else {
    return setCardTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
  }
}

Color readColorBegin() {
  if (AppData.persistentData["color"] == "red" || AppData.persistentData["color"] == "pink") {
    return Color.fromARGB(42, 255, 229, 253);
  } else if (AppData.persistentData["color"] == "blue") {
    return Color.fromARGB(42, 199, 229, 253);
  } else if (AppData.persistentData["color"] == "yellow") {
    return Color.fromARGB(42, 253, 249, 199);
  } else if (AppData.persistentData["color"] == "cyan") {
    return Color.fromARGB(42, 199, 251, 253);
  } else {
    return Color.fromARGB(42, 199, 229, 253);
  }
}

Color readColorEnd() {
  if (AppData.persistentData["color"] == "red") {
    return Color.fromARGB(110, 253, 199, 199);
  } else if (AppData.persistentData["color"] == "pink") {
    return Color.fromARGB(110, 253, 199, 228);
  } else if (AppData.persistentData["color"] == "blue") {
    return Color.fromARGB(110, 199, 229, 253);
  } else if (AppData.persistentData["color"] == "yellow") {
    return Color.fromARGB(110, 253, 246, 199);
  } else if (AppData.persistentData["color"] == "cyan") {
    return Color.fromARGB(110, 199, 251, 253);
  } else {
    return Color.fromARGB(110, 199, 229, 253);
  }
}

LinearGradient setCardTemplate(List<Color> colors) {
  return LinearGradient(
    colors: colors,
    begin: Alignment.centerLeft,
    end: Alignment.topRight,
  );
}

LinearGradient setTemplate(List<Color> colors) {
  return LinearGradient(
    colors: colors,
    begin: Alignment.centerLeft,
    end: Alignment.topRight,
  );
}
