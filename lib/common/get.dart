import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart' hide Element;
import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:glutassistantn/type/classroom.dart';
import 'package:glutassistantn/type/exam.dart';
import 'package:glutassistantn/type/schedule.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

import '/common/cookie.dart';
import '/common/io.dart';
import '/common/parser.dart';
import '../config.dart';
import '../data.dart';
import '../pages/about.dart';
import '../pages/update.dart';
import '../type/course.dart';
import '../type/teachingPlan.dart';
import '../widget/bars.dart';

Future getRecentExams() async {
  print("getRecentExams");
  Response response;
  try {
    response = await request("get", Uri.http(AppConfig.serverHost, AppConfig.recentExamsPath));
    Document document = parse(getHtml(response));
    List<Element> items = document.querySelectorAll("tr.infolist_common");
    if (items.length > 0) {
      List<Map<String, String>> examList = [];
      for (Element value in items) {
        Map<String, String> cache = {"name": "", "time": "", "location": "", "type": ""};
        int i = -1;
        List<String> keys = ["name", "time", "location", "type"];
        value.querySelectorAll("td").forEach((element) {
          print(element.innerHtml);
          element.innerHtml = element.innerHtml.replaceAll("&nbsp;", "").trim();
          if (element.innerHtml == "") return;
          if (i > -1) {
            cache[keys[i]] = element.innerHtml;
          }
          i++;
        });
        examList.add(cache);
      }
      print(examList);
      print("getRecentExams End");
    } else {
      print("未登录教务");
    }
  } catch (e) {
    print("失败");
    print(e);
  }
}

Future<void> getWeek() async {
  print("getWeek");
  Response response;
  try {
    response = await request("get", AppConfig.currentWeekUri);
  } catch (e) {
    print("失败");
    print(e);
    return;
  }
  Document document = parse(getHtml(response));
  String weekHtml;
  Element? span = document.querySelector("#date p span");
  if (span != null) {
    weekHtml = span.text.trim();
  } else {
    print("getWeek End else");
    return;
  }
  String week = "0";
  String year = "";
  String semester = "";
  if (weekHtml.length >= 5 && weekHtml.contains("第") && weekHtml.contains("周")) {
    week = weekHtml
        .substring(
          weekHtml.indexOf("第") + 1,
          weekHtml.indexOf("周"),
        )
        .trim();
    year = weekHtml.substring(0, 4).trim();
    semester = weekHtml.substring(4, 5);
  } else {
    print("getWeek End else 2");
    return;
  }
  AppData.week = int.tryParse(week) ?? 0;
  AppData.year = int.parse(year);
  AppData.semester = semester;

  if (AppData.queryYear == "") {
    AppData.queryYear = year;
  }

  if (AppData.querySemester == "") {
    AppData.querySemester = semester;
  }

  // print(AppData.persistentData);
  print("getWeek Save: ${week + "周"}");
  await writeConfig();
  print("getWeek End");
}

