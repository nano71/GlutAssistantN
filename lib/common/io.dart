import 'dart:convert';
import 'dart:io';

import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/init.dart';
import 'package:path_provider/path_provider.dart';

import '../data.dart';

Future<File> scheduleLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/schedule.json');
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

Future<void> writeConfig() async {
  print("writeConfig");
  writeData["time"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
  writeData["weekDay"] = DateTime.now().weekday;
  print(jsonEncode(writeData));
  String str = jsonEncode(writeData);
  final file = await configLocalSupportFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }
  try {
    await file.writeAsString(str);
    print("writeConfig End");
  } catch (e) {
    print(e);
  }
}

Future<void> readConfig() async {
  print("readConfig");
  final file = await configLocalSupportFile();
  bool dirBool = await file.exists();
  print(dirBool);
  if (!dirBool) {
    print("文件不存在");
    await file.create(recursive: true);
  }
  try {
    final result = await file.readAsString();
    if (result.isNotEmpty) {
      print(result);
      writeData = jsonDecode(result);
      List _timeList = writeData["time"].toString().split("-");
      int y = DateTime.now().year;
      int m = DateTime.now().month;
      int d = DateTime.now().day;
      int _nowWeek = int.parse(writeData["week"]) +
          getLocalWeek(DateTime(y, m, d),
              DateTime(int.parse(_timeList[0]), int.parse(_timeList[1]), int.parse(_timeList[2])));
      writeData["week"] = _nowWeek.toString();
      print("readConfig End");
      await writeConfig();
    } else {
      await writeConfig();
    }
  } catch (e) {
    print(e);
  }
}
