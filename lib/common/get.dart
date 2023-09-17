// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_gbk2utf8/flutter_gbk2utf8.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

import '/common/cookie.dart';
import '/common/io.dart';
import '/common/parser.dart';
import '../config.dart';
import '../data.dart';
import '../pages/update.dart';

Future getRecentExam() async {
  print("getRecentExam");
  Response response;
  try {
    response = await request("get", Uri.http(Global.jwUrl, Global.getRecentExam));
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
    } else {
      print("未登录教务");
    }
  } on TimeoutException catch (e) {
    print("超时");
    print(e);
  } on SocketException catch (e) {
    print("连接失败");
    print(e);
  }
}

Future<void> getWeek() async {
  print("getWeek");
  Response response;
  try {
    response = await request("get", Global.getWeekUrl);
  } on TimeoutException catch (e) {
    print("超时");
    print(e);
    return readConfig();
  } on SocketException catch (e) {
    print("连接失败");
    print(e);
    return readConfig();
  }
  Document document = parse(getHtml(response));
  String weekHtml = document.querySelector("#date p span")!.text.trim();
  String week = weekHtml.substring(weekHtml.indexOf("第") + 1, weekHtml.indexOf("周")).trim();
  String n = weekHtml.substring(0, 4).trim();
  String q = weekHtml.substring(4, 5);
  writeData["semester"] = q;
  writeData["year"] = n;
  writeData["week"] = week;
  print(writeData["yearBk"]);
  if (writeData["yearBk"] == "") {
    writeData["yearBk"] = "0";
  } else if (int.parse(writeData["year"]!) > int.parse(writeData["yearBk"]!)) {
    writeData["yearBk"] = n;
  }
  if (writeData["semesterBk"] == "" && writeData["yearBk"] == "") {
    writeData["semesterBk"] = q;
    writeData["yearBk"] = n;
  }
  if (writeData["querySemester"] == "" && writeData["queryYear"] == "") {
    writeData["querySemester"] = q;
    writeData["queryYear"] = n;
  }
  print("getWeek Save");
  await writeConfig();
  print("getWeek End");
}

