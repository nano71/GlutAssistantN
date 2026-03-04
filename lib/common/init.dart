import 'package:glutassistantn/type/schedule.dart';

import '../data.dart';
import '../type/course.dart';
import 'io.dart';

initSchedule({withWriteFile = false}) async {
  if (AppData.startSchoolSoon) return;
  print("initSchedule");
  AppData.schedule = createEmptySchedule();
  print("initSchedule End");
  if (withWriteFile) {
    await writeSchedule();
  }
}

initTodaySchedule() async {
  if (AppData.startSchoolSoon) return;
  print("initTodaySchedule");
  DateTime now = DateTime.now();

  int year = now.year;
  int month = now.month;
  int day = now.day;
  int weekday = now.weekday;

  print('当前日期: $year 年 $month 月 $day 日 / ${now.toIso8601String()}');
  final int week = AppData.week;
  List<List<List<Course>>> schedule = List.from(AppData.schedule);
  List<Course> toDay = [];

  if (week < 21 && week != 0) {
    toDay = schedule[week][weekday];
  }

  AppData.todaySchedule = toDay.where((c) => !c.isEmpty).toList();
  if (AppData.todaySchedule.isNotEmpty) {
    todayScheduleTitle = "今天的";
  } else {
    todayScheduleTitle = "今天没课";
  }
  if (!AppData.isLoggedIn) {
    todayScheduleTitle = "";
  }
  print("initTodaySchedule End");
}

initTomorrowSchedule() async {
  if (AppData.startSchoolSoon) return;
  print("initTomorrowSchedule");
  final int week = AppData.week;
  DateTime now = DateTime.now();
  int weekday = now.weekday;

  List<List<List<Course>>> schedule = List.from(AppData.schedule);
  List<Course> tomorrow = [];
  if (now.weekday != 7) {
    if (week < 21 && week != 0) {
      tomorrow = schedule[week][weekday + 1];
    }
  } else {
    if (week < 20) {
      tomorrow = schedule[week + 1][1];
    }
  }

  AppData.tomorrowSchedule = tomorrow.where((c) => !c.isEmpty).toList();
  if (AppData.tomorrowSchedule.isNotEmpty) {
    tomorrowScheduleTitle = "明天的";
  } else {
    tomorrowScheduleTitle = "明天没课嗷";
    if (AppData.todaySchedule.isEmpty) tomorrowScheduleTitle = "明天也没课🤣";
  }
  if (!AppData.isLoggedIn) {
    tomorrowScheduleTitle = "";
  }
  print("initTomorrowSchedule End");
}
