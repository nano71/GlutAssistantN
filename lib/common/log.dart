import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:synchronized/synchronized.dart';

class Log {
  static bool sharing = false;
  static List<Map<String, String>> list = [];
  static Directory? directory;

  static void record(String line) {
    stdout.writeln("record");
    final currentTime = DateTime.now().toIso8601String();
    list.add({
      "datetime": currentTime,
      "message": line,
    });
  }

  static final logLock = Lock();

  static Future<void> writeToFile() async {
    return logLock.synchronized(() async {
      try {
        directory ??= await getApplicationSupportDirectory();
        final file = File('${directory!.path}/log.jsonl');

        if (list.isEmpty) return;

        final buffer = StringBuffer();
        for (final log in list) {
          buffer.writeln(jsonEncode(log));
        }

        await file.writeAsString(
          buffer.toString(),
          mode: FileMode.append,
          flush: true,
        );

        list.clear();
      } catch (e, s) {
        print('writeLog error: $e');
        print(s);
      }
    });
  }

  static Future<bool> shareLogFile() async {
    if (sharing) return false;
    sharing = true;
    print('shareLogFile');

    await writeToFile();
    final logFilePath = await _gzipJsonlFile();
    final file = XFile(logFilePath);
    final ShareParams shareParams = ShareParams(files: [file], subject: '导出日志', text: '一份 JSONL 格式的日志文件');
    final result = await SharePlus.instance.share(shareParams);
    File(logFilePath).delete();
    print('shareLogFile end');
    sharing = false;
    return result.status == ShareResultStatus.success;
  }

  static Future<String> _gzipJsonlFile() async {
    // 获取应用的支持目录（可以用来存放日志或其他文件）

    final file = File('${directory!.path}/log.jsonl');

    // 读取文件内容（假设是 JSON 格式）
    String fileContent = await file.readAsString();

    // 将文件内容转为字节
    List<int>? byteData = utf8.encode(fileContent);
    // 设置压缩级别
    final encoder = GZipCodec(level: 9, memLevel: 9);
    // 使用 archive 包压缩数据为 GZIP
    List<int> compressedData = encoder.encode(byteData);
    final currentTime = DateTime.now().toIso8601String();
    final path = '${directory!.path}/${currentTime}.log.jsonl.gz';
    // 创建压缩后的文件（以 .gz 为后缀）
    final compressedFile = File(path);

    // 写入压缩后的数据到文件
    await compressedFile.writeAsBytes(compressedData);
    return path;
  }
}


