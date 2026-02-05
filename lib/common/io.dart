import 'dart:convert';
import 'dart:io';

import 'package:glutassistantn/type/schedule.dart';
import 'package:path_provider/path_provider.dart';

import '/common/init.dart';
import '/config.dart';
import '../data.dart';
import 'day.dart';

Future<File> scheduleLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/schedule.json');
}

Future<File> cookieFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/cookie.json');
}

Future<void> writeCookie() async {
  print("writeCookie");
  final file = await cookieFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }
  print(AppConfig.cookies);
  try {
    await file.writeAsString(jsonEncode(AppConfig.cookies));
    print("writeCookie End");
  } catch (e) {
    print(e);
  }
}

Future<void> readCookie() async {
  print("readCookie");
  final file = await cookieFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }
  final result = await file.readAsString();
  if (result.isNotEmpty) {
    AppConfig.cookies = jsonDecode(result);
    print(AppConfig.cookies);
    print("readCookie End");
  }
}

Future<void> writeSchedule() async {
  String str = jsonEncode(
    AppData.schedule.map((w) => w.map((d) => d.map((c) => c.toJson()).toList()).toList()).toList(),
  );
  print("writeSchedule");
  final file = await scheduleLocalSupportFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }
  try {
    await file.writeAsString("");
    await file.writeAsString(str);
    print("writeSchedule End");
  } catch (e) {
    print("writeSchedule Error");
    print(e);
  }
}

Future<void> clearAll() async {
  final file1 = await scheduleLocalSupportFile();
  final file2 = await configLocalSupportFile();
  bool dirBool1 = await file1.exists();
  bool dirBool2 = await file2.exists();
  if (dirBool1) {
    await file1.delete();
  }
  if (dirBool2) {
    await file2.delete();
  }
  await initSchedule(withWriteFile: true);
}

Future<void> readSchedule() async {
  print("readSchedule");
  final file = await scheduleLocalSupportFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }

  final result = await file.readAsString();
  if (result.isNotEmpty) {
    dynamic raw = jsonDecode(result);
    // print(raw);
    if (raw is List) {
      AppData.schedule = parseNewSchedule(raw);
      // 新格式
    } else if (raw is Map) {
      // 旧格式
      AppData.schedule = migrateOldSchedule(raw);
    }
  } else {
    await initSchedule();
  }
  print("readSchedule End");
}

Future<File> configLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/config.json');
}

Future<File> startTimeLocalSupportFile() async {
  print("startTimeLocalSupportFile");
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/startTime.json');
}

Future<File> endTimeLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/endTime.json');
}

Future<void> writeConfig2(String jsonString) async {
  print('writeConfig2');
  final file = await configLocalSupportFile();

  try {
    await file.writeAsString(jsonString);
    print("writeConfig2 End");
  } catch (e) {
    print(e);
  }
}

Future<void> writeConfig() async {
  if (AppData.hasReadConfigError) return print("hasReadConfigError");
  print("writeConfig");
  final now = DateTime.now();

  Map<String, dynamic> preEncodeData = {
    "studentId": AppData.studentId,
    "password": AppData.password,
    "studentName": AppData.studentName,
    "year": AppData.year,
    "semester": AppData.semester,
    "theme": AppData.theme,
    "programBackendSurvivalThreshold": AppData.programBackendSurvivalThreshold,
    "showLessonTimeInList": AppData.showLessonTimeInList,
    "showDayByWeekDay": AppData.showDayByWeekDay,
    "showScheduleChange": AppData.showScheduleChange,
    "schedulePagePromptCount": AppData.schedulePagePromptCount,
    "baseWeek": AppData.week,
    "baseWeekTime": "${now.year}-${now.month}-${now.day}",
    "newVersionChangelog": AppData.newVersionChangelog,
    "newVersionNumber": AppData.newVersionNumber,
    "newVersionDownloadUrl": AppData.newVersionDownloadUrl
  };

  String str = jsonEncode(preEncodeData);
  String startTimeStr = jsonEncode(startTimeList);
  String endTimeStr = jsonEncode(endTimeList);
  final file = await configLocalSupportFile();
  final startTimeFile = await startTimeLocalSupportFile();
  final endTimeFile = await endTimeLocalSupportFile();
  bool dirBool = await file.exists();
  bool endTimeDirBool = await endTimeFile.exists();
  bool startTimeDirBool = await startTimeFile.exists();
  if (!dirBool) await file.create(recursive: true);
  if (!endTimeDirBool) await endTimeFile.create(recursive: true);
  if (!startTimeDirBool) await startTimeFile.create(recursive: true);

  try {
    await file.writeAsString(str);
    await startTimeFile.writeAsString(startTimeStr);
    await endTimeFile.writeAsString(endTimeStr);
    print("writeConfig End");
  } catch (e) {
    print(e);
  }
}