Future<dynamic> getSchedule([BuildContext? context]) async {
  if (!await checkLoginValidity()) return false;
  print("getSchedule");
  List<List<List<Course>>> schedule = List.from(AppData.schedule);
  Map<String, int> weekTextMap = {
    "星期一": 1,
    "星期二": 2,
    "星期三": 3,
    "星期四": 4,
    "星期五": 5,
    "星期六": 6,
    "星期日": 7,
  };
  Uri uri = Uri.http(AppConfig.serverHost, AppConfig.schedulePath,
      {"year": (AppData.year - 1980).toString(), "term": AppData.semester == "秋" ? "3" : "1"});
  Response response;
  try {
    response = await request("", uri);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  } catch (e) {
    print("连接失败");
    print(e);
    return "未知异常";
  }
  String html = getHtml(response);
  if (html == "") return AppConfig.unknownDataErrorMessage;
  Document document = parse(html);
  List<Element> rows = document.querySelectorAll(".infolist_common");

  int rowsLength = rows.length - 23;
  if (rowsLength > 1) {
    schedule = createEmptySchedule();
  }
  for (int i = 0; i < rowsLength; i++) {
    parse() {
      List<String> texts = rows[i].children.map((element) => element.innerHtml.trim()).toList();
      List<String> texts2 = rows[i].children.map((element) => element.text.trim()).toList();
      List<Element> tableRows = rows[i].querySelectorAll("table.none > tbody > tr");

      for (var j = 0; j < tableRows.length; j++) {
        Element row = tableRows[j];
        List<String> texts3 =
            row.children.map((element) => element.innerHtml.trim().replaceAll(RegExp(r'([第节周])'), "")).toList();

        if ((texts3[1] + texts3[2] + texts3[3]).contains("nbsp")) {
          continue;
        }

        //课区间 interval
        String lessonInterval = texts3[2];
        //周次区间
        String weekInterval = texts3[0];
        //课节

        List<int> lessonList = lessonInterval.split("-").map((lesson) => int.tryParse(lesson) ?? 0).toList();
        //周次 1-9周 = [1,9]
        List<int> weekList = [];
        String weekText = texts3[1];
        String location = teachLocation(texts3[3]);
        bool specialWeek = true;

        // List<String> initList(bool isEven) {
        //   List<String> list = [];
        //   for (int i = int.parse(weekList.first); i <= int.parse(weekList.last); i++) {
        //     if (isEven ? i.isEven : i.isOdd) {
        //       list.add(i.toString());
        //     }
        //   }
        //   return list;
        // }

        void step3BySection(String section) {
          List<String> range = section.split("-");
          if (range.length == 2) {
            for (int i = int.parse(range[0]); i <= int.parse(range[1]); i++) {
              weekList.add(i);
            }
          } else if (range.length == 1) {
            weekList.add(int.parse(range[0]));
          }
        }

        void step3() {
          List<String> cache = weekInterval.split(",");
          for (String section in cache) {
            step3BySection(section);
          }
        }

        void handleSingleOrDouble(String section, bool isEven) {
          String key = isEven ? "双" : "单";
          section = section.replaceAll(key, ""); // 去掉“单”或“双”关键字
          List<String> range = section.split("-");

          if (range.length == 2) {
            for (int i = int.parse(range[0]); i <= int.parse(range[1]); i++) {
              if (isEven ? i.isEven : i.isOdd) {
                weekList.add(i);
              }
            }
          } else if (range.length == 1) {
            int week = int.parse(range[0]);
            if (week.isEven == isEven) {
              weekList.add(week);
            }
          }
        }

        void step4() {
          List<String> cache = weekInterval.split(","); // 按逗号分隔区间
          weekList = []; // 初始化周数列表

          for (String section in cache) {
            if (section.contains("单")) {
              handleSingleOrDouble(section, false); // 处理“单”周
            } else if (section.contains("双")) {
              handleSingleOrDouble(section, true); // 处理“双”周
            } else {
              step3BySection(section); // 处理普通区间
            }
          }
        }
        // weekInterval = "11-14,15-17单";
        // weekInterval = "11";
        // weekInterval = "11-14双,15-17单";
        // weekInterval = "11,15-17双";
        // switch (i) {
        //   case 0:
        //     weekInterval = "11-14,15-17单";
        //     break;
        //   case 1:
        //     weekInterval = "11-14双,15-17单";
        //     break;
        //   case 2:
        //     weekInterval = "11-14,16-17";
        //     break;
        //   case 3:
        //     weekInterval = "11";
        //     break;
        // }

        //单周
        if (weekInterval.contains("单") || weekInterval.contains("双")) {
          step4(); // 混合“单/双”处理
        } else if (weekInterval.contains(",")) {
          step3(); // 普通区间处理
        } else {
          specialWeek = false;
          weekList = weekInterval.split("-").map((source) => int.tryParse(source) ?? 0).toList();
        }

        if (lessonList.length > 1) {
          int? week = weekTextMap[weekText];
          if (week != null) {
            for (int lesson = lessonList[0]; lesson <= lessonList[1]; lesson++) {
              Course course = Course(
                  name: texts2[2],
                  teacher: texts2[3],
                  location: location,
                  extra: row.text.trim().replaceAll(" ", ";"),
                  index: lesson);

              // 普通模式
              if ((weekList.length > 1 && specialWeek) || weekList.length >= 3) {
                for (int teachWeek in weekList) {
                  // print(teachWeek);
                  schedule[teachWeek][week][lesson] = course;
                }
                // 区间模式
              } else if (weekList.length == 2) {
                for (int teachWeek = weekList[0]; teachWeek <= weekList[1]; teachWeek++) {
                  schedule[teachWeek][week][lesson] = course;
                }
                // 一周模式
              } else {
                schedule[int.tryParse(weekInterval) ?? 0][week][lesson] = course;
              }
            }
          }
        }
      }
    }

    try {
      parse();
    } catch (e) {
      if (context != null) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBarWithActionText(false, "部分课表解析出错!", "反馈", context, () {
          Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutPage()));
        }, margin: 80, isDialogCallback: false, duration: 4));
        await Future.delayed(const Duration(seconds: 4));
      }
      print('getSchedule parse Error');
      print(e);
    }
  }
  // print(AppData.persistentData);
  String query = document.querySelector(".button[value='班级课表']")!.attributes["onclick"]!.split("?")[1];
  final Map<String, dynamic> queryMap = Uri.splitQueryString(query);
  AppData.schedule = await getScheduleChanges(queryMap['id'], schedule);
  print("getSchedule End");
  return true;
}

