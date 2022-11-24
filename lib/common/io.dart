import 'dart:convert';
import 'dart:io';

import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/init.dart';
import 'package:glutassistantn/config.dart';
import 'package:path_provider/path_provider.dart';

import '../data.dart';

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
  print(Global.cookie);
  try {
    await file.writeAsString(jsonEncode(Global.cookie));
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
    Global.cookie = jsonDecode(result);
    print(Global.cookie);
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
  try {
    final result = await file.readAsString();
    if (result.isNotEmpty) {
      schedule = jsonDecode(result);
      print("readSchedule End");
    } else {
      await initSchedule();
    }
  } catch (e) {
    print(e);
  }
}

Future<File> configLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/config.json');
}

Future<File> startTimeLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/startTime.json');
}

Future<File> endTimeLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/endTime.json');
}

Future<void> writeConfig() async {
  print("writeConfig");
  writeData["time"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
  writeData["weekDay"] = DateTime.now().weekday.toString();
  String str = jsonEncode(writeData);
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
        writeData[key] = value.toString();
      });
      List _timeList = writeData["time"].toString().split("-");
      int y = DateTime.now().year;
      int m = DateTime.now().month;
      int d = DateTime.now().day;
      int _currentWeek = weekInt() + getLocalWeek(DateTime(y, m, d), DateTime(int.parse(_timeList[0]), int.parse(_timeList[1]), int.parse(_timeList[2])));
      writeData["week"] = _currentWeek.toString();
    }
    //存在
    if (startTimeResult.isNotEmpty) {
      startTimeList = jsonDecode(startTimeResult);
    }
    if (endTimeResult.isNotEmpty) {
      endTimeList = jsonDecode(endTimeResult);
    }
    print("readConfig save");
    await writeConfig();
    print("readConfig End");
  } catch (e) {
    print(e);
  }
}
