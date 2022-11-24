// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:glutassistantn/common/cookie.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/common/parser.dart';
import 'package:html/dom.dart';
import 'package:html/parser.dart';
import 'package:http/http.dart';

import '../config.dart';
import '../data.dart';
import '../pages/update.dart';

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
  if (writeData["semesterBk"] == "" && writeData["yearBk"] == "") {
    writeData["semesterBk"] = q;
    writeData["yearBk"] = n;
  }
  if (writeData["querySemester"] == "" && writeData["queryYear"] == "") {
    writeData["querySemester"] = q;
    writeData["queryYear"] = n;
  }
  print("getWeek save");
  await writeConfig();
  print("getWeek End");
}

Future<String> getSchedule() async {
  print("getSchedule...");
  Map _schedule = schedule;
  Map<String, String> _weekList = {"星期一": "1", "星期二": "2", "星期三": "3", "星期四": "4", "星期五": "5", "星期六": "6", "星期日": "7"};
  print(writeData["semesterBk"]);
  print(writeData["yearBk"]);
  Uri _url = Uri.http(Global.getScheduleUrl[0], Global.getScheduleUrl[1],
      {"year": ((int.parse(writeData["yearBk"] ?? "")) - 1980).toString(), "term": writeData["semesterBk"] == "秋" ? "3" : "1"});
  Response response;
  try {
    response = await request("", _url);
  } on TimeoutException catch (e) {
    return timeOutError(e);
  } on SocketException catch (e) {
    return socketError(e);
  }
  String html = getHtml(response);
  Document document = parse(html);

  if (html.contains(Global.scheduleErrorText)) {
    return "fail";
  } else {
    var list = document.querySelectorAll(".infolist_common");
    num listLength = document.querySelectorAll(".infolist_common").length - 23;
    for (int i = 0; i < listLength; i++) {
      for (var j = 0; j < list[i].querySelectorAll("table.none>tbody>tr").length; j++) {
        //课节
        String kj = list[i].querySelectorAll("table.none>tbody>tr")[j].querySelectorAll("td")[2].innerHtml.trim().replaceAll("第", "").replaceAll("节", "");
        //周次
        String zc = list[i].querySelectorAll("table.none>tbody>tr")[j].querySelectorAll("td")[0].innerHtml.trim().replaceAll("第", "").replaceAll("周", "");

        //课节
        List kjList = kj.trim().split("-");
        //周次 1-9周 = [1,9]
        List<String> zcList = zc.trim().split("-");
        String week = list[i].querySelectorAll("table.none>tbody>tr")[j].querySelectorAll("td")[1].innerHtml.replaceAll("第", "").replaceAll("周", "").trim();
        String area = list[i].querySelectorAll("table.none>tbody>tr")[j].querySelectorAll("td")[3].innerHtml.trim();

        //单周
        if (zc.indexOf("单") != -1) {
          zc = zc.replaceAll("单", "");
          zcList = zc.trim().split("-");
          print(int.parse(zcList.last));
          List<String> _list = [];
          for (int i = int.parse(zcList.first); i <= int.parse(zcList.last); i++) {
            if (!i.isEven) if (_list.indexOf(i.toString()) == -1) _list.add(i.toString());
          }
          zcList = _list;
          //双周
        } else if (zc.indexOf("双") != -1) {
          zc = zc.replaceAll("双", "");
          zcList = zc.trim().split("-");
          List<String> _list = [];
          for (int i = int.parse(zcList.first); i < int.parse(zcList.last); i++) {
            if (i.isEven) if (_list.indexOf(i.toString()) == -1) _list.add(i.toString());
          }
          zcList = _list;
        }
        if (kjList.length > 1 && week != "&nbsp;")
          for (int k = int.parse(kjList[0]); k < int.parse(kjList[1]) + 1; k++) {
            if (zcList.length > 2) {
              print("zcList");
              print(zcList);
              zcList.forEach((element) {
                _schedule[element.toString()]?[_weekList[list[i].querySelectorAll("table.none>tbody>tr")[j].querySelectorAll("td")[1].innerHtml.trim()]]
                    ?[k.toString()] = [
                  //课程名
                  list[i].querySelectorAll("a.infolist")[0].innerHtml.trim(),
                  //老师名字
                  list[i].querySelectorAll("a.infolist").length > 1 ? list[i].querySelectorAll("a.infolist")[1].innerHtml.trim() : null,
                  //上课地点
                  area != "&nbsp" ? area : null,
                  //备注
                  list[i].querySelectorAll("table.none>tbody>tr")[j].text.trim().replaceAll(" ", ";")
                ];
              });
            } else if (zcList.length > 1) {
              for (var l = int.parse(zcList[0]); l < int.parse(zcList[1]) + 1; l++) {
                _schedule[l.toString()]?[_weekList[list[i].querySelectorAll("table.none>tbody>tr")[j].querySelectorAll("td")[1].innerHtml.trim()]]
                    ?[k.toString()] = [
                  //课程名
                  list[i].querySelectorAll("a.infolist")[0].innerHtml.trim(),
                  //老师名字
                  list[i].querySelectorAll("a.infolist").length > 1 ? list[i].querySelectorAll("a.infolist")[1].innerHtml.trim() : null,
                  //上课地点
                  area != "&nbsp" ? area : null,
                  //备注
                  list[i].querySelectorAll("table.none>tbody>tr")[j].text.trim().replaceAll(" ", ";")
                ];
              }
            } else {
              _schedule[zc]?[_weekList[list[i].querySelectorAll("table.none>tbody>tr")[j].querySelectorAll("td")[1].innerHtml.trim()]]?[k.toString()] = [
                //课程名
                list[i].querySelectorAll("a.infolist")[0].innerHtml.trim(),
                //老师名字
                list[i].querySelectorAll("a.infolist").length > 1 ? list[i].querySelectorAll("a.infolist")[1].innerHtml.trim() : null,
                //上课地点
                area != "&nbsp" ? area : null,
                //备注
                list[i].querySelectorAll("table.none>tbody>tr")[j].text.trim().replaceAll(" ", ";")
              ];
            }
          }
      }
    }
    _next() async {
      print("获取课表变更(调课/停课/补课)");
      String _id = document.querySelector(".button[value='个人课表']")!.attributes["onclick"] ?? "".substring(61).split("&year")[0];

      print(_id);
      Uri _url = Uri.http(Global.getScheduleNextUrl[0], Global.getScheduleNextUrl[1], {
        "id": _id,
        "yearid": ((int.parse(writeData["yearBk"] ?? "")) - 1980).toString(),
        "termid": writeData["semesterBk"] == "秋" ? "3" : "1",
        "timetableType": "STUDENT",
        "sectionType": "BASE"
      });
      var response2 = await request("get", _url);
      document = parse(gbk.decode(response2.bodyBytes));
      List<Element> tables = document.querySelectorAll(".infolist_hr");
      if (tables.length >= 3) {
        Element table = tables[2];
        List<Element> trs = table.querySelectorAll(".infolist_hr_common");
        String _name = "";
        String _teacher = "";
        trs.forEach((element) {
          List<Element> tds = element.querySelectorAll("td");
          int _length = tds.length;
          print(_length);
          if (_length == 17) {
            //周
            String _delWeek = innerHtmlTrim(tds[8]);
            String _addWeek = innerHtmlTrim(tds[13]);
            //课节
            List<String> _delTime = lessonParser(tds[10]);
            List<String> _addTime = lessonParser(tds[15]);
            //星期
            String _delWeekDay = weekDay2Number(innerHtmlTrim(tds[9]));
            String _addWeekDay = weekDay2Number(innerHtmlTrim(tds[14]));
            //教室
            String _addRoom = innerHtmlTrim(tds[16]);
            //老师
            String _addTeacher = innerHtmlTrim(tds[4]);
            //课
            String _addName = innerHtmlTrim(tds[2]);
            _teacher = _addTeacher;
            _name = _addName;
            String remark =
                "第" + _addWeek.replaceAll("第", "").replaceAll("周", "") + "周;" + innerHtmlTrim(tds[14]) + ";" + innerHtmlTrim(tds[15]) + " - 调课/补课;$_addRoom";
            print(remark);

            if (_delWeek != "&nbsp;") {
              for (int i = int.parse(_delTime[0]); i <= int.parse(_delTime[1]); i++) {
                _schedule[_delWeek][_delWeekDay][i.toString()] = ["null", "null", "null", "null"];
              }
            }
            if (_addWeek != "&nbsp;") {
              for (int i = int.parse(_addTime[0]); i <= int.parse(_addTime[1]); i++) {
                _schedule[_addWeek][_addWeekDay][i.toString()] = [_addName, _addTeacher, _addRoom, remark];
              }
            }
          } else if (_length == 10) {
            //周
            String _delWeek = innerHtmlTrim(tds[1]);
            String _addWeek = innerHtmlTrim(tds[6]);
            //星期
            String _delWeekDay = weekDay2Number(innerHtmlTrim(tds[2]));
            String _addWeekDay = weekDay2Number(innerHtmlTrim(tds[7]));
            //课节
            List<String> _delTime = lessonParser(tds[3]);
            List<String> _addTime = lessonParser(tds[8]);
            //教室
            String _addRoom = innerHtmlTrim(tds[9]);
            String remark =
                "第" + _addWeek.replaceAll("第", "").replaceAll("周", "") + "周;" + innerHtmlTrim(tds[7]) + ";" + innerHtmlTrim(tds[8]) + " - 调课/补课;$_addRoom";
            print(remark);
            if (_delWeek != "&nbsp;") {
              for (int i = int.parse(_delTime[0]); i <= int.parse(_delTime[1]); i++) {
                _schedule[_delWeek][_delWeekDay][i.toString()] = ["null", "null", "null", "null"];
              }
            }
            if (_addWeek != "&nbsp;") {
              for (int i = int.parse(_addTime[0]); i <= int.parse(_addTime[1]); i++) {
                _schedule[_addWeek][_addWeekDay][i.toString()] = [_name, _teacher, _addRoom, remark];
              }
            }
          }
        });
      }
    }

    print(writeData);
    await _next();
    await writeSchedule(jsonEncode(_schedule));
  }
  print("getSchedule End");
  return "success";
}

