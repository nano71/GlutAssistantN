import 'package:workmanager/workmanager.dart';
import 'homeWidget.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("执行任务: $task");
    try {
      await backstageRefresh();
      print("完成任务: $task");
      return Future.value(true);
    } catch (error) {
      print("任务执行失败: $error");
      return Future.value(false);
    }
  });
}
