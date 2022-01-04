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
  schedule = _schedule;
  print("initSchedule End");
  await writeSchedule(jsonEncode(schedule));
}

initTodaySchedule() async {
  print("initTodaySchedule");
  final String _week = writeData["week"].toString();
  Map _schedule = schedule;
  List toDay = [];
  await _schedule[_week][DateTime.now().weekday.toString()].forEach((key, value) => {
        if (value[1] != "null")
          {
            if (value.length < 5) {value.add(key)},
            toDay.add(value)
          }
      });

  if (toDay.isNotEmpty) {
    todayScheduleTitle = "今天的";
    todaySchedule = toDay;
  } else {
    todayScheduleTitle = "今天没课";
  }
  if (writeData["username"] == "") {
    todayScheduleTitle = "";
  }
  print("initTodaySchedule End");
}

initTomorrowSchedule() async {
  print("initTomorrowSchedule");
  final String _week = writeData["week"].toString();
  Map _schedule = schedule;
  List tomorrow = [];
  String _getWeekDay() {
    if (DateTime.now().weekday <= 6) {
      return (DateTime.now().weekday + 1).toString();
    } else {
      return "1";
    }
  }

  if (DateTime.now().weekday <= 6) {
    await _schedule[_week][_getWeekDay()].forEach((key, value) => {
          if (value[1] != "null") {value.add(key), tomorrow.add(value)}
        });
  } else {
    await _schedule[(int.parse(_week) + 1).toString()][_getWeekDay()].forEach((key, value) => {
          if (value[1] != "null") {value.add(key), tomorrow.add(value)}
        });
  }
  if (tomorrow.isNotEmpty) {
    tomorrowScheduleTitle = "明天的";
    tomorrowSchedule = tomorrow;
  } else {
    tomorrowScheduleTitle = "明天没课嗷";
    if (todayScheduleTitle == "今天没课") tomorrowScheduleTitle = "明天也没课🤣";
  }
  if (writeData["username"] == "") {
    tomorrowScheduleTitle = "";
  }
  print("initTomorrowSchedule End");
}