Future<void> getName() async {
  print("getName...");
  Response response = await request("get", Global.getNameUrl);
  writeData["name"] = parse(response.body).querySelector('[name="realname"]')!.parentNode!.text ?? "";
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
  Document document = parse(html);

  if (html == "") {
    return "fail";
  }
  List<Element> dataList = document.querySelectorAll(".datalist > tbody >tr");
  String parseData(int i, int number) {
    return dataList[i].querySelectorAll("td")[number].text.trim();
  }

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

Future<String> getExam() async {
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
  if (html.contains(Global.examErrorText)) {
    return "fail";
  } else {
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
}

Future getCareer() async {
  print("getCareer");
  _next(List url) async {
    Response response;
    try {
      response = await request(
          "get", Uri.http(Global.jwUrl, "/academic/manager/studyschedule/studentScheduleShowByTerm.do", {"z": "z", "studentId": url[0], "classId": url[1]}));
    } on TimeoutException catch (e) {
      return timeOutError(e);
    } on SocketException catch (e) {
      return socketError(e);
    }

    Document document = parse(response.bodyBytes);
    careerCount = [0, 0, 0, 0];
    document.querySelectorAll("img.no_output").forEach((element) {
      if (element.parent!.innerHtml.contains("/academic/styles/images/course_failed.png") ||
          element.parent!.innerHtml.contains("/academic/styles/images/course_failed_reelect.png")) {
        //重修&&不及格
        careerCount[0]++;
      }
      if (element.parent!.innerHtml.contains("/academic/styles/images/course_pass.png") ||
          element.parent!.innerHtml.contains("/academic/styles/images/course_pass_reelect.png")) {
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
  if (html.contains(Global.careerErrorText)) {
    return "fail";
  } else {
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
}

Future getEmptyClassroom({
  String week = "1",
  String whichWeek = "-1",
  String building = "-1",
  String classroom = "-1",
}) async {
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
  if (html == "") {
    return "fail";
  } else {
    Document document = parse(html);
    if (weekMode) {
      List<Element> classrooms = document.querySelectorAll(".infolist_common");
      List<Map> result = [];

      classrooms.forEach((element) {
        List<Element> tds = element.querySelectorAll("td");
        List<Element> occupancyList = element.querySelectorAll("tr:last-child > td");
        List<bool> cache = [];
        String text(i) {
          return tds[i].innerHtml;
        }

        int j = 0;
        for (int i = 0; i < 11; i++) {
          if (occupancyList[i].innerHtml.contains("color")) {
            cache.add(true);
          } else {
            cache.add(false);
            j++;
          }
        }
        result.add({"classroom": text(0), "seats": text(1), "examSeats": text(3), "type": text(5), "occupancyList": cache, "todayEmpty": j == 11});
      });
      print(result);
      print('getEmptyClassroom end');
      return result;
    }
    List<Element> buildingOptions = document.querySelectorAll("#buildingid > option");
    List<Element> classroomOptions = document.querySelectorAll("select[name='room'] > option");
    Map<String?, String> buildings = {};
    Map<String?, String> classrooms = {};
    Map<String, Map> result = {"buildings": {}, "classrooms": {}};
    buildingOptions.removeAt(0);
    classroomOptions.removeAt(0);
    buildings["-1"] = "请选择";
    for (Element element in buildingOptions) {
      buildings[element.attributes["value"]] = element.innerHtml;
    }
    for (Element element in classroomOptions) {
      classrooms[element.attributes["value"]] = element.innerHtml;
    }
    result["buildings"] = buildings;
    result["classrooms"] = classrooms;
    print(result);
    print('getEmptyClassroom end');
    return result;
  }
}

Future getUpdate() async {
  print("getUpdate");
  Response response;
  try {
    response = await get(Global.getUpdateUrl);
  } on TimeoutException catch (e) {
    print("getUpdate Error: " + e.toString());
    return ["请求超时"];
  } on SocketException catch (e) {
    print("getUpdate Error: " + e.toString());
    return [Global.socketError];
  }
  if (response.body.toString().contains('"message":"API rate limit exceeded for')) {
    print("getUpdate End");
    return ["频繁的请求!"];
  }
  List list = jsonDecode(response.body)["name"].split("_");
  list.add(jsonDecode(response.body)["body"]);
  list.add(jsonDecode(response.body)["assets"][0]["browser_download_url"].toString().trim());
  print(list);
  print("getUpdate End");
  return list;
}

Future getUpdateForEveryday() async {
  print("getUpdateForEveryday");
  if ("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}" != writeData["newTime"]) {
    Response response = await get(Global.getUpdateUrl);
    if (response.body.toString().contains('"message":"API rate limit exceeded for')) {
    } else {
      List list = jsonDecode(response.body)["name"].split("_");
      list.add(jsonDecode(response.body)["body"]);
      writeData["newVersion"] = list[1];
      writeData["newBody"] = list[3];
      writeData["newTime"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      writeConfig();
      checkNewVersion();
      print("getUpdateForEveryday End");
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