Future<List<List<List<Course>>>> getScheduleChanges(String id, List<List<List<Course>>> schedule) async {
  if (!AppData.showScheduleChange) {
    return schedule;
  }
  print('getScheduleChanges');
  print("获取课表变更(调课/停课/补课)");
  Uri uri = Uri.http(AppConfig.serverHost, AppConfig.classReschedulePath, {
    "id": id,
    "yearid": (AppData.year - 1980).toString(),
    "termid": AppData.semester == "秋" ? "3" : "1",
    "timetableType": "CLASSES",
    "sectionType": "COMBINE"
  });
  Response response;
  try {
    response = await request("get", uri);
  } catch (e) {
    print('getScheduleChanges Error');
    print(e);
    return schedule;
  }

  Document document = parse(gbk.decode(response.bodyBytes));
  if (document.querySelector("table.error") != null) {
    return schedule;
  }
  List<Element> tableList = document.querySelectorAll(".infolist_hr");
  if (tableList.length >= 3) {
    Element table = tableList[2];
    List<Element> rowList = table.querySelectorAll(".infolist_hr_common");
    String course = "";
    String teacher = "";
    rowList.forEach((row) {
      List<Element> cellList = row.querySelectorAll("td");
      List<String> texts = row.querySelectorAll("td").map((element) => element.innerHtml.trim()).toList();
      int length = cellList.length;
      final Map<String, bool> rowInfo = {"standard": length == 17, "extension": length == 10};
      // print(rowInfo);
      String remark(String teachWeek, String location, int i, int j) {
        return "第" +
            teachWeek.replaceAll(RegExp(r'[第周]'), "") +
            "周;" +
            texts[i] +
            ";" +
            texts[j] +
            " - 调课/补课;$location";
      }

      if (rowInfo["standard"]!) {
        String location = teachLocation(texts[16]);

        CourseTimeSlot latest =
            CourseTimeSlot(week: texts[13], weekDay: weekTextToNumber(texts[14]), periods: teachTimeParser(texts[15]));
        CourseTimeSlot before =
            CourseTimeSlot(week: texts[8], weekDay: weekTextToNumber(texts[9]), periods: teachTimeParser(texts[10]));

        teacher = texts[4];
        course = texts[2];

        if (before.week != "&nbsp;") {
          print("删除${before.toJson()}");
          for (int lesson = before.periods[0]; lesson <= before.periods[1]; lesson++) {
            schedule[int.tryParse(before.week) ?? 0][before.weekDay][lesson] = Course(index: lesson);
          }
        }
        if (latest.week != "&nbsp;") {
          print("添加${latest.toJson()}");
          for (int lesson = latest.periods[0]; lesson <= latest.periods[1]; lesson++) {
            schedule[int.tryParse(latest.week) ?? 0][latest.weekDay][lesson] = Course(
                name: course,
                teacher: teacher,
                location: location,
                extra: remark(latest.week, location, 14, 15),
                index: lesson);
          }
        }
      } else if (rowInfo["extension"]!) {
        //周
        String oldCourseWeek = texts[1];
        String newCourseWeek = texts[6];
        //星期
        int oldCourseWeekDay = weekTextToNumber(texts[2]);
        int newWeekDay = weekTextToNumber(texts[7]);
        //课节
        List<int> oldCourseLessonList = teachTimeParser(texts[3]);
        List<int> newCourseLessonList = teachTimeParser(texts[8]);
        //教室
        String newLocation = teachLocation(texts[9]);

        if (oldCourseWeek != "&nbsp;") {
          for (int i = oldCourseLessonList[0]; i <= oldCourseLessonList[1]; i++) {
            schedule[int.tryParse(oldCourseWeek) ?? 0][oldCourseWeekDay][i] = Course(index: i);
          }
        }
        if (newCourseWeek != "&nbsp;") {
          for (int i = newCourseLessonList[0]; i <= newCourseLessonList[1]; i++) {
            schedule[int.tryParse(newCourseWeek) ?? 0][newWeekDay][i] = Course(
                name: course,
                teacher: teacher,
                location: newLocation,
                extra: remark(newCourseWeek, newLocation, 7, 8),
                index: i);
          }
        }
      }
    });
  }
  print('getScheduleChanges End');
  return schedule;
}

