import 'package:flutter/material.dart';

import 'data.dart';

class AppConfig {
  static String appTitle = "桂工助手N";
  static int pageIndex = 0;
  static PageController pageControl = PageController(
    initialPage: 0,
    keepPage: true,
  );
  static String timeoutErrorMessage = "教务无响应!";
  static String networkErrorMessage = "网络错误!";
  static String unknownDataErrorMessage = "教务未知错误!";
  static String notLoggedInErrorMessage = "请先登录!";
  static String retryErrorMessage = "未知错误,请重试!";
  static int requestTimeoutSeconds = 12;
  static double listLeftIconSize = 18;
  static double schedulePageMinSwipeDistance = 70.0;
  static double schedulePageGridHeight = 60.0;
  static const Map<String, String> cookies = {};
  static String serverHost = "jw.glutnn.cn";
  static String authorUrl = "nano71.com";
  static String controlConfigPath = "/gan/control.json";
  static String recentExamsPath = "/academic/student/exam/index.jsdo";
  static String schedulePath =  "/academic/student/currcourse/currcourse.jsdo";
  static String classReschedulePath =  "/academic/manager/coursearrange/showTimetable.do";
  static String studySchedulePath = "/academic/manager/studyschedule/studentScheduleShowByTerm.do";
  static String captchaCheckPath =  "/academic/checkCaptcha.do";
  static Uri captchaUri = httpUri("/academic/getCaptcha.do");
  static Uri loginUri = httpUri("/academic/j_acegi_security_check");
  static Uri loginValidityCheckUri = httpUri("/academic/showPersonalInfo.do");
  static Uri loginRedirectUri = httpUri("/academic/index_new.jsp");
  static Uri currentWeekUri = httpUri("/academic/listLeft.do");
  static Uri examListUri = httpUri("/academic/manager/examstu/studentQueryAllExam.do");
  static Uri studentInfoUri =
      httpUri("/academic/student/studentinfo/studentInfoModifyIndex.do", {"frombase": "0", "wantTag": "0"});
  static Uri scoreQueryUri = httpUri("/academic/manager/score/studentOwnScore.do");
  static Uri studyScheduleUri = httpUri("/academic/manager/studyschedule/studentSelfSchedule.jsdo");
  static Uri githubLatestReleaseUri = Uri.https("api.github.com", "/repos/nano71/GlutAssistantN/releases/latest");
  static Uri appUpdateCheckUri = Uri.https(authorUrl, "/gan/check");
  static Uri emptyClassroomDayUri = httpUri("/academic/teacher/teachresource/roomschedulequery.jsdo");
  static Uri emptyClassroomWeekUri = httpUri("/academic/teacher/teachresource/roomschedule_week.jsdo");

}

Uri httpUri(
  path, [
  Map<String, dynamic>? queryParameters,
]) {
  return Uri.http(AppConfig.serverHost, path, queryParameters);
}

readHomePageSmallCardTextColor() {
  if (AppData.isDarkTheme) {
    return Colors.white70;
  }
  return Colors.black54;
}

readScheduleListTextColor() {
  if (AppData.isDarkTheme) {
    return Colors.white;
  }
  return Colors.black;
}

readScheduleListTextColor2() {
  if (AppData.isDarkTheme) {
    return Colors.white54;
  }
  return Color(0xff999999);
}

readScheduleListTextColor3() {
  if (AppData.isDarkTheme) {
    return Colors.white30;
  }
  return Colors.black26;
}

readScoreColor(String score) {
  int value = int.parse(levelToNumber(score));

  if (value >= 95) {
    return Colors.blue;
  } else if (value >= 90) {
    return Colors.blue[700];
  } else if (value >= 85) {
    return Colors.blue[700];
  } else if (value >= 80) {
    return Colors.green;
  } else if (value >= 75) {
    return Colors.green[600];
  } else if (value >= 70) {
    return Colors.orange;
  } else if (value >= 65) {
    return Colors.deepOrange;
  } else {
    return Colors.red;
  }
}

readNavigationBarIconBrightness() {
  if (AppData.isDarkTheme) {
    return Brightness.light;
  }
  return Brightness.dark;
}

readClassRoomCardBackgroundColor(bool isEmpty) {
  if (isEmpty) {
    if (AppData.isDarkTheme) {
      return Color(0xFF18181c);
    }
    return Colors.grey;
  }
  return randomColors2();
}

readClassRoomCardTextContentBackgroundColor(bool isEmpty) {
  if (isEmpty) {
    if (AppData.isDarkTheme) {
      return Color(0xFF26262a);
    }
  }
  return Color(0x2AFFFFFF);
}

readClassRoomCardTextContentColor(bool isEmpty) {
  if (isEmpty) {
    if (AppData.isDarkTheme) {
      return readTextColor3();
    }
    return Color(0x2AFFFFFF);
  }
  return Colors.white;
}

readBorderColor() {
  if (AppData.isDarkTheme) {
    return Color(0xFF18181c);
  }
  return Colors.white;
}

readLineColor() {
  if (AppData.isDarkTheme) {
    return Color(0x1AFFFFFF);
  }
  return Color(0x66f1f1f1);
}

readListPageBackgroundColor() {
  if (AppData.isDarkTheme) {
    return readBackgroundColor();
  }
  return Colors.transparent;
}

readBackgroundColor() {
  if (AppData.isDarkTheme) {
    return Color(0xFF101014);
  }
  return Color(0xFFFAFAFA);
}

readTextColor() {
  if (AppData.isDarkTheme) {
    return Colors.white;
  }
  return Colors.black;
}

readTextColor2() {
  if (AppData.isDarkTheme) {
    return Colors.white54;
  }
  return Colors.black54;
}

readTextColor3() {
  if (AppData.isDarkTheme) {
    return Colors.white38;
  }
  return Colors.black45;
}

readArrowIconColor() {
  if (AppData.isDarkTheme) {
    return Colors.white60;
  }
  return Colors.black26;
}

readCardBackgroundColor() {
  if (AppData.isDarkTheme) {
    return Color(0xFF18181c);
  }
  return Colors.white;
}

readCardBackgroundColor2() {
  if (AppData.isDarkTheme) {
    return Color(0xFF26262a);
  }
  return Colors.white;
}

readTextContentBackgroundColor() {
  if (AppData.isDarkTheme) {
    return readCardBackgroundColor2();
  }
  return readColorEnd();
}

readListPageTopAreaBackgroundColor() {
  if (AppData.isDarkTheme) {
    return Color(0xFF18181c);
  }
  return readColor();
}

List<String> colorTexts = ["dark", "purple", "red", "pink", "blue", "cyan", "yellow"];

LinearGradient readGradient() {
  switch (AppData.theme) {
    case "dark":
      return setTemplate([Color(0xff11998e), Color(0xFF38ef7d)]);
    case "purple":
      return setTemplate([Color(0xfff0abfc), Color(0xff4f46e5)]);
    case "red":
      return setTemplate([Color(0xFFfbab66), Color(0xFFf7418c)]);
    case "pink":
      return setTemplate([Color(0xffc471f5), Color(0xfffa71cd)]);
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
  color ??= AppData.theme;

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
  switch (AppData.theme) {
    case "dark":
      return setCardTemplate([Color(0xff11998e), Color(0xff38ef7d)]);
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
  switch (AppData.theme) {
    case "dark":
      return setCardTemplate2([Color(0xa011998e), Color(0xe638ef7d)]);
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
  switch (AppData.theme) {
    case "dark":
      return Color(0xFF18181c);
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
  switch (AppData.theme) {
    case "dark":
      return Color(0xFF26262a);
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
