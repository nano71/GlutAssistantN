import 'dart:io';
import 'package:path_provider/path_provider.dart';

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

/// 获取应用程序目录文件
Future<File> _getLocalSupportFile() async {
  final dir = await getApplicationSupportDirectory();
  return File('${dir.path}/table.json');
}

/// 写入数据
Future<void> writeString(String str) async {
  final file = await _getLocalSupportFile();
  await file.writeAsString(str);
}

Future readString() async {
    final file = await _getLocalSupportFile();
    final result  = await file.readAsString();
    return result;
}
