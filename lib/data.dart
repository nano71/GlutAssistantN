import 'dart:math';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistantn/type/course.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'config.dart';

EventBus eventBus = EventBus();

class ErrorEvent {
  final String message;

  ErrorEvent(this.message);
}

class SetPageIndex {
  late int index;

  // SetPageIndex({int index = 0}) {
  //   this.index = index;
  // }
  SetPageIndex({this.index = 0});
}

class UpdateAppThemeState {
  UpdateAppThemeState();
}

class ReloadExamListState {
  ReloadExamListState();
}

class ReloadClassroomListState {
  ReloadClassroomListState();
}

class ReloadCareerPageState {
  ReloadCareerPageState();
}

class ReloadScoreListState {
  ReloadScoreListState();
}

class ReloadSchedulePageState {
  ReloadSchedulePageState();
}

class ReloadHomePageState {
  ReloadHomePageState();
}

class ReloadTomorrowListState {
  ReloadTomorrowListState();
}

class ReloadTodayListState {
  ReloadTodayListState();
}

class AppData {
  static int week = 0;

  static int year = 0;
  static String semester = "";
  static String theme = "blue";
  static bool showScheduleChange = false;
  static bool showLessonTimeInList = false;
  static bool showDayByWeekDay = false;
  static String studentName = "";
  static String password = "";
  static String studentId = "";
  static String queryYear = "";
  static String querySemester = "";
  static int programBackendSurvivalThreshold = 5;
  static String baseWeekTime = "";
  static int baseWeek = -1;
  static int schedulePagePromptCount = 0;

  static bool isLoggedIn = false;
  static bool isDarkTheme = false;
  static bool isInitialized = false;
  static bool startSoon = false;
  static late BuildContext homeContext;
  static bool canCheckImportantUpdate = true;
  static bool hasNewVersion = false;
  static bool hasReadConfigError = false;
  static String newVersionChangelog = "";
  static String newVersionNumber = "";
  static String newVersionDownloadUrl = "";

  static final bool isReleaseMode = const bool.fromEnvironment("dart.vm.product");
  static late PackageInfo packageInfo;
  static late AndroidDeviceInfo deviceInfo;

  static late List<List<List<Course>>> schedule;

  static Map<String, String> persistentData = {
    "username": "",
    "password": "",
    "name": "",
    "semester": "",
    "year": "",
    "color": "blue",
    "querySemester": "",
    "queryYear": "",
    "threshold": "5",
    "showLessonTimeInList": "0",
    "showDayByWeekDay": "0",
    "showScheduleChange": "0",
    "newVersion": "",
    "newBody": "",
    "newTime": "",
    "githubDownload": ""
  };
  static List<Course> tomorrowSchedule = [];
  static List<Course> todaySchedule = [];

  static int pageIndex = 0;
  static PageController pageControl = PageController(
    initialPage: 0,
    keepPage: true,
  );
}

List queryScore = [];
List<double> scores = [0.0, 0.0, 0.0];
List careerList = [];
List careerList2 = [];
List<String> careerInfo = ["", "", "", "", "", "", "", "", "", ""];
List<int> courseCountsByScore = [0, 0, 0, 0];
List<List<String>> examList = [];
List<bool> examList2 = [];

List<Map> classroomList = [];

int completedExamCount = 0;
int upcomingExamCount = 0;
String todayScheduleTitle = "";
String tomorrowScheduleTitle = "";
List<List<int>> startTimeListBk = [];
List<List<int>> endTimeListBk = [];
final List<String> weekTextList = const ["一", "二", "三", "四", "五", "六", "日"];

List<List<int>> startTimeList = [
  [8, 40],
  [9, 25],
  [10, 25],
  [11, 10],
  [14, 30],
  [15, 15],
  [16, 05],
  [16, 50],
  [19, 30],
  [20, 15],
  [21, 00]
];
List<List<int>> endTimeList = [
  [9, 20],
  [10, 05],
  [11, 05],
  [11, 50],
  [15, 10],
  [15, 55],
  [16, 45],
  [17, 30],
  [20, 10],
  [20, 55],
  [21, 40]
];
final List<List<int>> startTimeListRestore = const [
  [8, 40],
  [9, 25],
  [10, 25],
  [11, 10],
  [14, 30],
  [15, 15],
  [16, 05],
  [16, 50],
  [19, 30],
  [20, 15],
  [21, 00]
];
final List<List<int>> endTimeListRestore = const [
  [9, 20],
  [10, 05],
  [11, 05],
  [11, 50],
  [15, 10],
  [15, 55],
  [16, 45],
  [17, 30],
  [20, 10],
  [20, 55],
  [21, 40]
];

