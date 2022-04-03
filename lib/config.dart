import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'data.dart';

class Global {
  static String appTitle = "桂工助手N";
  static bool login = false;
  static int pageIndex = 0;
  static PageController pageControl = PageController(
    initialPage: 0,
    keepPage: true,
  );
  static String timeOutError = "教务无响应!";
  static String socketError = "网络错误!";
  static int timeOutSec = 12;
  static Map<String, String> cookie = {};
  static String jwUrl = "jw.glutnn.cn";
  static String updateApiUrl = "api.github.com";
  static Uri getCodeUrl = Uri.http(jwUrl, "/academic/getCaptcha.do");
  static Uri loginUrl = Uri.http(jwUrl, "/academic/j_acegi_security_check");
  static Uri loginUrl2 = Uri.http(jwUrl, "/academic/index_new.jsp");
  static Uri getWeekUrl = Uri.http(jwUrl, "/academic/listLeft.do");
  static Uri getExamUrl = Uri.http(jwUrl, "/academic/manager/examstu/studentQueryAllExam.do");
  static Uri getNameUrl = Uri.http(jwUrl, "/academic/student/studentinfo/studentInfoModifyIndex.do",
      {"frombase": "0", "wantTag": "0"});
  static Uri getScoreUrl = Uri.http(jwUrl, "/academic/manager/score/studentOwnScore.do");
  static Uri getCareerUrl =
      Uri.http(jwUrl, "/academic/manager/studyschedule/studentSelfSchedule.jsdo");
  static Uri getUpdateUrl =
      Uri.http(updateApiUrl, "/repos/nano71/GlutAssistantN/releases/latest");
  static List<String> getScheduleUrl = [jwUrl, "/academic/student/currcourse/currcourse.jsdo"];
  static List<String> getScheduleNextUrl = [jwUrl, "/academic/manager/coursearrange/showTimetable.do"];
  static List<String> codeCheckUrl = [jwUrl, "/academic/checkCaptcha.do"];
  static double schedulePageTouchMovesMinValue = 70.0;
  static double schedulePageGridHeight = 60.0;
}

LinearGradient readGradient() {
  if (writeData["color"] == "red") {
    return const LinearGradient(
      colors: [Color(0xFFfbab66), Color(0xFFf7418c)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else if (writeData["color"] == "pink") {
    return const LinearGradient(
      colors: [Color(0xffeca299), Color(0xfffc6caa)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  }else if (writeData["color"] == "blue") {
    return const LinearGradient(
      colors: [Color(0xff66cefb), Color(0xff4175f7)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else if (writeData["color"] == "yellow") {
    return const LinearGradient(
      colors: [Color(0xfffbef66), Color(0xfff7a841)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else if (writeData["color"] == "cyan") {
    return const LinearGradient(
      colors: [Color(0xff66fbce), Color(0xff16bbb4)],
      begin: Alignment.centerLeft,
      end: Alignment.topRight,
    );
  } else {
    return const LinearGradient(
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

Color readColorBegin() {
  if (writeData["color"] == "red"||writeData["color"] == "pink") {
    return const Color.fromARGB(42, 255, 229, 253);
  } else if (writeData["color"] == "blue") {
    return const Color.fromARGB(42, 199, 229, 253);
  } else if (writeData["color"] == "yellow") {
    return const Color.fromARGB(42, 253, 249, 199);
  } else if (writeData["color"] == "cyan") {
    return const Color.fromARGB(42, 199, 251, 253);
  } else {
    return const Color.fromARGB(42, 199, 229, 253);
  }
}

Color readColorEnd() {
  if (writeData["color"] == "red") {
    return const Color.fromARGB(110, 253, 199, 199);
  } else if (writeData["color"] == "pink") {
    return const Color.fromARGB(110, 253, 199, 228);
  }else if (writeData["color"] == "blue") {
    return const Color.fromARGB(110, 199, 229, 253);
  } else if (writeData["color"] == "yellow") {
    return const Color.fromARGB(110, 253, 246, 199);
  } else if (writeData["color"] == "cyan") {
    return const Color.fromARGB(110, 199, 251, 253);
  } else {
    return const Color.fromARGB(110, 199, 229, 253);
  }
}
