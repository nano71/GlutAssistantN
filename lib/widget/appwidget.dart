import 'dart:convert';

import 'package:glutassistantn/widget/lists.dart';
import 'package:home_widget/home_widget.dart';
import 'package:workmanager/workmanager.dart';

import '../config.dart';
import '../data.dart';

@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  print(data?.host);
  Appwidget.updateWidgetContent();
}

/// Used for Background Updates using Workmanager Plugin
@pragma("vm:entry-point")
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) {
    final now = DateTime.now();
    return Future.wait<bool?>([
      Appwidget.commitUpdateWidgetTask()
    ]).then((value) {
      return !value.contains(false);
    });
  });
}

class Appwidget {
  static late List<List> originalData;

  static void updateWidgetContent() {
    print('Appwidget.updateWidgetContent');
    if (!isLogin()) {
      HomeWidget.saveWidgetData<String>("title", AppConfig.appTitle);
      HomeWidget.saveWidgetData<String>("message", AppConfig.notLoginError);
      return;
    }
    List<List> deepCopy(List object) {
      return object.map((item) => List.from(item)).toList();
    }
    String title = "今天的课表";
    originalData = deepCopy(AppData.todaySchedule);

    if (originalData.isEmpty) {
      title = "明天的课表";
      originalData = deepCopy(AppData.tomorrowSchedule);
      if (originalData.isEmpty) {
        title = "这两天没课~";
        return;
      }
      updateTomorrowSchedule();
    } else {
      updateTodaySchedule();
    }
    HomeWidget.saveWidgetData<String>("title", title);
    commitUpdateWidgetTask();
  }
  static commitUpdateWidgetTask(){
    HomeWidget.updateWidget(
      qualifiedAndroidName: 'com.nano71.glutassistantn.HomeWidgetExampleProvider',
    );
  }
  static void updateTodaySchedule() {
    updateTemplateOfList("todaySchedule", originalData);
  }

  static void updateTomorrowSchedule() {
    updateTemplateOfList("tomorrowSchedule", originalData);
  }

  static void updateTemplateOfList(String id, List<List> list) {
    HomeWidget.saveWidgetData<String>(
        id,
        '{"value":' +
            jsonEncode(list.map((List list) {
              print(list);
              list.removeAt(3);
              list.removeAt(1);
              list.add(timeUntilNextClass(list.last).last);
              return list;
            }).toList()) +
            "}");
  }
}