Future<void> getStudentName() async {
  print('getName');
  try {
    Response response = await request("get", AppConfig.studentInfoUri);
    AppData.studentName = parse(response.body).querySelector('[name="realname"]')!.parentNode!.text ?? "";
    print('getName End');
  } catch (e) {
    print('getName Error');
    print(e);
  }
}

Future getScores() async {
  if (!await checkLoginValidity()) return false;
  print("getScores");
  String year = "";
  String semesterNumber = "";
  if (AppData.queryYear != "全部") {
    year = (int.parse(AppData.queryYear) - 1980).toString();
  }
  if (AppData.querySemester != "全部") {
    semesterNumber = (AppData.querySemester == "秋" ? 3 : 1).toString();
  }
  Map<String, String> postData = {
    "year": year,
    "term": semesterNumber,
    "prop": "",
    "groupName": "",
    "para": "0",
    "sortColumn": "",
    "Submit": "查询"
  };
  Response response;
  try {
    response = await request("post", AppConfig.scoreQueryUri, body: postData);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  } catch (e) {
    print("连接失败");
    print(e);
    return "未知异常";
  }
  String html = response.body;
  if (html == "") return AppConfig.unknownDataErrorMessage;
  if (html.contains("提示信息")) return AppConfig.retryErrorMessage;
  Document document = parse(html);
  List<Element> rows = document.querySelectorAll(".datalist > tbody > tr");
  List<CourseScore> scores = [];
  for (int i = 1; i < rows.length; i++) {
    List<String> texts = rows[i].children.map((Element element) => element.text.trim()).toList();
    if (texts[9].contains("免考")) {
      texts[5] = "合格";
    }
    scores.add(CourseScore(
      courseCode: texts[2],
      courseName: texts[3],
      teacher: texts[4],
      score: double.tryParse(levelToNumber(texts[5])) ?? 0,
      rawScore: texts[5],
      gradePoint: double.tryParse(texts[6]) ?? 0,
      credit: double.tryParse(texts[7]) ?? 0,
      courseCategory: texts[11],
    ));
  }
  print("getScores End");
  return scores;
}

