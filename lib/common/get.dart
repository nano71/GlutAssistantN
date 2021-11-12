// ignore_for_file: import_of_legacy_library_into_null_safe

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:glutassistantn/common/cookie.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/widget/lists.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart';

import '../config.dart';
import '../data.dart';
import 'init.dart';

Future<void> getWeek() async {
  try {
    print("getWeek");
    var response = await get(Global.getWeekUrl).timeout(const Duration(seconds: 3));
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
    print("getWeek End");
  } on TimeoutException catch (e) {
    print("超时");
    readConfig();
  } on SocketException catch (e) {
    print("连接失败");
    readConfig();
  }
}

Future<bool> getSchedule() async {
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
        .timeout(const Duration(seconds: 3));
    if (response.body.contains("j_username")) {
      print("登录过期");
      return false;
    } else {

      dom.Document document = parse(gbk
          .decode(response.bodyBytes)
          .toString()
          .replaceAll("第", "")
          .replaceAll("节", "")
          .replaceAll("周", "")
          .replaceAll("双", "")
      );
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
    return true;
  } on SocketException catch (e) {
    print("超时");
    return false;
  } on TimeoutException catch (e) {
    print("网络错误");
    return false;
  }
}

getScheduleErrorR() {}

Future<void> getName() async {
  print("getName...");
  var response = await get(Global.getNameUrl, headers: {"cookie": mapCookieToString()})
      .timeout(const Duration(seconds: 3));
  dom.Document document = parse(response.body);

  writeData["name"] = document.querySelector('[name="realname"]')!.parentNode!.text;
}

int getLocalWeek(DateTime nowDate, DateTime pastDate) {
  int day = nowDate.difference(pastDate).inDays;
  int week = day ~/ 7;
  return week;
}

List getSemester() {
  int y = DateTime.now().year;
  int m = DateTime.now().month;
  return [
    (y - 1980).toString(),
  ];
}

Future<void> getScore() async {
  Map postData = {
    "year": "",
    "term": "",
    "prop": "",
    "groupName": "",
    "para": "0",
    "sortColumn": "",
    "Submit": "查询"
  };
  var response =
      await post(Global.getScoreUrl, body: postData, headers: {"cookie": mapCookieToString()})
          .timeout(const Duration(milliseconds: 6000));
  dom.Document document = parse(response.body);
  var dataList = document.querySelectorAll(".datalist > tbody >tr");
  List list = [];
  for (int i = 1; i < dataList.length; i++) {
    List _list = [];
    _list.add(dataList[i].querySelectorAll("td")[0].text);
    _list.add(dataList[i].querySelectorAll("td")[1].text);
    _list.add(dataList[i].querySelectorAll("td")[3].text);
    _list.add(dataList[i].querySelectorAll("td")[4].text);
    _list.add(dataList[i].querySelectorAll("td")[5].text);
    _list.add(dataList[i].querySelectorAll("td")[6].text);
    list.add(_list);
  }

  print(list);
}