Future<void> readWeek() async {
  print('readWeek');
  if (AppData.baseWeekTime == "" || AppData.baseWeek == "") return;
  List<int> _timeList = AppData.baseWeekTime.split("-").map(int.parse).toList();
  int y = DateTime.now().year;
  int m = DateTime.now().month;
  int d = DateTime.now().day;
  int realWeek = weekInt(customWeek: AppData.baseWeek) +
      weekDifference(DateTime(y, m, d), DateTime(_timeList[0], _timeList[1], _timeList[2]));
  if (realWeek < 0) {
    AppData.week = 1;
    return;
  }
  AppData.week = realWeek;
  if (!AppData.isReleaseMode) {
    AppData.week = 11;
  }
  if (realWeek > 20) {
    AppData.startSoon = true;
  }
  print('readWeek End');
}

Future<void> readConfig() async {
  print("readConfig");
  final file = await configLocalSupportFile();
  final startTimeFile = await startTimeLocalSupportFile();
  final endTimeFile = await endTimeLocalSupportFile();

  bool dirBool = await file.exists();
  bool endTimeDirBool = await endTimeFile.exists();
  bool startTimeDirBool = await startTimeFile.exists();

  if (!dirBool) await file.create(recursive: true);
  if (!endTimeDirBool) await endTimeFile.create(recursive: true);
  if (!startTimeDirBool) await startTimeFile.create(recursive: true);

  try {
    final result = await file.readAsString();
    final startTimeResult = await startTimeFile.readAsString();
    final endTimeResult = await endTimeFile.readAsString();

    // 存在
    if (result.isNotEmpty) {
      print("缓存文件存在");
      print("cache File: $result");
      jsonDecode(result).forEach((key, value) {
        AppData.persistentData[key] = value.toString();
        // print(key);
        if (value == null || value == "") {
          return print("skip: $key");
        }
        int parseInt(dynamic value) {
          if (value is String) {
            return int.parse(value);
          }
          return value;
        }

        bool parseBool(dynamic value) {
          return value == "1" || value == true;
        }

        switch (key) {
          case "prompt":
          case "schedulePagePromptCount":
            AppData.schedulePagePromptCount = parseInt(value);
            break;

          case "baseWeek":
            AppData.baseWeek = parseInt(value);
            break;

          case "setBaseWeekTime":
          case "baseWeekTime":
            AppData.baseWeekTime = value;
            break;

          case "username":
          case "studentId":
            AppData.studentId = value;
            break;

          case "password":
            AppData.password = value;
            break;

          case "name":
          case "studentName":
            AppData.studentName = value;
            break;

          case "year":
            int year = parseInt(value);
            AppData.year = year;
            AppData.queryYear = year.toString();
            break;

          case "semester":
            AppData.semester = value;
            AppData.querySemester = value;
            break;

          case "color":
          case "theme":
            AppData.theme = value;
            break;

          case "showScheduleChange":
            AppData.showScheduleChange = parseBool(value);
            break;

          case "showLessonTimeInList":
            AppData.showLessonTimeInList = parseBool(value);
            break;

          case "showDayByWeekDay":
            AppData.showDayByWeekDay = parseBool(value);
            break;

          case "threshold":
          case "programBackendSurvivalThreshold":
            AppData.programBackendSurvivalThreshold = parseInt(value);
            break;

          case "newVersionChangelog":
            AppData.newVersionChangelog = value;
            break;
          case "newVersionNumber":
            AppData.newVersionNumber = value;
            break;
          case "newVersionDownloadUrl":
            AppData.newVersionDownloadUrl = value;
            break;
        }
      });
    }
    //存在
    if (startTimeResult.isNotEmpty) {
      List<dynamic> parsedJson = jsonDecode(startTimeResult);
      startTimeList = parsedJson.map((list) {
        return List<int>.from(list);
      }).toList();
    }
    if (endTimeResult.isNotEmpty) {
      List<dynamic> parsedJson = jsonDecode(endTimeResult);
      endTimeList = parsedJson.map((list) {
        return List<int>.from(list);
      }).toList();
    }
    print("readConfig End");
  } catch (e) {
    print(e);
    throw e;
  }
}
