import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

EventBus eventBus = EventBus();

class SetPageIndex {
  late int index;

  // SetPageIndex({int index = 0}) {
  //   this.index = index;
  // }
  SetPageIndex({this.index = 0});
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

class ReloadTomorrowListState {
  ReloadTomorrowListState();
}

class ReloadTodayListState {
  ReloadTodayListState();
}

class AppData {
  static late BuildContext homeContext;
  static bool canCheckImportantUpdate = true;
  static bool hasNewVersion = false;
  static final bool isReleaseMode = const bool.fromEnvironment("dart.vm.product");
  static Map schedule = {};
  static bool isInitialized = false;
  static Map<String, String> persistentData = {
    "time": "",
    "week": "1",
    "weekBk": "",
    "weekDay": "",
    "username": "",
    "password": "",
    "name": "",
    "semester": "",
    "semesterBk": "",
    "year": "",
    "yearBk": "",
    "color": "blue",
    "querySemester": "",
    "queryYear": "",
    "threshold": "5",
    "showLessonTimeInList": "0",
    "newVersion": "",
    "newBody": "",
    "newTime": "",
    "githubDownload": ""
  };
  static List<List> tomorrowSchedule = [];
  static List<List> todaySchedule = [];
}

List queryScore = [];
List<double> scores = [0.0, 0.0, 0.0];
List careerList = [];
List careerList2 = [];
List<String> careerInfo = ["", "", "", "", "", "", "", "", "", ""];
List<int> careerCount = [0, 0, 0, 0];
int careerNumber = 0;
int careerJobNumber = 0;
int examAllNumber = 0;
List<List<String>> examList = [];
List<Map> classroomList = [];
List<bool> examListC = [];
int examListA = 0;
int examListB = 0;
String todayScheduleTitle = "";
String tomorrowScheduleTitle = "";
List<List<int>> startTimeListBk = [];
List<List<int>> endTimeListBk = [];
final List<String> weekList4CN = const ["一", "二", "三", "四", "五", "六", "日"];

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

final List<String> excludedCourses = [
  "职业发展与就业指导（一）",
  "职业发展与就业指导（二）",
  "职业发展与就业指导（三）",
  "职业发展与就业指导（四）",
  "职业发展与就业指导（五）",
  "就业指导与创业基础（一）",
  "就业指导与创业基础（二）",
  "就业指导与创业基础（三）",
  "创业基础（一）",
  "创业基础（二）",
  "创业基础（三）",
  "大学生心理健康（一）",
  "大学生心理健康（二）",
  "形势与政策（一）",
  "形势与政策（二）",
  "形势与政策（三）",
  "形势与政策（四）",
  "形势与政策（五）",
  "形势与政策（六）",
  "形势与政策（七）",
  "形势与政策（八）",
  "形势与政策",
  "体育（一）",
  "体育（二）",
  "体育（三）",
  "体育（四）",
  "大学生安全教育（十）",
  "大学生安全教育（一）",
  "大学生安全教育（二）",
  "大学生安全教育（三）",
  "大学生安全教育（四）",
  "大学生安全教育（五）",
  "大学生安全教育（六）",
  "大学生安全教育（七）",
  "大学生安全教育（八）",
  "大学生安全教育（九）",
  "职业发展与就业指导（一）",
  "职业发展与就业指导（二）",
  "职业发展与就业指导（三）",
  "职业发展与就业指导（四）",
  "职业发展与就业指导（五）",
  "就业指导与创业基础（一）",
  "就业指导与创业基础（二）",
  "就业指导与创业基础（三）",
  "创业基础（一）",
  "创业基础（二）",
  "大学生心理学（一）",
  "大学生心理学（二）",
  "大学生心理健康教育（一）",
  "大学生心理健康教育（二）",
  "形势与政策（一）",
  "形势与政策（二）",
  "形势与政策（三）",
  "形势与政策（四）",
  "形势与政策（五）",
  "形势与政策（六）",
  "形势与政策",
  "体育（一）",
  "体育（二）",
  "体育（三）",
  "体育（四）",
  "大学生安全教育（一）",
  "大学生安全教育（二）",
  "大学生安全教育（三）",
  "大学生安全教育（四）",
  "大学生安全教育（五）",
  "大学生安全教育（六）",
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

Color randomColors() {
  return colorList[randomInt(0, colorList.length - 1)];
}

Color randomColors2() {
  return colorList2[randomInt(0, colorList2.length - 1)];
}

int randomInt(int min, int max) {
  return min + Random().nextInt(max - min + 1);
}

String courseLongText2Short(String value) {
  return value.replaceAll("（", "(").replaceAll("）", ")").replaceAll("毛泽东思想和中国特色社会主义理论体系概论", "毛概");
}

String levelToNumber(String value) {
  return value.replaceAll("优", "95").replaceAll("良", "85").replaceAll("中", "75").replaceAll("及格", "65").replaceAll("合格", "65").replaceAll("不及格", "40").replaceAll("不合格", "40");
}

String weekCN2Number(String value) {
  weekList4CN.forEach((word) {
    value = value.replaceAll("周" + word, (weekList4CN.indexOf(word) + 1).toString());
  });
  return value;
}

int weekInt() {
  // AppData.persistentData["week"] = "7";
  // writeConfig();
  return int.parse(AppData.persistentData["week"] ?? "");
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

bool isLogin() {
  return AppData.persistentData["username"] != "";
}

bool isExcludedCourse(String courseName) {
  return excludedCourses.contains(courseName);
}
