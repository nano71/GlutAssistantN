import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../config.dart';

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
  try {
    await file.writeAsString(str);
  } catch (e) {
    await file.create(recursive: true);
  }
}

Future<Map> readSchedule() async {
  final file = await scheduleLocalSupportFile();
  try {
    final result = await file.readAsString();
    return jsonDecode(result);
  } catch (e) {
    await file.create(recursive: true);
    return jsonDecode('{"message":"fail"}');
  }
}

Future<File> configLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/config.json');
}

Future<void> writeConfig(String week) async {
  print("writeConfig");
  Global.writeData["time"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
  Global.writeData["week"] = week;
  String str = jsonEncode(Global.writeData);
  final file = await configLocalSupportFile();
  try {
    await file.writeAsString(str);
    readConfig();
  } catch (e) {
    await file.create(recursive: true);
  }
}

int daysBetweenDay(DateTime a, DateTime b) {
  int v = a.millisecondsSinceEpoch - b.millisecondsSinceEpoch;
  return v ~/ 86400000;
}

Future<void> readConfig() async {
  print("readConfig");
  final file = await configLocalSupportFile();
  try {
    final result = await file.readAsString();
    print(result);
    Global.writeData = jsonDecode(result);
    List timeList = Global.writeData["time"].split("-");
    print(timeList);
  } catch (e) {
    await file.create(recursive: true);
  }
}
