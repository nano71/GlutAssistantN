import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/data.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../config.dart';

class QueryRoomPage extends StatefulWidget {
  final String title;

  const QueryRoomPage({Key? key, this.title = "空教室查询"}) : super(key: key);

  @override
  State<QueryRoomPage> createState() => QueryRoomPageState();
}

class QueryRoomPageState extends State<QueryRoomPage> {
  Map<String, Map> query = {
    "buildings": {"-1": "请选择"},
    "whichWeeks": {"-1": "请选择"},
    "weeks": {"-1": "请选择"}
  };
  String buildingSelect = "-1";
  String classroomSelect = "-1";
  String whichWeekSelect = "-1";
  String weekSelect = "-1";
  String message = "查询选择的教学楼全部教室";
  Color messageColor = Colors.grey;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initWhichWeek();
    initWeek();
    getEmptyClassroom().then((value) => process(value));
  }

  void initWeek() {
    setState(() {
      for (int i = 0; i < 7; i++) {
        String value = i.toString();
        query["weeks"]![value] = "周" + weekList4CN[i];
      }
      weekSelect = writeData["weekDay"];
      query["weeks"]!.remove("-1");
    });
    print(query["weeks"]);
  }

  void initWhichWeek() {
    setState(() {
      for (int i = 1; i < 20; i++) {
        String value = i.toString();
        query["whichWeeks"]![value] = "第" + value + "周";
      }
      whichWeekSelect = writeData["week"];
      query["whichWeeks"]!.remove("-1");
    });
  }

  List<DropdownMenuItem<Object>> dropdownMenuItemList(String queryKey) {
    List<DropdownMenuItem<Object>> list = [];
    query[queryKey]?.forEach((key, value) {
      list.add(DropdownMenuItem(child: Text(value), value: key));
    });
    if (list == []) {
      list.add(DropdownMenuItem(child: Text("-"), value: "请选择"));
    }
    return list;
  }

  void process(value) {
    print('process');
    // print(value is List<Map>);
    if (value is Map<String, Map>) {
      setState(() {
        value.forEach((key, value) {
          query[key] = value;
        });
        // query["buildings"]!.remove("-1");
      });
    } else if (value is List<Map>) {
      // print("赋值");
      setState(() {
        classroomList = value;
      });
      eventBus.fire(ReloadClassroomListState());
    } else if (value == "fail") {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
        false,
        "需要验证",
        context,
        () => {ScaffoldMessenger.of(context).removeCurrentSnackBar(), getEmptyClassroom().then((value) => process(value)), Navigator.pop(context)},
        hideSnackBarSeconds: Global.timeOutSec,
      ));
    } else {
      print(value);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
    }
  }

  void _getEmptyClassroom() {
    if (buildingSelect != "-1") {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "查询中...", 10));
      getEmptyClassroom(week: weekSelect, whichWeek: whichWeekSelect, building: buildingSelect).then((value) => process(value));
    } else {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "请选择教学楼", 4));
    }
  }

  @override
  Widget build(BuildContext context) {
    // TODO: implement build
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
              "教室查询",
              InkWell(
                child: const Icon(FlutterRemix.close_line, size: 24),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 0),
                child: Text(
                  message,
                  style: TextStyle(color: messageColor),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(12.0)), color: readColorBegin(), gradient: readGradient()),
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
                margin: const EdgeInsets.fromLTRB(16, 16, 16, 16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text("教学楼"),
                        ),
                        SizedBox(
                          height: 40,
                          child: DropdownButton(
                            icon: Icon(FlutterRemix.arrow_right_s_line),
                            iconSize: 14,
                            underline: Container(),
                            alignment: Alignment.centerRight,
                            elevation: 0,
                            hint: Text(query["buildings"]?[buildingSelect], style: TextStyle(fontSize: 14)),
                            items: dropdownMenuItemList("buildings"),
                            onChanged: (value) {
                              setState(() {
                                buildingSelect = value.toString();
                                if (value != "-1") query["buildings"]?.remove("-1");
                                // getEmptyClassroom(building: value.toString())
                                //     .then((value) => process(value));
                              });
                            },
                          ),
                        )
                      ],
                    ),
                    // Row(
                    //   children: [
                    //     SizedBox(
                    //       width: 60,
                    //       child: Text("教    室:"),
                    //     ),
                    //     SizedBox(
                    //       height: 40,
                    //       child: Row(
                    //         children: [
                    //           DropdownButton(
                    //             elevation: 0,
                    //             hint: Text(classroomSelect, style: TextStyle(fontSize: 14)),
                    //             items: dropdownMenuItemList("classrooms"),
                    //             onChanged: (value) {
                    //               setState(() {
                    //                 classroomSelect = query["classrooms"]?[value];
                    //               });
                    //             },
                    //           ),
                    //         ],
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text("时    间"),
                        ),
                        SizedBox(
                          height: 40,
                          child: DropdownButton(
                            icon: Icon(FlutterRemix.arrow_right_s_line),
                            iconSize: 14,
                            underline: Container(),
                            alignment: Alignment.centerRight,
                            elevation: 0,
                            hint: Text(query["whichWeeks"]?[whichWeekSelect], style: TextStyle(fontSize: 14)),
                            items: dropdownMenuItemList("whichWeeks"),
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
                        SizedBox(
                          width: 60,
                          child: Text("星    期"),
                        ),
                        SizedBox(
                          height: 40,
                          child: DropdownButton(
                            icon: Icon(FlutterRemix.arrow_right_s_line),
                            iconSize: 14,
                            underline: Container(),
                            alignment: Alignment.centerRight,
                            elevation: 0,
                            hint: Text(query["weeks"]?[weekSelect], style: TextStyle(fontSize: 14)),
                            items: dropdownMenuItemList("weeks"),
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
                    SizedBox(
                      height: 8,
                    ),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 0, 0),
                        child: TextButton(
                            autofocus: true,
                            style: ButtonStyle(
                              //设置水波纹颜色
                              overlayColor: MaterialStateProperty.all(Colors.yellow),
                              backgroundColor: MaterialStateProperty.resolveWith((states) {
                                return readColor();
                              }),
                              shape: MaterialStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                            ),
                            child: Text(
                              "即刻查询",
                              style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                            onPressed: () {
                              _getEmptyClassroom();
                            }),
                      ),
                    )
                  ],
                ),
              ),
            ),
            ClassroomList(),
          ],
        ),
      ),
    );
  }
}

// class RoomList extends StatefulWidget {
//   RoomListState createState() => RoomListState();
// }
//
// class RoomListState extends State<RoomList> {
//   @override
//   Widget build(BuildContext context) {
//     // TODO: implement build
//       throw UnimplementedError();
//   }
// }

List<DropdownMenuItem<Object>> weekList() {
  List<DropdownMenuItem<Object>> list = [];
  int i = 1;

  while (i < 8) {
    list.add(DropdownMenuItem(child: Text("周" + weekList4CN[i - 1]), value: i));
  }
  return list;
}

List<DropdownMenuItem<Object>> weeksList() {
  List<DropdownMenuItem<Object>> list = [];
  int i = 1;
  while (i < 20) {
    list.add(DropdownMenuItem(child: Text("第$i周"), value: i));
  }
  return list;
}
