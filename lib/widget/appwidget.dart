import 'dart:convert';

import 'package:glutassistantn/common/io.dart';
import 'package:home_widget/home_widget.dart';

import '../common/init.dart';
import '../config.dart';
import '../data.dart';
import 'lists.dart';

@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  print('backgroundCallback');
  print(data?.host);
  if (data?.host == "refresh") {
    await readConfig();
    await readSchedule();
    await initTodaySchedule();
    await initTomorrowSchedule();

    Appwidget.updateWidgetContent(true);
  }
}

List<List> _customParser(List<List> originalData, [bool isTodaySchedule = true]) {
  List<List> processedData = [];

  for (int i = 0; i < originalData.length; i++) {
    List item = originalData[i];
    if (!isTodaySchedule) {
      item.removeAt(1);
      item.removeAt(2);
      processedData.add(item);
      continue;
    }
    List status = timeUntilNextClass(item.last);
    if (status.last == "after") {
      if (i < originalData.length - 1 && i % 2 == 0) {
        List nextItem = originalData[i + 1];
        List lastStatus = timeUntilNextClass(nextItem.last);
        if (nextItem[0] == item[0] && nextItem[1] == item[1] && nextItem[2] == item[2] && (lastStatus.last == "before" || lastStatus[2] > 0)) {
          item.removeAt(1);
          item.removeAt(2);
          processedData.add(item);
          nextItem.removeAt(1);
          nextItem.removeAt(2);
          processedData.add(nextItem);
          i++;
          continue;
        }
      }
      if (status.last != "before" && status[2] > 0) {
        item.removeAt(1);
        item.removeAt(2);
        processedData.add(item);
      }
    } else {
      item.removeAt(1);
      item.removeAt(2);
      processedData.add(item);
    }
  }
  print("preSendData:");
  print(processedData);
  return processedData;
}

class Appwidget {

  static late String nullSymbol = '{"value":[]}';

  static void updateWidgetContent([bool isBackgroundRefresh = false]) {
    print('Appwidget.updateWidgetContent');
    if (!isLogin()) {
      print('Appwidget.updateWidgetContent.!isLogin');
      commitUpdateWidgetTask(title: AppConfig.appTitle, message: AppConfig.notLoginError);
      return;
    }
    if (isBackgroundRefresh) {
      print('Appwidget.updateWidgetContent.isBackgroundRefresh');
      HomeWidget.saveWidgetData<String>("backgroundRefresh", "1");
    } else {
      HomeWidget.saveWidgetData<String>("backgroundRefresh", "0");
    }
    List<List> deepCopy(List object) {
      return object.map((item) => List.from(item)).toList();
    }

    String title = "今天的课表";
    List<List> originalData = _customParser(deepCopy(AppData.todaySchedule));

    if (originalData.isEmpty) {
      title = "明天的课表";
      originalData = _customParser(deepCopy(AppData.tomorrowSchedule), false);
      if (originalData.isEmpty) {
        print('Appwidget.updateWidgetContent.originalData.isEmpty');
        removeSchedules();
        commitUpdateWidgetTask(title: AppConfig.appTitle, message: "真没课啦~");
        return;
      }
      updateTomorrowSchedule(originalData);
    } else {
      updateTodaySchedule(originalData);
    }
    commitUpdateWidgetTask(title: title);
  }

  static commitUpdateWidgetTask({String title = "", String message = ""}) {
    print('Appwidget.commitUpdateWidgetTask');
    HomeWidget.saveWidgetData<String>("title", title);
    HomeWidget.saveWidgetData<String>("message", message);
    HomeWidget.updateWidget(
      qualifiedAndroidName: 'com.nano71.glutassistantn.HomeWidgetExampleProvider',
    );
  }

  static void updateTodaySchedule(List<List> originalData) {
    print('Appwidget.updateTodaySchedule');
    updateTemplateOfList("todaySchedule", originalData);
  }

  static void updateTomorrowSchedule(List<List> originalData) {
    print('Appwidget.updateTomorrowSchedule');
    print(originalData);
    updateTemplateOfList("tomorrowSchedule", originalData);
  }

  static void updateTemplateOfList(String id, List<List> list) {
    removeSchedules();

    HomeWidget.saveWidgetData<String>(id, '{"value":' + jsonEncode(list) + "}");
  }

  static void removeSchedules() {
    HomeWidget.saveWidgetData<String>("todaySchedule", nullSymbol);
    HomeWidget.saveWidgetData<String>("tomorrowSchedule", nullSymbol);
    HomeWidget.saveWidgetData<String>("message", "");
  }
}
