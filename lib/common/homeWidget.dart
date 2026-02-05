import 'dart:async';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:glutassistantn/pages/layout.dart';
import 'package:home_widget/home_widget.dart';

import '../config.dart';
import '../data.dart';
import '../type/course.dart';
import '../widget/lists.dart';
import 'log.dart';

@pragma("vm:entry-point")
void backgroundCallback(Uri? data) async {
  print("backgroundCallback: ${data?.host}");
  if (data?.host == "refresh") {
    backstageRefresh();
  }
}

Future<void> backstageRefresh() async {
  await runZoned(
    () async {
      print('backstageRefresh');
      await reinitialize();
      HomeWidgetUtils.updateWidgetContent();
      await Log.writeToFile();
    },
    zoneSpecification: new ZoneSpecification(print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      parent.print(zone, line);
      Log.record(line);
    }),
  );
}

List<List<String>> _customParser(List<Course> originalData, [bool isTodaySchedule = true]) {
  print('_customParser');
  List<List<String>> processedData = [];

  for (int i = 0; i < originalData.length; i++) {
    Course course = originalData[i];
    if (!isTodaySchedule) {

      processedData.add([
        course.name,
        course.location,
        course.index.toString(),
      ]);
      continue;
    }
    List status = timeUntilNextClass(course.index);
    if (status.last == "after") {
      if (i < originalData.length - 1 && i % 2 == 0) {
        Course nextCourse = originalData[i + 1];
        List lastStatus = timeUntilNextClass(nextCourse.index);
        if (nextCourse.name == course.name &&
            nextCourse.teacher == course.teacher &&
            nextCourse.location == course.location &&
            (lastStatus.last == "before" || lastStatus[2] > 0)) {

          processedData.add([
            course.name,
            course.location,
            course.index.toString(),
          ]);
          processedData.add([
            nextCourse.name,
            nextCourse.location,
            nextCourse.index.toString(),
          ]);
          i++;
          continue;
        }
      }
      if (status.last != "before" && status[2] > 0) {
        processedData.add([
          course.name,
          course.location,
          course.index.toString(),
        ]);
      }
    } else {
      processedData.add([
        course.name,
        course.location,
        course.index.toString(),
      ]);
    }
  }
  print("preSendData: $processedData");
  print('_customParser End');

  return processedData;
}

class HomeWidgetUtils {
  static late String nullSymbol = '{"value":[]}';
  static const platform = MethodChannel("com.nano71.glutassistantn/widget_check");

  static Future<bool> isWidgetAdded() async {
    try {
      final bool result = await platform.invokeMethod('isWidgetAdded');
      return result;
    } on PlatformException catch (e) {
      print("Failed to check widget status: '${e.message}'.");
      return false;
    }
  }

  static void updateWidgetContent() {
    print('HomeWidgetUtils.updateWidgetContent');
    // if (!AppData.isLoggedIn) {
    //   print('Appwidget.updateWidgetContent.!isLoggedIn');
    //   commitUpdateWidgetTask(title: AppConfig.appTitle, message: AppConfig.notLoginError);
    //   return;
    // }

    List<Course> deepCopy(List<Course> list) {
      return List.from(list);
    }
    deepCopy(AppData.todaySchedule);
    String title = "今天的课表";
    List<List> originalData = _customParser(deepCopy(AppData.todaySchedule));
    if (originalData.isEmpty) {
      title = "明天的课表";
      originalData = _customParser(deepCopy(AppData.tomorrowSchedule), false);
      if (originalData.isEmpty) {
        print('HomeWidgetUtils.updateWidgetContent.originalData.isEmpty');
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
    print('HomeWidgetUtils.commitUpdateWidgetTask');
    HomeWidget.saveWidgetData<String>("title", title);
    HomeWidget.saveWidgetData<String>("message", message);
    HomeWidget.updateWidget(
      qualifiedAndroidName: 'com.nano71.glutassistantn.HomeWidgetProvider',
    );
  }

  static void updateTodaySchedule(List<List> originalData) {
    print('HomeWidgetUtils.updateTodaySchedule');
    updateTemplateOfList("todaySchedule", originalData);
  }

  static void updateTomorrowSchedule(List<List> originalData) {
    print('HomeWidgetUtils.updateTomorrowSchedule');
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
