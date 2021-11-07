import 'dart:math';

import 'package:flutter/material.dart';

Map schedule = {};
Map writeData = {
  //时间
  "time": "",
  //是多少周
  "week": "1",

  "weekDay": "",
  "username": "5191963403",
  "password": "",
  "name": "梁皓"
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
  [10, 20],
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
];

Color randomColors() {
  return colorList[randomInt(0, colorList.length - 1)];
}

int randomInt(int min, int max) {
  return min + Random().nextInt(max - min + 1);
}

String courseLongText2ShortName(String value) {
  return value.replaceAll("（", "(").replaceAll("）", ")").replaceAll("毛泽东思想和中国特色社会主义理论体系概论", "毛概");
}
