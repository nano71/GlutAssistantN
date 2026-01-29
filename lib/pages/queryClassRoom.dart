import 'package:flutter/material.dart';
import 'package:glutassistantn/widget/icons.dart';
import 'package:remixicon/remixicon.dart';
import '/common/get.dart';
import '/data.dart';
import '/widget/bars.dart';
import '/widget/lists.dart';

import '../config.dart';

class QueryRoomPage extends StatefulWidget {
  final String title;

  QueryRoomPage({Key? key, this.title = "空教室查询"}) : super(key: key);

  @override
  State<QueryRoomPage> createState() => QueryRoomPageState();
}

class QueryRoomPageState extends State<QueryRoomPage> {
  String message = "查询选择的教学楼全部教室";
  Color messageColor = Colors.grey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: readBackgroundColor(),
      body: CustomScrollView(
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          publicTopBar(
            "教室查询",
            InkWell(
              child: Icon(Remix.close_line, size: 24,color: readTextColor(),),
              onTap: () {
                Navigator.of(context).pop();
              },
            ),

            readBackgroundColor(),
            readTextColor(),
          ),
          SliverToBoxAdapter(
            child: Container(
              margin: EdgeInsets.fromLTRB(16, 0, 16, 0),
              child: Text(
                message,
                style: TextStyle(color: messageColor),
              ),
            ),
          ),
          QueryConditionCard(),
          ClassroomList(),
        ],
      ),
    );
  }
}

class QueryConditionCard extends StatefulWidget {
  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return QueryConditionCardState();
  }
}

