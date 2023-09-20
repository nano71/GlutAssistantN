import 'package:workmanager/workmanager.dart';

import '../widget/appwidget.dart';

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    return Future.wait<bool?>([
      Appwidget.commitUpdateWidgetTask()
    ]).then((value) {
      return !value.contains(false);
    });
  });
}
