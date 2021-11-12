import 'dart:math';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

EventBus pageBus = EventBus();

class SetPageIndex {
  int index;

  SetPageIndex(this.index);
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

Map schedule = {};
Map writeData = {
  "time": "",
  "week": "1",
  "weekDay": "",
  "username": "",
  "password": "",
  "name": "",
  "semester": "",
  "semesterBk": "",
  "year": "",
  "yearBk": "",
  "color": "blue"
};
List todaySchedule = [];
List tomorrowSchedule = [];

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
