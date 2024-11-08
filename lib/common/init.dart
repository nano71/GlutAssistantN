import 'dart:convert';

import '../data.dart';
import 'io.dart';

initSchedule() async {
  print("initSchedule");
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
  AppData.schedule = _schedule;
  print("initSchedule End");
  await writeSchedule(jsonEncode(_schedule));
}

initTodaySchedule() async {
  print("initTodaySchedule");
  DateTime now = DateTime.now();

  int year = now.year;
  int month = now.month;
  int day = now.day;

  print('当前日期: $year 年 $month 月 $day 日');
  print(now.toIso8601String());
  final String _week = AppData.persistentData["week"].toString();
  Map _schedule = Map.from(AppData.schedule);
  List<List> toDay = [];
  if (int.parse(_week) < 21) {
    Map weekOfSemester = _schedule[_week];
    Map dayOfWeek = weekOfSemester[DateTime.now().weekday.toString()];
    dayOfWeek.forEach((key, value) {
      if (value is List) if (value[1] != "null") {
        if (value.length < 5) {
          value.add(key);
        }
        toDay.add(value);
      }
    });
  }

  if (toDay.isNotEmpty) {
    todayScheduleTitle = "今天的";
    AppData.todaySchedule = toDay;
  } else {
    todayScheduleTitle = "今天没课";
  }
  if (AppData.persistentData["username"] == "") {
    todayScheduleTitle = "";
  }
  print("initTodaySchedule End");
}

initTomorrowSchedule() async {
  print("initTomorrowSchedule");
  final String _week = AppData.persistentData["week"].toString();
  Map _schedule = Map.from(AppData.schedule);
  List<List> tomorrow = [];
  String _getWeekDay() {
    if (DateTime.now().weekday <= 6) {
      return (DateTime.now().weekday + 1).toString();
    } else {
      return "1";
    }
  }

  if (DateTime.now().weekday <= 6) {
    if (int.parse(_week) < 21)
      await _schedule[_week][_getWeekDay()].forEach((key, value) => {
            if (value[1] != "null") {value.add(key), tomorrow.add(value)}
          });
  } else {
    if (int.parse(_week) < 20)
      await _schedule[(int.parse(_week) + 1).toString()][_getWeekDay()].forEach((key, value) {
        if (value[1] != "null") {
          value.add(key);
          tomorrow.add(value);
        }
      });
  }
  AppData.tomorrowSchedule = tomorrow;
  if (tomorrow.isNotEmpty) {
    tomorrowScheduleTitle = "明天的";
  } else {
    tomorrowScheduleTitle = "明天没课嗷";
    if (AppData.todaySchedule.isEmpty) tomorrowScheduleTitle = "明天也没课🤣";
  }
  if (AppData.persistentData["username"] == "") {
    tomorrowScheduleTitle = "";
  }
  print("initTomorrowSchedule End");
}
