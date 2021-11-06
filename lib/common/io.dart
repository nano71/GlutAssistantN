import 'dart:convert';
import 'dart:io';

import 'package:glutnnbox/common/init.dart';
import 'package:path_provider/path_provider.dart';

import '../data.dart';

// /// 获取文档目录文件
// Future<File> _getLocalDocumentFile() async {
//   final dir = await getApplicationDocumentsDirectory();
//   return File('${dir.path}/str.txt');
// }
//
// /// 获取临时目录文件
// Future<File> _getLocalTemporaryFile() async {
//   final dir = await getTemporaryDirectory();
//   return File('${dir.path}/table.json');
// }

Future<File> scheduleLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/schedule.json');
}

Future<void> writeSchedule(String str) async {
  final file = await scheduleLocalSupportFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }
  try {
    await file.writeAsString(str);
    print("writeSchedule End");
  } catch (e) {
    print(e);
  }
}

Future<void> readSchedule() async {
  final file = await scheduleLocalSupportFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }
  try {
    final result = await file.readAsString();
    Map _schedule = jsonDecode(result);
    if (_schedule.length == 20) {
      schedule = jsonDecode(result);
      print("readSchedule End");
    } else {
      initSchedule();
    }
  } catch (e) {
    print(e);
  }
}

Future<File> configLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/config.json');
}

Future<void> writeConfig(String week) async {
  print("writeConfig");
  writeData["time"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
  writeData["week"] = week;
  String str = jsonEncode(writeData);
  final file = await configLocalSupportFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }
  try {
    await file.writeAsString(str);
    print("writeConfig End");
    readConfig();
  } catch (e) {
    print(e);
  }
}

Future<void> readConfig() async {
  print("readConfig");
  final file = await configLocalSupportFile();
  bool dirBool = await file.exists();
  if (!dirBool) {
    await file.create(recursive: true);
  }
  try {
    final result = await file.readAsString();
    writeData = jsonDecode(result);
    List timeList = writeData["time"].split("-");
    print("readConfig End");
  } catch (e) {
    print(e);
  }
}

int daysBetweenDay(DateTime a, DateTime b) {
  int v = a.millisecondsSinceEpoch - b.millisecondsSinceEpoch;
  return v ~/ 86400000;
}
