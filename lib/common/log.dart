import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

bool sharing = false;
final int maxLogCount = 10000;
List<Map<String, String>> logList = [];
List<Map<String, String>> backupLogList = [];
bool isWritingLog = false;
Directory? directory;

void record(String line) {
  final currentTime = DateTime.now().toIso8601String();
  final logMessage = {"datetime": currentTime, "message": line};
  if (isWritingLog) {
    backupLogList.add(logMessage);
  } else {
    logList.add(logMessage);
  }
}

Future<void> writeLog() async {
  print('writeLog');
  if (isWritingLog) {
    return;
  }

  isWritingLog = true;

  if (directory == null) {
    directory = await getApplicationSupportDirectory();
  }
  final file = File('${directory!.path}/log.json');

  if (await file.exists()) {
    final fileContent = await file.readAsString();
    List<dynamic> jsonList = jsonDecode(fileContent);

    jsonList.addAll(logList);

    if (jsonList.length > maxLogCount) {
      jsonList.removeRange(0, jsonList.length - maxLogCount);
    }

    final jsonString = jsonEncode(jsonList);
    await file.writeAsString(jsonString);
  } else {
    final jsonString = jsonEncode(logList);
    await file.writeAsString(jsonString);
  }

  logList.clear(); // 清空备用日志列表
  logList.addAll(backupLogList);
  isWritingLog = false; // 写入完成，恢复为非写入状态
  print('writeLog end');
}

Future<bool> shareLogFile() async {
  if (sharing) return false;
  sharing = true;
  print('shareLogFile');

  await writeLog();
  final logFilePath = await gzipJsonFile();
  final file = XFile(logFilePath);
  final result = await Share.shareXFiles([file], subject: '导出日志', text: '一份 JSON 格式的日志文件');
  File(logFilePath).delete();
  print('shareLogFile end');
  sharing = false;
  return result.status == ShareResultStatus.success;
}

Future<String> gzipJsonFile() async {
  // 获取应用的支持目录（可以用来存放日志或其他文件）

  final file = File('${directory!.path}/log.json');

  // 读取文件内容（假设是 JSON 格式）
  String fileContent = await file.readAsString();

  // 将文件内容转为字节
  List<int>? byteData = utf8.encode(fileContent);
  // 设置压缩级别
  final encoder = GZipCodec(level: 9, memLevel: 9);
  // 使用 archive 包压缩数据为 GZIP
  List<int> compressedData = encoder.encode(byteData);
  final currentTime = DateTime.now().toIso8601String();
  final path = '${directory!.path}/${currentTime}.log.json.gz';
  // 创建压缩后的文件（以 .gz 为后缀）
  final compressedFile = File(path);

  // 写入压缩后的数据到文件
  await compressedFile.writeAsBytes(compressedData);
  return path;
}
