import 'dart:convert';

import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:glutnnbox/common/cookie.dart';
import 'package:glutnnbox/common/io.dart';
import 'package:html/dom.dart' as dom;
import 'package:html/parser.dart';
import 'package:http/http.dart';

import '../config.dart';
import '../data.dart';

Future<void> getWeek() async {
  try {
    var response = await get(Global.getWeekUrl);
    dom.Document document = parse(gbk.decode(response.bodyBytes));
    String weekHtml = document.querySelector("#date p span")!.innerHtml.trim();
    int week =
        int.parse(weekHtml.substring(weekHtml.indexOf("第") + 1, weekHtml.indexOf("周")).trim());
    await writeConfig(week.toString());
  } catch (e) {
    readConfig();
  }
}

getSchedule() async {
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
  Uri _url =
      Uri.http(Global.getScheduleUrl[0], Global.getScheduleUrl[1], {"year": "41", "term": "1"});
  var response = await get(_url, headers: {"cookie": mapCookieToString()})
      .timeout(const Duration(milliseconds: 6000));
  if (response.contentLength == 5175) {
    Global.logined = false;
  } else {
    dom.Document document = parse(gbk.decode(response.bodyBytes));
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
        kj = kj.substring(kj.indexOf("第") + 1, kj.length - 1);
        List kjList = kj.trim().split('-');
        zc = zc.substring(0, zc.length - 1);
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
    writeSchedule(jsonEncode(_schedule));
  }
}

int getLocalWeek(DateTime nowDate, DateTime pastDate) {
  int day = nowDate.difference(pastDate).inDays;
  int week = day ~/ 7;
  return week;
}
