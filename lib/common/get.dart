// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:glutassistantn/common/cookie.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart';

import '../config.dart';
import '../data.dart';

Future<void> getWeek() async {
  try {
    print("getWeek");
    var response = await get(Global.getWeekUrl).timeout(Duration(seconds: Global.timeOutSec));
    dom.Document document = parse(gbk.decode(response.bodyBytes));
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
    await writeConfig();
    print("getWeek End");
  } on TimeoutException catch (e) {
    print("超时");
    print(e);
    readConfig();
  } on SocketException catch (e) {
    print("连接失败");
    print(e);
    readConfig();
  }
}

Future<String> getSchedule() async {
  print("getSchedule...");
  Map _schedule = schedule;
  Map<String, String> _weekList = {
    "星期一": "1",
    "星期二": "2",
    "星期三": "3",
    "星期四": "4",
    "星期五": "5",
    "星期六": "6",
    "星期日": "7"
  };
  try {
    print(writeData["semesterBk"]);
    print(writeData["yearBk"]);
    Uri _url = Uri.http(Global.getScheduleUrl[0], Global.getScheduleUrl[1], {
      "year": ((int.parse(writeData["yearBk"])) - 1980).toString(),
      "term": writeData["semesterBk"] == "秋" ? "3" : "1"
    });
    var response = await get(_url, headers: {"cookie": mapCookieToString()})
        .timeout(Duration(seconds: Global.timeOutSec));
    if (response.body.contains("j_username")) {
      print("登录过期");
      return "fail";
    } else {
      dom.Document document = parse(gbk.decode(response.bodyBytes).toString());
      var list = document.querySelectorAll(".infolist_common");
      num listLength = document.querySelectorAll(".infolist_common").length - 23;
      for (var i = 0; i < listLength; i++) {
        for (var j = 0; j < list[i].querySelectorAll("table.none>tbody>tr").length; j++) {
          //课节
          String kj = list[i]
              .querySelectorAll("table.none>tbody>tr")[j]
              .querySelectorAll("td")[2]
              .innerHtml
              .trim()
              .replaceAll("第", "")
              .replaceAll("节", "");
          //周次
          String zc = list[i]
              .querySelectorAll("table.none>tbody>tr")[j]
              .querySelectorAll("td")[0]
              .innerHtml
              .trim()
              .replaceAll("第", "")
              .replaceAll("单", "")
              .replaceAll("双", "")
              .replaceAll("周", ""); //课节
          List kjList = kj.trim().split('-');
          List zcList = zc.trim().split('-');
          String week = list[i]
              .querySelectorAll("table.none>tbody>tr")[j]
              .querySelectorAll("td")[1]
              .innerHtml
              .replaceAll("第", "")
              .replaceAll("单", "")
              .replaceAll("双", "")
              .replaceAll("周", "")
              .trim();
          String area = list[i]
              .querySelectorAll("table.none>tbody>tr")[j]
              .querySelectorAll("td")[3]
              .innerHtml
              .trim();

          if (kjList.length > 1 && week != "&nbsp;") {
            for (var k = int.parse(kjList[0]); k < int.parse(kjList[1]) + 1; k++) {
              if (zcList.length > 1) {
                for (var l = int.parse(zcList[0]); l < int.parse(zcList[1]) + 1; l++) {
                  _schedule[l.toString()]?[_weekList[list[i]
                      .querySelectorAll("table.none>tbody>tr")[j]
                      .querySelectorAll("td")[1]
                      .innerHtml
                      .trim()]]?[k.toString()] = [
                    //课程名
                    list[i].querySelectorAll("a.infolist")[0].innerHtml.trim(),
                    //老师名字
                    list[i].querySelectorAll("a.infolist").length > 1
                        ? list[i].querySelectorAll("a.infolist")[1].innerHtml.trim()
                        : null,
                    //上课地点
                    area != "&nbsp" ? area : null,
                    //备注
                    list[i].querySelectorAll("table.none>tbody>tr")[j].text.trim().replaceAll(" ", ";")
                  ];
                }
              } else {
                _schedule[zc]?[_weekList[list[i]
                    .querySelectorAll("table.none>tbody>tr")[j]
                    .querySelectorAll("td")[1]
                    .innerHtml
                    .trim()]]?[k.toString()] = [
                  //课程名
                  list[i].querySelectorAll("a.infolist")[0].innerHtml.trim(),
                  //老师名字
                  list[i].querySelectorAll("a.infolist").length > 1
                      ? list[i].querySelectorAll("a.infolist")[1].innerHtml.trim()
                      : null,
                  //上课地点
                  area != "&nbsp" ? area : null,
                  //备注
                  list[i].querySelectorAll("table.none>tbody>tr")[j].text.trim().replaceAll(" ", ";")
                ];
              }
            }
          }
        }
      }
      _next() async {
        print("获取课表变更(调课/停课/补课)");
        String _id = document
            .querySelector(".button[value='个人课表']")!
            .attributes["onclick"]!
            .substring(61)
            .split("&year")[0];

        print(_id);
        Uri _url = Uri.http(Global.getScheduleNextUrl[0], Global.getScheduleNextUrl[1], {
          "id": _id,
          "yearid": ((int.parse(writeData["yearBk"])) - 1980).toString(),
          "termid": writeData["semesterBk"] == "秋" ? "3" : "1",
          "timetableType": "STUDENT",
          "sectionType": "BASE"
        });
        var response2 = await get(_url, headers: {"cookie": mapCookieToString()})
            .timeout(Duration(seconds: Global.timeOutSec));
        document = parse(gbk.decode(response2.bodyBytes));
        List<dom.Element> tables = document.querySelectorAll(".infolist_hr");
        if (tables.length >= 3) {
          dom.Element table = tables[2];
          List<dom.Element> trs = table.querySelectorAll(".infolist_hr_common");
          String _name = "";
          String _teacher = "";
          trs.forEach((element) {
            List<dom.Element> tds = element.querySelectorAll("td");
            int _length = tds.length;
            print(_length);
            if (_length == 17) {
              //周
              String _delWeek = tds[8].innerHtml.trim();
              String _addWeek = tds[13].innerHtml.trim();
              //课节
              List<String> _delTime = tds[10]
                  .innerHtml
                  .trim()
                  .replaceAll("第", "")
                  .replaceAll("节", "")
                  .replaceAll("周", "")
                  .replaceAll("单", "")
                  .replaceAll("双", "")
                  .split('-');
              List<String> _addTime = tds[15]
                  .innerHtml
                  .trim()
                  .replaceAll("第", "")
                  .replaceAll("节", "")
                  .replaceAll("周", "")
                  .replaceAll("单", "")
                  .replaceAll("双", "")
                  .split('-');
              //星期
              String _delWeekDay = weekDay2Number(tds[9].innerHtml.trim());
              String _addWeekDay = weekDay2Number(tds[14].innerHtml.trim());
              //教室
              String _addRoom = tds[16].innerHtml.trim();
              //老师
              String _addTeacher = tds[4].innerHtml.trim();
              _teacher = _addTeacher;
              //课
              String _addName = tds[2].innerHtml.trim();
              _name = _addName;
              if (_delWeek != "&nbsp;") {
                for (int i = int.parse(_delTime[0]); i <= int.parse(_delTime[1]); i++) {
                  _schedule[_delWeek][_delWeekDay][i.toString()] = ["null", "null", "null"];
                }
              }
              if (_addWeek != "&nbsp;") {
                for (int i = int.parse(_addTime[0]); i <= int.parse(_addTime[1]); i++) {
                  _schedule[_addWeek][_addWeekDay]
                      [i.toString()] = [_addName, _addTeacher, _addRoom];
                }
              }
            } else if (_length == 10) {
              //周
              String _delWeek = tds[1].innerHtml.trim();
              String _addWeek = tds[6].innerHtml.trim();
              //课节
              List<String> _delTime = tds[3]
                  .innerHtml
                  .trim()
                  .replaceAll("第", "")
                  .replaceAll("节", "")
                  .replaceAll("周", "")
                  .replaceAll("单", "")
                  .replaceAll("双", "")
                  .split('-');
              List<String> _addTime = tds[8]
                  .innerHtml
                  .trim()
                  .replaceAll("第", "")
                  .replaceAll("节", "")
                  .replaceAll("周", "")
                  .replaceAll("单", "")
                  .replaceAll("双", "")
                  .split('-');
              //星期
              String _delWeekDay = weekDay2Number(tds[2].innerHtml.trim());
              String _addWeekDay = weekDay2Number(tds[7].innerHtml.trim());
              //教室
              String _addRoom = tds[9].innerHtml.trim();

              if (_delWeek != "&nbsp;") {
                for (int i = int.parse(_delTime[0]); i <= int.parse(_delTime[1]); i++) {
                  _schedule[_delWeek][_delWeekDay][i.toString()] = ["null", "null", "null"];
                }
              }
              if (_addWeek != "&nbsp;") {
                for (int i = int.parse(_addTime[0]); i <= int.parse(_addTime[1]); i++) {
                  _schedule[_addWeek][_addWeekDay][i.toString()] = [_name, _teacher, _addRoom];
                  print(_schedule[_addWeek][_addWeekDay][i.toString()]);
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
  } on TimeoutException catch (e) {
    print("getExam Error");
    print(e);
    return Global.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
    print(e);
    return Global.socketError;
  }
}

Future<void> getName() async {
  print("getName...");
  var response = await get(Global.getNameUrl, headers: {"cookie": mapCookieToString()})
      .timeout(Duration(seconds: Global.timeOutSec));
  dom.Document document = parse(response.body);
  writeData["name"] = document.querySelector('[name="realname"]')!.parentNode!.text;
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

Future<List> getScore() async {
  print("getScore");
  String _year = "";
  String _term = "";
  if (writeData["queryYear"] != "全部") {
    _year = (int.parse(writeData["queryYear"]) - 1980).toString();
  }
  if (writeData["querySemester"] != "全部") {
    _term = (writeData["querySemester"] == "秋" ? 3 : 1).toString();
  }
  Map postData = {
    "year": _year,
    "term": _term,
    "prop": "",
    "groupName": "",
    "para": "0",
    "sortColumn": "",
    "Submit": "查询"
  };
  try {
    var response =
        await post(Global.getScoreUrl, body: postData, headers: {"cookie": mapCookieToString()})
            .timeout(Duration(seconds: Global.timeOutSec));

    dom.Document document = parse(response.body);
    print(response.contentLength);
    if (response.contentLength == 0 || document.querySelector("title")!.text.contains("提示信息")) {
      return ["登录过期"];
    }
    var dataList = document.querySelectorAll(".datalist > tbody >tr");
    List list = [];
    for (int i = 1; i < dataList.length; i++) {
      List _list = [];
      _list.add(dataList[i].querySelectorAll("td")[0].text.trim());
      _list.add(dataList[i].querySelectorAll("td")[1].text.trim());
      _list.add(dataList[i].querySelectorAll("td")[3].text.trim());
      _list.add(dataList[i].querySelectorAll("td")[4].text.trim());
      _list.add(dataList[i].querySelectorAll("td")[5].text.trim());
      _list.add(dataList[i].querySelectorAll("td")[6].text.trim());
      list.add(_list);
    }
    print("getScore End");
    return list;
  } on TimeoutException catch (e) {
    print("getScore Error");
    print(e);
    return [Global.timeOutError];
  } on SocketException catch (e) {
    print("getScore Error");
    print(e);
    return [Global.socketError];
  }
}

Future<String> getExam() async {
  print("getExam");
  try {
    var response = await post(Global.getExamUrl, headers: {"cookie": mapCookieToString()})
        .timeout(Duration(seconds: Global.timeOutSec));
    dom.Document document = parse(gbk.decode(response.bodyBytes));
    if (document.querySelector("title")!.text.contains("提示信息")) {
      return "fail";
    } else {
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
        _list.add(_row[i]
            .querySelectorAll("td")[3]
            .text
            .replaceAll("空港校区", "")
            .replaceAll("教", "")
            .trim()
            .substring(1)
            .trim());
        _list.add(_row[i].querySelectorAll("td")[4].text);

        DateTime startDate = DateTime.now();
        DateTime endDate = DateTime(int.parse(timeList[0]), int.parse(timeList[1]),
            int.parse(timeList[2].toString().substring(0, 2)));
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
  } on TimeoutException catch (e) {
    print("getExam Error");
    print(e);
    return Global.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
    print(e);
    return Global.socketError;
  }
}

Future getCareer() async {
  print("getCareer");

  try {
    _next(List url) async {
      var response = await get(
          Uri.http(Global.jwUrl, "/academic/manager/studyschedule/studentScheduleShowByTerm.do",
              {"z": "z", "studentId": url[0], "classId": url[1]}),
          headers: {"cookie": mapCookieToString()}).timeout(Duration(seconds: Global.timeOutSec));
      dom.Document document = parse(response.bodyBytes);
      print(document.querySelectorAll("img.no_output").length);
      careerCount = [0, 0, 0, 0];
      document.querySelectorAll("img.no_output").forEach((element) {
        if (element.parent!.innerHtml.contains("/academic/styles/images/course_failed.png") ||
            element.parent!.innerHtml
                .contains("/academic/styles/images/course_failed_reelect.png")) {
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

    var response = await get(Global.getCareerUrl, headers: {"cookie": mapCookieToString()})
        .timeout(Duration(seconds: Global.timeOutSec));
    dom.Document document = parse(gbk.decode(response.bodyBytes));
    if (gbk.decode(response.bodyBytes).contains("用户名不能为空！")) {
      return "fail";
    } else {
      String url = document.querySelectorAll("a")[3].parent!.innerHtml.trim();
      String urlA = url.substring(url.indexOf('修读顺序：按照课组及学年学期的顺序，用二维表方式显示教学计划课组及课程"></a>') +
          '修读顺序：按照课组及学年学期的顺序，用二维表方式显示教学计划课组及课程"></a>'.length);
      String urlB = urlA
          .replaceAll('<a href="', "")
          .replaceAll(
              '" target="_blank"><img src="/academic/styles/images/Sort_Ascending.png" title="学期模式：按照学年学期的顺序，显示教学计划课程"></a>',
              "")
          .replaceAll("amp;", "")
          .replaceAll(
              '/academic/manager/studyschedule/scheduleJump.jsp?link=studentScheduleShowByTerm.do&studentId=',
              "")
          .trim();
      List urlC = urlB.split('&classId=');
      print(urlC);
      await _next(urlC);
      print("getCareer End");
      return "success";
    }
  } on TimeoutException catch (e) {
    print("getExam Error");
    print(e);
    return Global.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
    print(e);
    return Global.socketError;
  }
}

Future getUpdate() async {
  print("getUpdate");
  try {
    var response = await get(Global.getUpdateUrl);
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
  } on TimeoutException catch (e) {
    print("getUpdate Error: " + e.toString());
    return ["请求超时"];
  } on SocketException catch (e) {
    print("getUpdate Error: " + e.toString());
    return [Global.socketError];
  }
}

Future getUpdateForEveryday() async {
  print("getUpdateForEveryday");
  if ("${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}" !=
      writeData["newTime"]) {
    var response = await get(Global.getUpdateUrl);
    if (response.body.toString().contains('"message":"API rate limit exceeded for')) {
    } else {
      List list = jsonDecode(response.body)["name"].split("_");
      list.add(jsonDecode(response.body)["body"]);
      writeData["newVersion"] = list[1];
      writeData["newBody"] = list[3];
      writeData["newTime"] = "${DateTime.now().year}-${DateTime.now().month}-${DateTime.now().day}";
      writeConfig();
      print("getUpdateForEveryday End");
    }
  }
  print("getUpdateForEveryday Skip");
}