Future<dynamic> getExams() async {
  if (!await checkLoginValidity()) return false;
  print("getExams");
  Response response;
  try {
    response = await request("post", AppConfig.examListUri);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  } catch (e) {
    print("连接失败");
    print(e);
    return "未知异常";
  }
  String html = getHtml(response);
  if (html == "") return AppConfig.unknownDataErrorMessage;
  Document document = parse(html);
  examList = [];
  examList2 = [];
  completedExamCount = 0;
  upcomingExamCount = 0;
  document = parse(response.body);
  examList = [];
  List<Element> rows = document.querySelectorAll(".datalist> tbody > tr");

  for (int i = 1; i < rows.length; i++) {
    List<String> texts = rows[i].children.map((element) => element.innerHtml.trim().replaceAll("&nbsp;", " ")).toList();
    bool isPast = false;
    try {
      DateTime now = DateTime.now();
      List<String> parts = texts[2].split(' ');
      String datePart = parts[0];
      List<String> times = parts[1].split('--');
      DateTime endTime = DateTime.parse('$datePart ${times[1]}');
      isPast = now.isAfter(endTime);
    } catch (e) {
      print("getExams Error: 解析失败:${texts[2]}");
    }

    if (isPast) {
      completedExamCount++;
    } else {
      upcomingExamCount++;
    }

    examList.add(Exam(
      courseName: texts[1],
      timeRange: texts[2],
      location: texts[3].split(" ").last,
      isPast: isPast,
    ));
  }
  print("getExams End");
  return true;
}

Future getTeachingPlan() async {
  if (!await checkLoginValidity()) return false;
  print("getTeachingPlan");
  Future next(String studentId, String classId) async {
    Response response;
    try {
      response = await request(
          "get",
          Uri.http(AppConfig.serverHost, AppConfig.studySchedulePath,
              {"z": "z", "studentId": studentId, "classId": classId}));
    } on TimeoutException catch (e) {
      return timeOutError(e);
    } on SocketException catch (e) {
      return socketError(e);
    }

    Document document = parse(response.bodyBytes);
    List<List<String>> list = [];
    courseCountsByScore = [0, 0, 0, 0];

    document.querySelectorAll("img.no_output").forEach((Element element) {
      if (element.parent!.innerHtml.contains("/academic/styles/images/course_failed.png") ||
          element.parent!.innerHtml.contains("/academic/styles/images/course_failed_reelect.png")) {
        //重修&&不及格
        courseCountsByScore[0]++;
      }
      if (element.parent!.innerHtml.contains("/academic/styles/images/course_pass.png") ||
          element.parent!.innerHtml.contains("/academic/styles/images/course_pass_reelect.png")) {
        //合格
        courseCountsByScore[1]++;
      }
      if (element.parent!.innerHtml.contains("/academic/styles/images/course_unknown_pass.png")) {
        //成绩未知
        courseCountsByScore[2]++;
      }
    });

    List<Element> baseInfos = document.querySelectorAll("table.datalist tr:last-child > td");
    TeachingPlan.department = baseInfos[0].text;
    TeachingPlan.major = baseInfos[1].text;
    TeachingPlan.grade = int.parse(onlyDigits(baseInfos[2].text));
    TeachingPlan.educationalLevel = baseInfos[3].text;

    List<List<CourseInfo>> courseInfoListBySemester = [];
    int semesterCount = 0;

    document.querySelectorAll("table.datalist.output_ctx tbody tr").forEach((Element row) {
      List<String> rowTexts = row.querySelectorAll("td").map((element) => removeSpace(element.text).trim()).toList();
      if (rowTexts.length == 1 && rowTexts[0].contains("学年")) {
        semesterCount += 1;
        courseInfoListBySemester.add([]);
        return;
      }

      if (rowTexts.length > 1) {
        TeachingPlan.totalCourseCount++;
        if (rowTexts[2].contains("考试")) {
          TeachingPlan.totalExamCount++;
        }
        if (rowTexts[5].contains("专业")) {
          TeachingPlan.totalMajorCourseCount++;
        }
        courseInfoListBySemester.last.add(CourseInfo(
          code: rowTexts[0],
          name: rowTexts[1],
          assessmentType: rowTexts[2],
          credit: rowTexts[3],
          hours: rowTexts[4].replaceAll(".0", ""),
          category: rowTexts[5],
        ));
      }
    });
    print("semesterCount: $semesterCount");
    TeachingPlan.schoolingLength = (semesterCount / 2).ceil();
    TeachingPlan.courseInfoListBySemester = courseInfoListBySemester;
    int start = 1;
    List newList = [];

    for (int i = 0; i < list.length; i++) {
      if (i != 0 && list[i].length == 2) {
        newList.add(list.sublist(start, i));
        start = i + 1;
      }
      if (i == list.length - 1) {
        newList.add(list.sublist(start, i + 1));
      }
    }
    careerList2 = newList;
    return true;
  }

  Response response;
  try {
    response = await request("get", AppConfig.studyScheduleUri);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  } catch (e) {
    print("连接失败");
    print(e);
    return "未知异常";
  }
  String html = getHtml(response);
  if (html == "") return AppConfig.unknownDataErrorMessage;

  Document document = parse(html);
  Element link = document.querySelector("table.broken_tab a:last-child")!;
  String url = link.attributes["href"]!;
  Map<String, String> queryParameters = Uri.parse(url).queryParameters;
  dynamic result = await next(queryParameters["studentId"]!, queryParameters["classId"]!);
  if (result is String) {
    return result;
  }
  print("getTeachingPlan End");
  return true;
}

