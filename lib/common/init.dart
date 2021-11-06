import 'dart:convert';

import '../data.dart';
import 'io.dart';

initSchedule() {
  Map _schedule = {};
  for (var i = 1; i < 21; i++) {
    _schedule[i.toString()] = {};
    for (var j = 1; j < 8; j++) {
      _schedule[i.toString()]?[(j - 1).toString()] = {};
      for (var k = 1; k < 12; k++) {
        _schedule[i.toString()]?[(j - 1).toString()]?[k.toString()] = ["null", "null", "null"];
      }
    }
  }
  schedule = _schedule;
  print("initSchedule End");
  writeSchedule(jsonEncode(schedule));
}

initTodaySchedule() {
  final String _week = writeData["week"].toString();
  Map _schedule = schedule;
  List toDay = [];
  _schedule[_week][DateTime.now().weekday.toString()].forEach((k, v) => {
        if (v[1] != null) {v.add(k), toDay.add(v)}
      });
  if (toDay.isNotEmpty) {
    todayScheduleTitle = "今天的";
    todaySchedule = toDay;
  } else {
    todayScheduleTitle = "今天没课哦";
  }
}

initTomorrowSchedule() {
  final String _week = writeData["week"].toString();
  Map _schedule = schedule;
  List tomorrow = [];
  String _getWeekDay() {
    if (DateTime.now().weekday <= 6) {
      return (DateTime.now().weekday).toString();
    } else {
      return "1";
    }
  }

  _schedule[_week][_getWeekDay()].forEach((k, v) => {
        if (v[1] != null) {v.add(k), tomorrow.add(v)}
      });
  if (tomorrow.isNotEmpty) {
    tomorrowScheduleTitle = "明天的";
    tomorrowSchedule = tomorrow;
  } else {
    tomorrowScheduleTitle = "明天没课嗷";
  }
}