Future<dynamic> getSchedule() async {
  if (!await checkLoginValidity()) return false;
  print("getSchedule");
  Map _schedule = schedule;
  Map<String, String> _weekList = {"星期一": "1", "星期二": "2", "星期三": "3", "星期四": "4", "星期五": "5", "星期六": "6", "星期日": "7"};
  print(writeData["semesterBk"]);
  print(writeData["yearBk"]);
  Uri uri = Uri.http(
      Global.getScheduleUrl[0], Global.getScheduleUrl[1], {"year": ((int.parse(writeData["year"] ?? "")) - 1980).toString(), "term": writeData["semester"] == "秋" ? "3" : "1"});
  Response response;
  try {
    response = await request("", uri);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  }
  String html = getHtml(response);
  if (html == "") return Global.dataError;
  Document document = parse(html);
  List<Element> list = document.querySelectorAll(".infolist_common");
  List<Element> infoList(int index) => list[index].querySelectorAll("a.infolist");
  String course(int index) => innerHtmlTrim(infoList(index)[0]);

  String teacher(int index) => infoList(index).length > 1 ? innerHtmlTrim(infoList(index)[1]) : "未知";

  String innerHtmlTrimReplace(Element element) => innerHtmlTrim(element).replaceAll(RegExp(r'([第节周])'), "");

  List<Element> tableRows(int index) => list[index].querySelectorAll("table.none>tbody>tr");

  List<Element> tableCells(Element element) => element.querySelectorAll("td");

  String? week(int i, int j) => _weekList[innerHtmlTrim(tableCells(tableRows(i)[j])[1])];

  String remark(int i, int j) => tableRows(i)[j].text.trim().replaceAll(" ", ";");

  int listLength = document.querySelectorAll(".infolist_common").length - 23;
  if (listLength > 1) {
    _schedule = emptySchedule();
  }
  for (int i = 0; i < listLength; i++) {
    for (var j = 0; j < tableRows(i).length; j++) {
      //课区间 interval
      String lessonInterval = innerHtmlTrimReplace(tableCells(tableRows(i)[j])[2]);
      //周次区间
      String weekInterval = innerHtmlTrimReplace(tableCells(tableRows(i)[j])[0]);
      //课节
      List<String> lessonList = lessonInterval.split("-");
      //周次 1-9周 = [1,9]
      List<String> weekList = [];
      String weekCN = innerHtmlTrimReplace(tableCells(tableRows(i)[j])[1]);
      String courseVenue = teachLocation(innerHtmlTrim(tableCells(tableRows(i)[j])[3]));
      bool specialWeek = true;
      List<String> initList(bool isEven) {
        List<String> list = [];
        for (int i = int.parse(weekList.first); i <= int.parse(weekList.last); i++) {
          if (isEven ? i.isEven : i.isOdd) {
            list.add(i.toString());
          }
        }
        return list;
      }

      //单周
      if (weekInterval.indexOf("单") != -1) {
        weekInterval = weekInterval.replaceAll("单", "");
        weekList = weekInterval.split("-");
        weekList = initList(false);
        //双周
      } else if (weekInterval.indexOf("双") != -1) {
        weekInterval = weekInterval.replaceAll("双", "");
        weekList = weekInterval.split("-");
        weekList = initList(true);
      } else if (weekInterval.indexOf(",") != -1) {
        if (weekInterval.indexOf("-") != -1) {
          List<String> cache = weekInterval.split(",");
          for (int i = 0; i < cache.length; i++) {
            if (cache[i].split("-").length == 1) {
              weekList.add(cache[i]);
              continue;
            }
            for (int j = int.parse(cache[i].split("-")[0]); j <= int.parse(cache[i].split("-")[1]); j++) {
              weekList.add(j.toString());
            }
          }
        } else {
          weekInterval = weekInterval.replaceAll(",", "-");
          weekList = weekInterval.split("-");
        }
        print(weekList);
      } else {
        specialWeek = false;
        weekList = weekInterval.split("-");
      }
      if (lessonList.length > 1 && weekCN != "&nbsp;")
        for (int lesson = int.parse(lessonList[0]); lesson <= int.parse(lessonList[1]); lesson++) {
          if (weekList.length > 1 && specialWeek) {
            weekList.forEach((teachWeek) {
              print(teachWeek);
              _schedule[teachWeek.toString()]?[week(i, j)]?[lesson.toString()] = [
                //课程名
                course(i),
                //老师名字
                teacher(i),
                //上课地点
                courseVenue,
                //备注
                remark(i, j)
              ];
            });
          } else if (weekList.length == 2) {
            for (int teachWeek = int.parse(weekList[0]); teachWeek <= int.parse(weekList[1]); teachWeek++) {
              _schedule[teachWeek.toString()]?[week(i, j)]?[lesson.toString()] = [
                //课程名
                course(i),
                //老师名字
                teacher(i),
                //上课地点
                courseVenue,
                //备注
                remark(i, j)
              ];
            }
          } else if (weekList.length >= 3) {
            for (String teachWeek in weekList) {
              print(teachWeek);
              _schedule[teachWeek]?[week(i, j)]?[lesson.toString()] = [
                //课程名
                course(i),
                //老师名字
                teacher(i),
                //上课地点
                courseVenue,
                //备注
                remark(i, j)
              ];
            }
          } else {
            _schedule[weekInterval]?[week(i, j)]?[lesson.toString()] = [
              //课程名
              course(i),
              //老师名字
              teacher(i),
              //上课地点
              courseVenue,
              //备注
              remark(i, j)
            ];
          }
        }
    }
  }
  print(writeData);
  String id = document.querySelector(".button[value='个人课表']")!.attributes["onclick"]!.substring(61).split("&year")[0];
  Map scheduleChanges = await getScheduleChanges("id", _schedule);
  await writeSchedule(jsonEncode(scheduleChanges));

  print("getSchedule End");
  return true;
}

