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
  Map<String, Map> query = {"builds": {
    "1":"请选择"
  }};
  Map<String, String> selects = {"builds": "请选择"};
  String buildSelect = "请选择";

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getEmptyClassroom().then((value) => process(value));
  }

  List<DropdownMenuItem<Object>> builds() {
    List<DropdownMenuItem<Object>> list = [];
    query["builds"]!.forEach((key, value) {
      list.add(DropdownMenuItem(child: Text(value), value: key));
    });

    if (list == []) {
      list.add(DropdownMenuItem(child: Text("-"), value: "请选择"));
    }
    print('41');
    print(list);
    return list;
  }

  String hintText() {
    return selects["builds"] == null ? "请选择" : query["builds"]?[selects["builds"]];
  }

  process(value) {
    print('process');
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
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            DropdownButton(
                              elevation: 0,
                              hint: Text(buildSelect),
                              items: builds(),
                              onChanged: (value) {
                                setState(() {
                                  buildSelect = query["builds"]?[value.toString()];
                                  selects["builds"] = value.toString();
                                });
                              },
                            ),
                            SizedBox(
                              width: 25,
                            ),
                            DropdownButton(
                              elevation: 0,
                              hint: Text(writeData["querySemester"]),
                              items: const [
                                DropdownMenuItem(child: Text("全部"), value: "全部"),
                                DropdownMenuItem(child: Text("春"), value: "春"),
                                DropdownMenuItem(child: Text("秋"), value: "秋"),
                              ],
                              onChanged: (value) {
                                setState(() {
                                  writeData["querySemester"] = value;
                                });
                              },
                            ),
                          ],
                        ),
                        InkWell(
                          onTap: () {},
                          child: Container(
                            decoration: const BoxDecoration(
                              borderRadius: BorderRadius.all(Radius.circular(6.0)),
                              color: Color(0x1ff1f1f1),
                            ),
                            padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                            child: Text(
                              "查询",
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
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