final List<String> containCourseTypes = ["实践教学环节", "专业核心课", "专业基础课", "公共必修课"];
final List<String> excludedCourseNumbers = [
  "B83A000111",
  "B83A000112",
  "B83A000113",
  "B83A000114",
  "B83A000115",
  "B83A000211",
  "B83A000212",
  "B83A000213",
  "B84A000111",
  "B84A000112",
  "B84A000113",
  "B85A000111",
  "B85A000112",
  "B72A000411",
  "B72A000412",
  "B72A000413",
  "B72A000414",
  "B72A000415",
  "B72A000416",
  "B72A000417",
  "B72A000418",
  "B72A000611",
  "B82A000111",
  "B82A000112",
  "B82A000113",
  "B82A000114",
  "B87A000210",
  "B87A000211",
  "B87A000212",
  "B87A000213",
  "B87A000214",
  "B87A000215",
  "B87A000216",
  "B87A000217",
  "B87A000218",
  "B87A000219",
  "G83A000111",
  "G83A000112",
  "G83A000113",
  "G83A000114",
  "G83A000115",
  "G83A000211",
  "G83A000212",
  "G83A000213",
  "G84A000111",
  "G84A000112",
  "B85A000111",
  "B85A000112",
  "G85A000111",
  "G85A000112",
  "G72A000311",
  "G72A000312",
  "G72A000313",
  "G72A000314",
  "G72A000315",
  "G72A000316",
  "G72A000321",
  "G82A000111",
  "G82A000112",
  "G82A000113",
  "G82A000114",
  "G87A000211",
  "G87A000212",
  "G87A000213",
  "G87A000214",
  "G87A000215",
  "G87A000216"
];

final List colorList = const [
  Colors.red,
  Colors.amber,
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.orange,
  Colors.lightGreen,
  Colors.redAccent,
  Colors.blueAccent,
  Colors.deepOrangeAccent,
  Colors.deepPurpleAccent,
  Colors.teal,
  Colors.cyan
];

final List colorList2 = const [
  Colors.red,
  Colors.amber,
  Colors.blue,
  Colors.green,
  Colors.deepPurpleAccent,
];

final List colorList3 = const [
  Colors.teal,
  Colors.lightBlue,
  Colors.blue,
  Colors.green,
  Colors.purple,
  Colors.lightGreen,
  Colors.blueAccent,
  Colors.deepPurpleAccent,
  Colors.teal,
  Colors.cyan
];

Color randomColors() {
  return colorList[randomInt(0, colorList.length - 1)];
}

Color randomColors2() {
  return colorList2[randomInt(0, colorList2.length - 1)];
}

Color randomColors3() {
  return colorList3[randomInt(0, colorList3.length - 1)];
}

int randomInt(int min, int max) {
  return min + Random().nextInt(max - min + 1);
}

String courseLongText2Short(String value) {
  return value
      .replaceAll("（", "(")
      .replaceAll("）", ")")
      .replaceAll("毛泽东思想和中国特色社会主义理论体系概论", "毛概")
      .replaceAll("习近平新时代中国特色社会主义思想概论", "习近平思想概论");
}

String levelToNumber(String value) {
  return value
      .replaceAll("优", "95")
      .replaceAll("良", "85")
      .replaceAll("中", "75")
      .replaceAll("及格", "65")
      .replaceAll("合格", "65")
      .replaceAll("不及格", "40")
      .replaceAll("不合格", "40");
}

int weekTextToNumber(String text) {
  return weekTextList.indexOf(text.replaceAll("周", "")) + 1;
}

int weekInt({bool exclusionZero = false, int customWeek = -1}) {
  if (customWeek == -1) {
    customWeek = AppData.week;
  }
  int week = customWeek;
  if (exclusionZero && week == 0) return 1;
  return week;
}

Map emptySchedule() {
  print("emptySchedule");
  Map _schedule = {};
  for (var i = 1; i < 21; i++) {
    _schedule[i.toString()] = {};
    for (var j = 1; j < 8; j++) {
      _schedule[i.toString()]?[j.toString()] = {};
      for (var k = 1; k < 12; k++) {
        _schedule[i.toString()]?[j.toString()]?[k.toString()] = ["null", "null", "null"];
      }
    }
  }
  print("emptySchedule End");
  return _schedule;
}

bool isContainCourse(String courseNumber, String courseType) {
  return containCourseTypes.contains(courseType) && !excludedCourseNumbers.contains(courseNumber);
}

String getAccount() {
  return "${AppData.studentId}${AppData.password}";
}

void setSystemNavigationBarColor(Color color) {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    systemNavigationBarColor: color,
    systemNavigationBarIconBrightness: readNavigationBarIconBrightness(),
  ));
}

String onlyDigits(String input) {
  return input.replaceAll(RegExp(r'\D'), '');
}

String removeSpace(String input){
  return input.replaceAll(RegExp(r'\s+'), '');

}

Future<void> readPackageInfo() async {
  AppData.packageInfo = await PackageInfo.fromPlatform();
}

Future<void> readDeviceInfo() async {
  DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  AppData.deviceInfo = await deviceInfo.androidInfo;
}

// 判断是否国产ROM
bool isChinaRom() {
  print(AppData.deviceInfo);
  final brand = AppData.deviceInfo.brand.toLowerCase();
  final manu = AppData.deviceInfo.manufacturer.toLowerCase();

  if (AppData.deviceInfo.version.sdkInt < 36) {
    return false;
  }
  const chinaBrands = [
    'xiaomi',
    'huawei',
    'honor',
    'oppo',
    'vivo',
    'realme',
    'oneplus',
    'meizu',
  ];

  return chinaBrands.any((b) => brand.contains(b) || manu.contains(b));
}