Future<Map> getScheduleChanges(String id, Map schedule) async {
  print('getScheduleChanges');
  print("获取课表变更(调课/停课/补课)");
  Uri uri = Uri.http(Global.getScheduleNextUrl[0], Global.getScheduleNextUrl[1], {
    "id": id,
    "yearid": ((int.parse(writeData["year"] ?? "")) - 1980).toString(),
    "termid": writeData["semester"] == "秋" ? "3" : "1",
    "timetableType": "STUDENT",
    "sectionType": "BASE"
  });
  Response response;
  try {
    response = await request("get", uri);
  } catch (e) {
    return schedule;
  }

  Document document = parse(gbk.decode(response.bodyBytes));
  if (document.querySelector("table.error") == null) {
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
      int length = cellList.length;
      final Map<String, bool> rowInfo = {"standard": length == 17, "extension": length == 10};
      // print(rowInfo);
      String remark(String teachWeek, String courseVenue, int i, int j) {
        return "第" + teachWeek.replaceAll(RegExp(r'[第周]'), "") + "周;" + innerHtmlTrim(cellList[i]) + ";" + innerHtmlTrim(cellList[j]) + " - 调课/补课;$courseVenue";
      }

      if (rowInfo["standard"]!) {
        final Map<String, dynamic> latest = {
          "teachWeek": innerHtmlTrim(cellList[13]),
          "lessonList": teachTimeParser(cellList[15]),
          "week": weekCN2Number(innerHtmlTrim(cellList[14])),
        };
        final Map<String, dynamic> before = {
          "teachWeek": innerHtmlTrim(cellList[8]),
          "lessonList": teachTimeParser(cellList[10]),
          "week": weekCN2Number(innerHtmlTrim(cellList[9])),
        };

        String courseVenue = teachLocation(innerHtmlTrim(cellList[16]));
        teacher = innerHtmlTrim(cellList[4]);
        course = innerHtmlTrim(cellList[2]);
        String remark1 =
            "第" + latest["teachWeek"].replaceAll(RegExp(r'[第周]'), "") + "周;" + innerHtmlTrim(cellList[14]) + ";" + innerHtmlTrim(cellList[15]) + " - 调课/补课;$courseVenue";
        print(remark1);

        if (before["teachWeek"] != "&nbsp;") {
          for (int lesson = int.parse(before["lessonList"][0]); lesson <= int.parse(before["lessonList"][1]); lesson++) {
            // print("删除$before, $lesson");
            schedule[before["teachWeek"]][before["week"]][lesson.toString()] = ["null", "null", "null", "null"];
          }
        }
        if (latest["teachWeek"] != "&nbsp;") {
          for (int lesson = int.parse(latest["lessonList"][0]); lesson <= int.parse(latest["lessonList"][1]); lesson++) {
            // print("添加$latest, $lesson");
            schedule[latest["teachWeek"]][latest["week"]][lesson.toString()] = [course, teacher, courseVenue, remark(latest["teachWeek"], courseVenue, 14, 15)];
          }
        }
      } else if (rowInfo["extension"]!) {
        //周
        String _delWeek = innerHtmlTrim(cellList[1]);
        String _addWeek = innerHtmlTrim(cellList[6]);
        //星期
        String _delWeekDay = weekCN2Number(innerHtmlTrim(cellList[2]));
        String _addWeekDay = weekCN2Number(innerHtmlTrim(cellList[7]));
        //课节
        List<String> _delTime = teachTimeParser(cellList[3]);
        List<String> _addTime = teachTimeParser(cellList[8]);
        //教室
        String _addRoom = teachLocation(innerHtmlTrim(cellList[9]));
        String remark1 = "第" + _addWeek.replaceAll("第", "").replaceAll("周", "") + "周;" + innerHtmlTrim(cellList[7]) + ";" + innerHtmlTrim(cellList[8]) + " - 调课/补课;$_addRoom";
        print(remark1);
        if (_delWeek != "&nbsp;") {
          for (int i = int.parse(_delTime[0]); i <= int.parse(_delTime[1]); i++) {
            schedule[_delWeek][_delWeekDay][i.toString()] = ["null", "null", "null", "null"];
          }
        }
        if (_addWeek != "&nbsp;") {
          for (int i = int.parse(_addTime[0]); i <= int.parse(_addTime[1]); i++) {
            schedule[_addWeek][_addWeekDay][i.toString()] = [course, teacher, _addRoom, remark(_addWeek, _addRoom, 7, 8)];
          }
        }
      }
    });
  }
  print('getScheduleChanges End');
  return schedule;
}