class QueryConditionCardState extends State<QueryConditionCard> {
  Map<String, Map> query = {
    "buildingCode": {"-1": "请选择"},
    "weekOfSemester": {"-1": "请选择"},
    "dayOfWeek": {"-1": "请选择"}
  };
  String buildingSelect = "-1";
  String classroomSelect = "-1";
  String whichWeekSelect = "-1";
  String weekSelect = "-1";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initWhichWeek();
    initWeek();
    getEmptyClassroom().then(process);
  }

  void initWeek() {
    setState(() {
      for (int i = 0; i < 7; i++) {
        String value = (i + 1).toString();
        query["dayOfWeek"]![value] = "周" + weekList4CN[i];
      }
      weekSelect = DateTime
          .now()
          .weekday
          .toString();
      print('weekSelect');
      print(weekSelect);
      query["dayOfWeek"]!.remove("-1");
    });
    print(query["dayOfWeek"]);
  }

  void initWhichWeek() {
    setState(() {
      for (int i = 1; i <= 20; i++) {
        String value = i.toString();
        query["weekOfSemester"]![value] = "第" + value + "周";
      }
      if (AppData.week > 20) {
        whichWeekSelect = "20";
      } else {
        whichWeekSelect = AppData.week.toString();
      }
      query["weekOfSemester"]!.remove("-1");
    });
  }

  List<DropdownMenuItem<Object>> dropdownMenuItemList(String queryKey, [bool isBuilder = false]) {
    List<DropdownMenuItem<Object>> list = [];
    query[queryKey]!.forEach((key, value) {
      list.add(DropdownMenuItem(
        child: Text(
          value,
          style: TextStyle(fontSize: 14, color: isBuilder ? readTextColor() : null),
        ),
        value: key,
      ));
    });
    if (list == []) {
      list.add(DropdownMenuItem(
          child: Text(
            "-",
            style: isBuilder ? TextStyle(fontSize: 14, color: readTextColor()) : null,
          ),
          value: "请选择"));
    }
    return list;
  }

  void process(value) {
    print('process');
    if (value is Map<String, Map>) {
      setState(() {
        value.forEach((key, value) {
          query[key] = value;
        });
      });
    } else if (value is List<Map>) {
      setState(() {
        classroomList = value;
      });
      eventBus.fire(ReloadClassroomListState());
    } else if (value is bool) {
      if (!value) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
          false,
          "需要验证",
          context,
              () {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            getEmptyClassroom().then(process);
            Navigator.pop(context);
          },
          hideSnackBarSeconds: AppConfig.timeOutSec,
        ));
      }
    } else if (value is String) {
      print(value);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
    }
  }

  void _getEmptyClassroom() {
    if (buildingSelect != "-1") {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "查询中...", 10));
      getEmptyClassroom(dayOfWeek: weekSelect, weekOfSemester: whichWeekSelect, building: buildingSelect).then(process);
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "请选择教学楼", 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12.0)), gradient: readCardGradient2()),
        padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
        margin: EdgeInsets.fromLTRB(16, 16, 16, 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "教学楼",
                  style: TextStyle(fontSize: 16,color: readTextColor()),
                ),
                SizedBox(
                  height: 40,
                  child: DropdownButton(
                    enableFeedback: true,
                    icon: chevronRight(),
                    iconSize: 18,
                    underline: Container(),
                    alignment: Alignment.centerRight,
                    elevation: 0,
                    hint: Text(
                      query["buildingCode"]?[buildingSelect],
                      style: TextStyle(fontSize: 14,color: readTextColor()),
                    ),
                    items: dropdownMenuItemList("buildingCode"),
                    onTap: () {
                      if (query["buildingCode"]!.length == 1) getEmptyClassroom().then(process);
                    },
                    onChanged: (value) {
                      setState(() {
                        if (value != "-1") query["buildingCode"]!.remove("-1");
                        buildingSelect = value.toString();
                      });
                      // getEmptyClassroom(building: value.toString())
                      //     .then(process);
                    },
                  ),
                )
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "时    间",
                  style: TextStyle(fontSize: 16,color: readTextColor()),
                ),
                SizedBox(
                  height: 40,
                  child: DropdownButton(
                    enableFeedback: true,
                    value: whichWeekSelect,
                    // style: TextStyle(fontSize: 14, color: Colors.black.withOpacity(0.6)),
                    selectedItemBuilder: (context) {
                      return dropdownMenuItemList("weekOfSemester", true);
                    },
                    icon: chevronRight(),
                    iconSize: 18,
                    underline: Container(),
                    alignment: Alignment.centerRight,
                    elevation: 0,
                    hint: Text(query["weekOfSemester"]?[whichWeekSelect], style: TextStyle(fontSize: 14,color:readTextColor2())),
                    items: dropdownMenuItemList("weekOfSemester"),
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        whichWeekSelect = value.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "星    期",
                  style: TextStyle(fontSize: 16,color: readTextColor()),
                ),
                SizedBox(
                  height: 40,
                  child: DropdownButton(
                    value: weekSelect,
                    enableFeedback: true,
                    selectedItemBuilder: (context) {
                      return dropdownMenuItemList("dayOfWeek", true);
                    },
                    icon: chevronRight(),
                    iconSize: 18,
                    underline: Container(),
                    alignment: Alignment.centerRight,
                    elevation: 0,
                    // hint: Text(query["dayOfWeek"]?[weekSelect], style: TextStyle(fontSize: 14)),
                    items: dropdownMenuItemList("dayOfWeek"),
                    onChanged: (value) {
                      print(value);
                      setState(() {
                        weekSelect = value.toString();
                      });
                    },
                  ),
                ),
              ],
            ),
            ColumnGap(16),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: TextButton(
                    autofocus: true,
                    style: ButtonStyle(
                      //设置水波纹颜色
                      overlayColor: WidgetStateProperty.all(Colors.yellow),
                      backgroundColor: WidgetStateProperty.resolveWith((states) {
                        return readColor();
                      }),
                      shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                    ),
                    child: Text(
                      "即刻查询",
                      style: TextStyle(fontWeight: FontWeight.w500, color: Colors.white, fontSize: 14),
                    ),
                    onPressed: () {
                      _getEmptyClassroom();
                    }),
              ),
            )
          ],
        ),
      ),
    );
  }
}
