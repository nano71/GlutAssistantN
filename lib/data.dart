import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

EventBus pageBus = EventBus();

class SetPageIndex {
  int index;

  SetPageIndex(this.index);
}

class QueryExamRe {
  int index;

  QueryExamRe(this.index);
}

class CareerRe {
  int index;

  CareerRe(this.index);
}

class QueryScoreRe {
  int index;

  QueryScoreRe(this.index);
}

class ReState {
  int index;

  ReState(this.index);
}

class ReTomorrowListState {
  int index;

  ReTomorrowListState(this.index);
}

class ReTodayListState {
  int index;

  ReTodayListState(this.index);
}

double gpa = 0.0;
double avg = 0.0;
double weight = 0.0;
Map schedule = {};
Map writeData = {
  "time": "",
  "week": "1",
  "weekBk":"",
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
  "newVersion": "",
  "newBody": "",
  "newTime": "",
  "githubDownload": ""
};
List todaySchedule = [];
List tomorrowSchedule = [];
List queryScore = [];
List careerList = [];
List careerList2 = [];
List<String> careerInfo = ["", "", "", "", "", "", "", "", "", ""];
List<int> careerCount = [0, 0, 0, 0];
int careerNumber = 0;
int careerJobNumber = 0;
int examAllNumber = 0;
List<List<String>> examList = [];
List<bool> examListC = [];
int examListA = 0;
int examListB = 0;
String todayScheduleTitle = "";
String tomorrowScheduleTitle = "";
final List startTimeList = [
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
final List endTimeList = [
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
List colorList = [
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

List colorList2 = [
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

String courseLongText2ShortName(String value) {
  return value.replaceAll("（", "(").replaceAll("）", ")").replaceAll("毛泽东思想和中国特色社会主义理论体系概论", "毛概");
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

String weekDay2Number(String value) {
  return value
      .replaceAll("周一", "1")
      .replaceAll("周二", "2")
      .replaceAll("周三", "3")
      .replaceAll("周四", "4")
      .replaceAll("周五", "5")
      .replaceAll("周六", "6")
      .replaceAll("周日", "7");
}