Future getFreeClassrooms({
  String dayOfWeek = "1",
  String weekOfSemester = "-1",
  String building = "-1",
  String classroom = "-1",
}) async {
  if (!await checkLoginValidity()) return false;
  // Global.cookie = {};
  print('getEmptyClassroom');
  Map<String, String> postData = {
    "aid": "1",
    "buildingid": building, //1教:10
    "room": classroom, //教室
    "whichweek": weekOfSemester, //第几周
    "week": dayOfWeek, //星期
    "Submit": "确 定"
  };
  print("params: $postData");
  Response response;
  bool weekMode = weekOfSemester != "-1" && dayOfWeek != "-1";
  try {
    if (weekMode) {
      response = await request("post", AppConfig.emptyClassroomWeekUri, body: postData);
    } else {
      response = await request("post", AppConfig.emptyClassroomDayUri, body: postData);
    }
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  } catch (e) {
    print("连接失败");
    print(e);
    return "未知异常";
  }
  String html = getHtml(response);
  if (html == "") return AppConfig.unknownDataErrorMessage;
  Document document = parse(html);
  if (weekMode) {
    List<Element> classrooms = document.querySelectorAll("tr.infolist_common");
    List<Classroom> result = [];
    print("classrooms.length: ${classrooms.length}");

    classrooms.forEach((element) {
      int freeCount = 0;
      List<String> texts = element.querySelectorAll("td").map((element) => element.text.trim()).toList();
      List<bool> occupancy = element.querySelectorAll("td tbody > tr:nth-child(2) > td").map((element) {
        bool isFree = element.innerHtml.contains("&nbsp;");
        if (isFree) {
          freeCount++;
        }
        return !isFree;
      }).toList();

      result.add(Classroom(
        roomNumber: texts[0],
        seatCount: int.tryParse(texts[1]) ?? 0,
        examSeatCount: int.tryParse(texts[3]) ?? 0,
        type: texts[5],
        occupancy: occupancy,
        isAllDayFree: freeCount == 11,
      ));
    });
    print('getEmptyClassroom end');
    return result;
  }
  List<Element> buildingOptions = document.querySelectorAll("#buildingid > option");
  List<Element> classroomOptions = document.querySelectorAll("select[name='room'] > option");
  Map<String?, String> buildingCode = {};
  Map<String?, String> classrooms = {};
  Map<String, Map> results = {"buildingCode": {}, "classrooms": {}};
  buildingOptions.removeAt(0);
  classroomOptions.removeAt(0);
  buildingCode["-1"] = "请选择";
  for (Element element in buildingOptions) {
    buildingCode[element.attributes["value"]] = element.innerHtml;
  }
  for (Element element in classroomOptions) {
    classrooms[element.attributes["value"]] = element.innerHtml;
  }
  results["buildingCode"] = buildingCode;
  results["classrooms"] = classrooms;
  print('getEmptyClassroom end');
  return results;
}

