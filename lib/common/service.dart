import 'package:glutassistantn/common/notification.dart';
import 'package:workmanager/workmanager.dart';

void initService() {
  Workmanager().initialize(
    callbackDispatcher,
  );
  Workmanager().registerPeriodicTask(
    "periodicTaskIdentifier",
    "simplePeriodicTask",
    frequency: Duration(minutes: 15),
  );
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) {
    print(task);
    CustomNotification.send("上课提醒", "上课啦");
    return Future.value(true);
  });
}
