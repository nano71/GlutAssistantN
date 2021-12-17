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
    readConfig();
  } on SocketException catch (e) {
    print("连接失败");
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
      dom.Document document = parse(gbk
          .decode(response.bodyBytes)
          .toString()
          .replaceAll("第", "")
          .replaceAll("节", "")
          .replaceAll("周", "")
          .replaceAll("双", ""));
      var list = document.querySelectorAll(".infolist_common");
      num listLength = document.querySelectorAll(".infolist_common").length - 23;
      for (var i = 0; i < listLength; i++) {
        for (var j = 0; j < list[i].querySelectorAll("table.none>tbody>tr").length; j++) {
          //课节
          String kj = list[i]
              .querySelectorAll("table.none>tbody>tr")[j]
              .querySelectorAll("td")[2]
              .innerHtml
              .trim();
          //周次
          String zc = list[i]
              .querySelectorAll("table.none>tbody>tr")[j]
              .querySelectorAll("td")[0]
              .innerHtml
              .trim();
          List kjList = kj.trim().split('-');
          List zcList = zc.trim().split('-');
          String week = list[i]
              .querySelectorAll("table.none>tbody>tr")[j]
              .querySelectorAll("td")[1]
              .innerHtml
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
                    area != "&nbsp" ? area : null
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
                  area != "&nbsp" ? area : null
                ];
              }
            }
          }
        }
      }
      await writeSchedule(jsonEncode(_schedule));
    }
    print("getSchedule End");
    return "success";
  } on TimeoutException catch (e) {
    print("getExam Error");
    return Global.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
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
  Map postData = {
    "year": (int.parse(writeData["queryYear"]) - 1980).toString(),
    "term": (writeData["querySemester"] == "秋" ? 3 : 1).toString(),
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
    if (response.headers["location"] == "/academic/common/security/login.jsp" ||
        response.headers["location"] == null) {
      return ["登录过期"];
    }
    dom.Document document = parse(response.body);
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
    return [Global.timeOutError];
  } on SocketException catch (e) {
    print("getScore Error");
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
    return Global.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
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
      int length = document.querySelectorAll("table.datalist tbody tr").length;
      List list = [];
      for (int i = 0; i < length; i++) {
        var td = document.querySelectorAll("table.datalist tbody tr")[i].querySelectorAll("td");
        if (td.length > 1) {
          List _list = [];
          for (int j = 0; j < td.length; j++) {
            _list.add(td[j].text.trim());
          }
          list.add(_list);
        } else if (td.length == 1) {
          List _list = [];
          List title = td[0].text.trim().split("学年");
          if (title.length > 1) {
            _list.add(title[0].trim() + " 学年");
            _list.add(title[1].trim());
            list.add(_list);
          }
        }
      }
      print(list);
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
    return Global.timeOutError;
  } on SocketException catch (e) {
    print("getExam Error");
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
    print(list);
    print("getUpdate End");
    return list;
  } on TimeoutException catch (e) {
    print("getUpdate Error: "+e.toString());
    return ["请求超时"];
  } on SocketException catch (e) {
    print("getUpdate Error: "+e.toString());
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