Future<dynamic> getUpdate({bool isRetry = false}) async {
  print("getUpdate");
  Response response;
  try {
    response = await get(isRetry ? AppConfig.appUpdateCheckUri : AppConfig.githubLatestReleaseUri)
        .timeout(Duration(seconds: 4));
  } on TimeoutException catch (e) {
    print("getUpdate Error");
    print(e);
    if (isRetry) {
      return AppConfig.timeoutErrorMessage;
    }
    return getUpdate(isRetry: true);
  } on SocketException catch (e) {
    print("getUpdate Error 2");
    print(e);
    if (isRetry) {
      return AppConfig.networkErrorMessage;
    }
    return getUpdate(isRetry: true);
  } catch (e) {
    print("getUpdate Error 3");
    print(e);
    if (isRetry) {
      return "未知异常";
    }
    return getUpdate(isRetry: true);
  }
  if (response.body.contains('"message":"API rate limit exceeded for')) {
    print("getUpdate Error 4");
    return "频繁的请求!";
  }

  final decodeData = jsonDecode(response.body);
  // print(decodeData);

  AppData.newVersionNumber = decodeData["name"].split("_")[1];
  AppData.newVersionChangelog = decodeData["body"];
  AppData.newVersionDownloadUrl = decodeData["assets"][0]["browser_download_url"].toString();

  print("getUpdate End");
  return true;
}

Future getUpdateByEveryday() async {
  print("getUpdateByEveryday");
  // ignore: dead_code
  await getUpdate();

  checkNewVersion();
  if (AppData.hasNewVersion && AppData.canCheckImportantUpdate) {
    Future.delayed(Duration(seconds: 1), () {
      checkImportantUpdate();
    });
  }

  print("getUpdateByEveryday End");
}

Future<Response> request(String method, Uri uri, {Map<String, String>? body, Encoding? encoding}) async {
  Map<String, String>? headers = {"cookie": mapCookieToString()};
  if (method == "post") {
    return await post(uri, body: body, headers: headers, encoding: encoding)
        .timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
  } else {
    return await get(uri, headers: headers).timeout(Duration(seconds: AppConfig.requestTimeoutSeconds));
  }
}

String getHtml(Response response) {
  return gbk.decode(response.bodyBytes);
}

String timeOutError(e) {
  print("超时");
  print(e);
  return AppConfig.timeoutErrorMessage;
}

String socketError(e) {
  print("连接失败");
  print(e);
  return AppConfig.networkErrorMessage;
}

void getPermissions() async {
  print("getPermissions");
  Response response;
  try {
    response = await request("get", Uri.https(AppConfig.authorUrl, AppConfig.controlConfigPath));
    Map result = jsonDecode(response.body);
    if (!result["permissions"]["all"]) {
      // exit(0);
    } else {
      print("应用已授权");
    }
  } catch (e) {
    print('getPermissions Error');
    print(e);
  }
}

Future<bool> checkLoginValidity() async {
  print("checkLoginValidity");
  Response response;
  try {
    response = await request("get", AppConfig.loginValidityCheckUri);
  } catch (e) {
    print('checkLoginValidity Error');
    print(e);
    return false;
  }
  String html = getHtml(response);
  print("checkLoginValidity End");
  return !html.contains("请重新登录");
}
