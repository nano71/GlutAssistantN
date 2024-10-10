import 'package:workmanager/workmanager.dart';
import 'homeWidget.dart';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print("执行任务: $task");

    try {
      await backstageRefresh();
    } catch (error) {
      print('callbackDispatcher: ' + error.toString());
      throw Exception(error);
    }

    return Future.value(true);
  });
}
