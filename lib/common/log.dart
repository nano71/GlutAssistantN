import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

List<String>logList = [];

void record(String line) {
  final currentTime = DateTime.now().toIso8601String();
  final logMessage = '$currentTime: $line';
  logList.add(logMessage);
}

Future<void> writeLog() async {
  // 获取应用的文档目录
  final directory = await getApplicationDocumentsDirectory();
  final file = File('${directory.path}/app_log.txt');

  // 将 logList 中的所有日志写入文件
  final logContent = logList.join('\n');  // 合并日志列表为一个字符串，每个日志一行

  // 写入日志到文件，mode: FileMode.append 会追加内容到文件末尾
  await file.writeAsString(logContent, mode: FileMode.append);

  // 清空日志列表（如果你希望写入文件后清空日志）
  logList.clear();
}