Future<void> getName() async {
  print('getName');
  Response response = await request("get", Global.getNameUrl);
  writeData["name"] = parse(response.body).querySelector('[name="realname"]')!.parentNode!.text ?? "";
  print('getName End');
}

int getLocalWeek(DateTime nowDate, DateTime pastDate) {
  int day = nowDate.difference(pastDate).inDays;
  int week = day.abs() ~/ 7;
  return week;
}

List getSemester() {
  int y = DateTime.now().year;
  return [
    (y - 1980).toString(),
  ];
}

Future getScore() async {
  if (!await checkLoginValidity()) return false;
  print("getScore");
  String _year = "";
  String _term = "";
  if (writeData["queryYear"] != "全部") {
    _year = (int.parse(writeData["queryYear"] ?? "") - 1980).toString();
  }
  if (writeData["querySemester"] != "全部") {
    _term = (writeData["querySemester"] == "秋" ? 3 : 1).toString();
  }
  Map<String, String> postData = {"year": _year, "term": _term, "prop": "", "groupName": "", "para": "0", "sortColumn": "", "Submit": "查询"};
  Response response;
  try {
    response = await request("post", Global.getScoreUrl, body: postData);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  }
  String html = response.body;
  if (html == "") return Global.dataError;
  Document document = parse(html);
  List<Element> dataList = document.querySelectorAll(".datalist > tbody > tr");
  String parseData(int i, int number) => dataList[i].querySelectorAll("td")[number].text.trim();
  List list = [];
  for (int i = 1; i < dataList.length; i++) {
    List _list = [];
    _list.add(parseData(i, 0));
    _list.add(parseData(i, 1));
    _list.add(parseData(i, 3));
    _list.add(parseData(i, 4));
    _list.add(parseData(i, 5));
    _list.add(parseData(i, 6));
    list.add(_list);
  }
  print("getScore End");
  return list;
}

Future<dynamic> getExam() async {
  if (!await checkLoginValidity()) return false;
  print("getExam");
  Response response;
  try {
    response = await request("post", Global.getExamUrl);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  }
  String html = getHtml(response);
  if (html == "") return Global.dataError;
  Document document = parse(html);
  examList = [];
  examListC = [];
  examListA = 0;
  examListB = 0;
  document = parse(response.body);
  examList = [];
  var _row = document.querySelectorAll(".datalist> tbody > tr");
  for (int i = 1; i < _row.length; i++) {
    List<String> _list = [];
    String time = _row[i].querySelectorAll("td")[2].text;
    List timeList = time.split("-");
    _list.add(_row[i].querySelectorAll("td")[1].text);
    _list.add(time);
    _list.add(_row[i].querySelectorAll("td")[3].text.replaceAll("空港校区", "").replaceAll("教", "").trim().substring(1).trim());
    _list.add(_row[i].querySelectorAll("td")[4].text);

    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime(int.parse(timeList[0]), int.parse(timeList[1]), int.parse(timeList[2].toString().substring(0, 2)));
    int days = endDate.difference(startDate).inDays;
    if (days < 0) {
      examListC.add(true);
      examListA++;
    } else {
      examListB++;
      examListC.add(false);
    }

    examList.add(_list);
  }
  print("getExam End");
  return "success";
}

