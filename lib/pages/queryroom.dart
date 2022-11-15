import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/data.dart';
import 'package:glutassistantn/widget/bars.dart';

import '../config.dart';

class QueryRoomPage extends StatefulWidget {
  final String title;

  const QueryRoomPage({Key? key, this.title = "空教室查询"}) : super(key: key);

  @override
  State<QueryRoomPage> createState() => QueryRoomPageState();
}

class QueryRoomPageState extends State<QueryRoomPage> {
  Map<String, Map> query = {
    "buildings": {"1": "请选择"}
  };
  String buildingSelect = "请选择";
  String classroomSelect = "请选择";
  Object? currentRadio = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmptyClassroom().then((value) => process(value));
  }

  List<DropdownMenuItem<Object>> classrooms() {
    List<DropdownMenuItem<Object>> list = [];
    print(query);
    query["classrooms"]?.forEach((key, value) {
      list.add(DropdownMenuItem(child: Text(value), value: key));
    });

    if (list == []) {
      list.add(DropdownMenuItem(child: Text("-"), value: "请选择"));
    }
    print('41');
    return list;
  }

  List<DropdownMenuItem<Object>> buildings() {
    List<DropdownMenuItem<Object>> list = [];
    print(query);
    query["buildings"]!.forEach((key, value) {
      list.add(DropdownMenuItem(child: Text(value), value: key));
    });

    if (list == []) {
      list.add(DropdownMenuItem(child: Text("-"), value: "请选择"));
    }
    print('55');
    return list;
  }

  process(value) {
    print('process');
    print(value);
    if (value is Map<String, Map>) {
      query = value;
      setState(() {});
    } else if (value == "fail") {
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBarActionQ3(
        false,
        "需要验证",
        context,
        Global.timeOutSec,
      ));
    } else {
      print(value);
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4));
    }
  }

  queryClassroomList(String value) {
    print(value);
    buildingSelect = query["buildings"]?[value];
    getEmptyClassroom(building: value).then((value) => process(value));
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
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                color: Colors.white,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text("教学楼:"),
                        ),
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              DropdownButton(
                                elevation: 0,
                                hint: Text(buildingSelect, style: TextStyle(fontSize: 14)),
                                items: buildings(),
                                onChanged: (value) {
                                  setState(() {
                                    queryClassroomList(value.toString());
                                  });
                                },
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        SizedBox(
                          width: 60,
                          child: Text("教    室:"),
                        ),
                        SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              DropdownButton(
                                elevation: 0,
                                hint: Text(classroomSelect, style: TextStyle(fontSize: 14)),
                                items: classrooms(),
                                onChanged: (value) {
                                  setState(() {
                                    classroomSelect = query["classrooms"]?[value];
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    Row(children: [
                      SizedBox(
                        width: 60,
                        child: Text("模    式:"),
                      ),
                      SizedBox(
                          height: 40,
                          child: Row(
                            children: [
                              Radio(
                                  value: 0,
                                  groupValue: currentRadio,
                                  onChanged: (value) {
                                    setState(() {
                                      this.currentRadio = value;
                                    });
                                  }),
                              Text("教学楼模式"),
                              Radio(
                                  value: 1,
                                  groupValue: currentRadio,
                                  onChanged: (value) {
                                    setState(() {
                                      this.currentRadio = value;
                                    });
                                  }),
                            ],
                          ))
                    ]),
                    SizedBox(
                      height: 8,
                    ),
                  ],
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                color: Colors.white,
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                child: Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                        child: TextButton(
                            autofocus: true,
                            style: ButtonStyle(
                              //设置水波纹颜色
                              overlayColor: MaterialStateProperty.all(Colors.yellow),
                              backgroundColor: MaterialStateProperty.resolveWith((states) {
                                return readColor();
                              }),
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(borderRadius: BorderRadius.circular(28))),
                            ),
                            child: Text(
                              "查询",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, color: Colors.white, fontSize: 14),
                            ),
                            onPressed: () {}),
                      ),
                    )
                  ],
                ),
              ),
            ),
            // RoomList()
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
