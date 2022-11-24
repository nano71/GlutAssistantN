import 'package:flutter/material.dart';
import 'package:glutassistantn/widget/lists.dart';

import 'data.dart';

class Global {
  static String appTitle = "桂工助手N";
  static bool login = false;
  static int pageIndex = 0;
  static final GlobalKey<TodayCourseListState> todayCourseListKey = GlobalKey();
  static final GlobalKey<TomorrowCourseListState> tomorrowCourseListKey = GlobalKey();
  static PageController pageControl = PageController(
    initialPage: 0,
    keepPage: true,
  );
  static String timeOutError = "教务无响应!";
  static String socketError = "网络错误!";
  static int timeOutSec = 12;
  static double listLeftIconSize = 18;
  static Map cookie = {};
  static String jwUrl = "jw.glutnn.cn";
  static String updateApiUrl = "api.github.com";
  static Uri getCodeUrl = httpUri("/academic/getCaptcha.do");
  static Uri loginUrl = httpUri("/academic/j_acegi_security_check");
  static Uri loginUrl2 = httpUri("/academic/index_new.jsp");
  static Uri getWeekUrl = httpUri("/academic/listLeft.do");
  static Uri getExamUrl = httpUri("/academic/manager/examstu/studentQueryAllExam.do");
  static Uri getNameUrl = httpUri("/academic/student/studentinfo/studentInfoModifyIndex.do", {"frombase": "0", "wantTag": "0"});
  static Uri getScoreUrl = httpUri("/academic/manager/score/studentOwnScore.do");
  static Uri getCareerUrl = httpUri("/academic/manager/studyschedule/studentSelfSchedule.jsdo");
  static Uri getUpdateUrl = Uri.http(updateApiUrl, "/repos/nano71/GlutAssistantN/releases/latest");
  static Uri getEmptyClassroomUrl = httpUri("/academic/teacher/teachresource/roomschedulequery.jsdo");
  static Uri getEmptyClassroomUrl2 = httpUri("/academic/teacher/teachresource/roomschedule_week.jsdo");
  static List<String> getScheduleUrl = [jwUrl, "/academic/student/currcourse/currcourse.jsdo"];
  static List<String> getScheduleNextUrl = [jwUrl, "/academic/manager/coursearrange/showTimetable.do"];
  static List<String> codeCheckUrl = [jwUrl, "/academic/checkCaptcha.do"];
  static double schedulePageTouchMovesMinValue = 70.0;
  static double schedulePageGridHeight = 60.0;
  static String careerErrorText = "用户名不能为空！";
  static String examErrorText = "<title>提示信息</title>";
  static String scheduleErrorText = "j_username";
}

Uri httpUri(
  path, [
  Map<String, dynamic>? queryParameters,
]) {
  return Uri.http(Global.jwUrl, path, queryParameters);
}

LinearGradient readGradient() {
  if (writeData["color"] == "red") {
    return LinearGradient(
      colors: [Color(0xFFfbab66), Color(0xFFf7418c)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else if (writeData["color"] == "pink") {
    return LinearGradient(
      colors: [Color(0xffeca299), Color(0xfffc6caa)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else if (writeData["color"] == "blue") {
    return LinearGradient(
      colors: [Color(0xff66cefb), Color(0xff4175f7)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else if (writeData["color"] == "yellow") {
    return LinearGradient(
      colors: [Color(0xfffbef66), Color(0xfff7a841)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else if (writeData["color"] == "cyan") {
    return LinearGradient(
      colors: [Color(0xff66fbce), Color(0xff16bbb4)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else {
    return LinearGradient(
      colors: [Color(0xff66cefb), Color(0xff4175f7)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  }
}

readColor() {
  if (writeData["color"] == "blue") {
    return Colors.blue;
  } else if (writeData["color"] == "pink") {
    return Colors.pinkAccent[100];
  } else if (writeData["color"] == "red") {
    return Colors.redAccent;
  } else if (writeData["color"] == "yellow") {
    return Colors.yellow[600];
  } else if (writeData["color"] == "cyan") {
    return Colors.cyan[400];
  } else {
    return Colors.blue;
  }
}

LinearGradient readCardGradient() {
  if (writeData["color"] == "red") {
    return setTemplate([Color(0xFFfbab66), Color(0xFFf7418c)]);
  } else if (writeData["color"] == "pink") {
    return setTemplate([Color(0xffeca299), Color(0xfffc6caa)]);
  } else if (writeData["color"] == "blue") {
    return setTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
  } else if (writeData["color"] == "yellow") {
    return setTemplate([Color(0xfffbef66), Color(0xfff7a841)]);
  } else if (writeData["color"] == "cyan") {
    return setTemplate([Color(0xff66fbce), Color(0xff16bbb4)]);
  } else {
    return setTemplate([Color(0xff66cefb), Color(0xff4175f7)]);
  }
}

Color readColorBegin() {
  if (writeData["color"] == "red" || writeData["color"] == "pink") {
    return Color.fromARGB(42, 255, 229, 253);
  } else if (writeData["color"] == "blue") {
    return Color.fromARGB(42, 199, 229, 253);
  } else if (writeData["color"] == "yellow") {
    return Color.fromARGB(42, 253, 249, 199);
  } else if (writeData["color"] == "cyan") {
    return Color.fromARGB(42, 199, 251, 253);
  } else {
    return Color.fromARGB(42, 199, 229, 253);
  }
}

Color readColorEnd() {
  if (writeData["color"] == "red") {
    return Color.fromARGB(110, 253, 199, 199);
  } else if (writeData["color"] == "pink") {
    return Color.fromARGB(110, 253, 199, 228);
  } else if (writeData["color"] == "blue") {
    return Color.fromARGB(110, 199, 229, 253);
  } else if (writeData["color"] == "yellow") {
    return Color.fromARGB(110, 253, 246, 199);
  } else if (writeData["color"] == "cyan") {
    return Color.fromARGB(110, 199, 251, 253);
  } else {
    return Color.fromARGB(110, 199, 229, 253);
  }
}

LinearGradient setTemplate(List<Color> colors) {
  return LinearGradient(
    colors: colors,
    begin: Alignment.topRight,
    end: Alignment.bottomCenter,
  );
}