Future getCareer() async {
  if (!await checkLoginValidity()) return false;
  print("getCareer");
  Future<void> _next(List url) async {
    Response response;
    try {
      response = await request("get", Uri.http(Global.jwUrl, "/academic/manager/studyschedule/studentScheduleShowByTerm.do", {"z": "z", "studentId": url[0], "classId": url[1]}));
    } on TimeoutException catch (e) {
      timeOutError(e);
      return;
    } on SocketException catch (e) {
      socketError(e);
      return;
    }

    Document document = parse(response.bodyBytes);
    careerCount = [0, 0, 0, 0];
    document.querySelectorAll("img.no_output").forEach((element) {
      if (element.parent!.innerHtml.contains("/academic/styles/images/course_failed.png") ||
          element.parent!.innerHtml.contains("/academic/styles/images/course_failed_reelect.png")) {
        //重修&&不及格
        careerCount[0]++;
      }
      if (element.parent!.innerHtml.contains("/academic/styles/images/course_pass.png") || element.parent!.innerHtml.contains("/academic/styles/images/course_pass_reelect.png")) {
        //合格
        careerCount[1]++;
      }
      if (element.parent!.innerHtml.contains("/academic/styles/images/course_unknown_pass.png")) {
        //成绩未知
        careerCount[2]++;
      }
    });
    List<List<String>> list = [];
    document.querySelectorAll("table.datalist tbody tr").forEach((element) {
      var td = element.querySelectorAll("td");
      if (td.length > 1) {
        List<String> _list = [];
        td.forEach((element) {
          _list.add(element.text.trim());
        });
        list.add(_list);
      } else if (td.length == 1) {
        List<String> _list = [];
        List<String> title = td[0].text.trim().split("学年");
        if (title.length > 1) {
          _list.add(title[0].trim() + " 学年");
          _list.add(title[1].trim());
          list.add(_list);
        }
      }
    });

    careerInfo = list[0];
    list.removeAt(0);
    careerList = list;
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
  }

  Response response;
  try {
    response = await request("get", Global.getCareerUrl);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  }
  String html = getHtml(response);
  if (html == "") return Global.dataError;

  Document document = parse(html);
  String url = document.querySelectorAll("a")[3].parent!.innerHtml.trim();
  String urlA = url.substring(url.indexOf('修读顺序：按照课组及学年学期的顺序，用二维表方式显示教学计划课组及课程"></a>') + '修读顺序：按照课组及学年学期的顺序，用二维表方式显示教学计划课组及课程"></a>'.length);
  String urlB = urlA
      .replaceAll('<a href="', "")
      .replaceAll('" target="_blank"><img src="/academic/styles/images/Sort_Ascending.png" title="学期模式：按照学年学期的顺序，显示教学计划课程"></a>', "")
      .replaceAll("amp;", "")
      .replaceAll('/academic/manager/studyschedule/scheduleJump.jsp?link=studentScheduleShowByTerm.do&studentId=', "")
      .trim();
  List urlC = urlB.split('&classId=');
  print(urlC);
  await _next(urlC);
  print("getCareer End");
  return "success";
}

Future getEmptyClassroom({
  String week = "1",
  String whichWeek = "-1",
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
    "whichweek": whichWeek, //第几周
    "week": week, //星期
    "Submit": "%C8%B7+%B6%A8"
  };
  print(postData);
  Response response;
  bool weekMode = whichWeek != "-1" && week != "-1";
  try {
    if (weekMode) {
      response = await request("post", Global.getEmptyClassroomUrl2, body: postData);
    } else {
      response = await request("post", Global.getEmptyClassroomUrl, body: postData);
    }
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  }
  String html = getHtml(response);
  if (html == "") return Global.dataError;
  Document document = parse(html);
  if (weekMode) {
    List<Element> classrooms = document.querySelectorAll("tr.infolist_common");
    List<Map> result = [];
    print("classrooms.length");
    print(classrooms.length);
    print('--');
    classrooms.forEach((element) {
      List<Element> tds = element.querySelectorAll("td");
      List<Element> occupancyList = element.querySelectorAll("td tbody > tr:nth-child(2) > td");
      List<bool> cache = [];
      String text(i) {
        return tds[i].innerHtml;
      }

      int j = 0;
      if (occupancyList.length == 11) {
        for (int i = 0; i < 11; i++) {
          if (!occupancyList[i].innerHtml.contains("&nbsp;")) {
            cache.add(true);
          } else {
            cache.add(false);
            j++;
          }
        }
        result.add({"classroom": text(0), "seats": text(1), "examSeats": text(3), "type": text(5), "occupancyList": cache, "todayEmpty": j == 11});
      }
    });
    print(result[result.length - 1]);
    print('getEmptyClassroom end');
    return result;
  }
  List<Element> buildingOptions = document.querySelectorAll("#buildingid > option");
  List<Element> classroomOptions = document.querySelectorAll("select[name='room'] > option");
  Map<String?, String> buildings = {};
  Map<String?, String> classrooms = {};
  Map<String, Map> results = {"buildings": {}, "classrooms": {}};
  buildingOptions.removeAt(0);
  classroomOptions.removeAt(0);
  buildings["-1"] = "请选择";
  for (Element element in buildingOptions) {
    buildings[element.attributes["value"]] = element.innerHtml;
  }
  for (Element element in classroomOptions) {
    classrooms[element.attributes["value"]] = element.innerHtml;
  }
  results["buildings"] = buildings;
  results["classrooms"] = classrooms;
  print('getEmptyClassroom end');
  return results;
}

