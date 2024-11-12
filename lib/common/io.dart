import 'dart:convert';
import 'dart:io';

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
  print(AppConfig.cookie);
  try {
    await file.writeAsString(jsonEncode(AppConfig.cookie));
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
    AppConfig.cookie = jsonDecode(result);
    print(AppConfig.cookie);
    print("readCookie End");
  }
}

Future<void> writeSchedule(String str) async {
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
  await initSchedule();
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
    AppData.schedule = jsonDecode(result);
    print("readSchedule End");
  } else {
    await initSchedule();
  }
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

Future<void> writeConfig() async {
  print("writeConfig");
  AppData.persistentData["time"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
  AppData.persistentData["weekDay"] = DateTime.now().weekday.toString();
  String str = jsonEncode(AppData.persistentData);
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

    //true = 不存在
    if (result.isNotEmpty) {
      print("缓存文件存在");
      jsonDecode(result).forEach((key, value) {
        AppData.persistentData[key] = value.toString();
      });
      print("缓存数据时间: " + AppData.persistentData["time"].toString());

      List<int> _timeList = AppData.persistentData["time"].toString().split("-").map((String element) {
        return int.parse(element);
      }).toList();
      int y = DateTime.now().year;
      int m = DateTime.now().month;
      int d = DateTime.now().day;
      int _currentWeek = weekInt() + getWeekDifference(DateTime(y, m, d), DateTime(_timeList[0], _timeList[1], _timeList[2]));
      AppData.persistentData["week"] = _currentWeek.toString();
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
    print("readConfig save");
    await writeConfig();
    print("readConfig End");
  } catch (e) {
    print(e);
  }
}