Future<dynamic> getUpdate() async {
  print("getUpdate");
  Response response;
  try {
    response = await get(Global.getUpdateUrl);
  } on TimeoutException catch (e) {
    print("getUpdate Error: " + e.toString());
    return "请求超时";
  } on SocketException catch (e) {
    print("getUpdate Error: " + e.toString());
    return Global.socketError;
  }
  if (response.body.toString().contains('"message":"API rate limit exceeded for')) {
    print("getUpdate End");
    return "频繁的请求!";
  }
  print(jsonDecode(response.body));
  Map<String, String> result = {
    "newVersion": jsonDecode(response.body)["name"].split("_")[1],
    "newBody": jsonDecode(response.body)["body"],
    "githubDownload": jsonDecode(response.body)["assets"][0]["browser_download_url"].toString().trim()
  };
  print(result);
  print("getUpdate End");
  return result;
}

Future getUpdateForEveryday() async {
  print("getUpdateForEveryday");
  if (true || "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}" != writeData["newTime"]) {
    Response response;
    try {
      response = await get(Global.getUpdateUrl);
    } on TimeoutException catch (e) {
      print("getUpdate Error: " + e.toString());
      return "请求超时";
    } on SocketException catch (e) {
      print("getUpdate Error: " + e.toString());
      return Global.socketError;
    } on ClientException catch (e) {
      return;
    }
    print('statusCode');
    print(response.statusCode);
    if (!response.body.toString().contains('"message":"API rate limit exceeded for')) {
      List list = jsonDecode(response.body)["name"].split("_");
      list.add(jsonDecode(response.body)["body"]);
      writeData["newVersion"] = list[1];
      writeData["newBody"] = list[3];
      writeData["newTime"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      writeConfig();
      checkNewVersion();
      if (hasNewVersion && canCheckImportantUpdate) {
        Future.delayed(Duration(seconds: 1), () {
          checkImportantUpdate();
        });
      }
      return print("getUpdateForEveryday End");
    }
  }
  print("getUpdateForEveryday Skip");
}

Future<Response> request(String method, Uri uri, {Map<String, String>? body, Encoding? encoding}) async {
  Map<String, String>? headers = {"cookie": mapCookieToString()};
  if (method == "post") {
    return await post(uri, body: body, headers: headers, encoding: encoding).timeout(Duration(seconds: Global.timeOutSec));
  } else {
    return await get(uri, headers: headers).timeout(Duration(seconds: Global.timeOutSec));
  }
}

String getHtml(Response response) {
  return gbk.decode(response.bodyBytes);
}

String timeOutError(e) {
  print("超时");
  print(e);
  return Global.timeOutError;
}

String socketError(e) {
  print("连接失败");
  print(e);
  return Global.socketError;
}

void getPermissions() async {
  print("getPermissions");
  Response response;
  response = await request("get", Uri.http(Global.authorUrl, Global.controlUrl));
  Map result = jsonDecode(response.body);
  if (!result["permissions"]["all"]) {
    exit(0);
  } else {
    print("应用已授权");
  }
}

Future<bool> checkLoginValidity() async {
  print("checkLoginSituation");
  Response response;
  try {
    response = await request("get", Global.checkLoginValidityUri);
  } catch (e) {
    return false;
  }
  String html = getHtml(response);
  return !html.contains(Global.reLoginErrorText);
}
