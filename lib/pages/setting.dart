import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/main.dart';
import '/common/init.dart';
import '/common/io.dart';
import '/common/style.dart';
import '/custom/expansiontile.dart' as CustomExpansionTile;
import '/pages/scheduleManager.dart';
import '/pages/timeManager.dart';
import '/widget/bars.dart';

import '../config.dart';
import '../data.dart';
import 'init.dart';
import 'person.dart';

class SettingPage extends StatefulWidget {
  final String title;

  SettingPage({Key? key, this.title = "设置"}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with WidgetsBindingObserver {
  final TextEditingController _textFieldController1 = TextEditingController();
  final TextEditingController _textFieldController2 = TextEditingController();
  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();
  bool _isExpanded = false;
  bool focusNode2Type = false;
  bool focusNodeType = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _textFieldController1.text = AppData.persistentData["year"] ?? "";
    _textFieldController2.text = AppData.persistentData["semester"] ?? "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
              "设置",
              InkWell(
                child: Icon(FlutterRemix.close_line, size: 24),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  textDirection: TextDirection.ltr,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FlutterRemix.calendar_line,
                              color: readColor(),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: Text(
                                "当前学年",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        Text(
                          AppData.persistentData["yearBk"] ?? "",
                          style: TextStyle(
                            color: readColor(),
                          ),
                        ),
                        // DropdownButton(
                        //   iconEnabledColor: readColor(),
                        //   elevation: 0,
                        //   hint: Text(
                        //     AppData.writeData["yearBk"],
                        //     style: TextStyle(
                        //       color: readColor(),
                        //     ),
                        //   ),
                        //   items: yearList(1),
                        //   underline: Container(height: 0),
                        //   onChanged: (value) {
                        //     setState(() {
                        //       AppData.writeData["yearBk"] = value;
                        //     });
                        //   },
                        // )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FlutterRemix.mickey_line,
                              color: readColor(),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: Text(
                                "当前学期",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                        Text(AppData.persistentData["semester"] ?? "",
                            style: TextStyle(
                              color: readColor(),
                            )),
                        // DropdownButton(
                        //   iconEnabledColor: readColor(),
                        //   isDense: true,
                        //   elevation: 0,
                        //   hint: Text(AppData.writeData["semester"],
                        //       style: TextStyle(
                        //         color: readColor(),
                        //       )),
                        //   underline: Container(height: 0),
                        //   items:  [
                        //     DropdownMenuItem(child: Text("春"), value: "春"),
                        //     DropdownMenuItem(child: Text("秋"), value: "秋"),
                        //   ],
                        //   onChanged: (value) {
                        //     setState(() {
                        //       AppData.writeData["semester"] = value;
                        //       AppData.writeData["semesterBk"] = value;
                        //     });
                        //   },
                        // ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FlutterRemix.game_line,
                              color: readColor(),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: Text(
                                "当前周数",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                        Text(AppData.persistentData["week"] ?? "",
                            style: TextStyle(
                              color: readColor(),
                            )),
                        // DropdownButton(
                        //   iconEnabledColor: readColor(),
                        //   isDense: true,
                        //   elevation: 0,
                        //   hint: Text(AppData.writeData["week"],
                        //       style: TextStyle(
                        //         color: readColor(),
                        //       )),
                        //   underline: Container(height: 0),
                        //   items: [
                        //     DropdownMenuItem(child: Text("暂"), value: ""),
                        //     DropdownMenuItem(child: Text("时"), value: ""),
                        //     DropdownMenuItem(child: Text("不"), value: ""),
                        //     DropdownMenuItem(child: Text("允"), value: ""),
                        //     DropdownMenuItem(child: Text("许"), value: ""),
                        //     DropdownMenuItem(child: Text("更"), value: ""),
                        //     DropdownMenuItem(child: Text("改"), value: ""),
                        //   ],
                        //   onChanged: (value) {},
                        // ),
                      ],
                    ),
                    topLine,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FlutterRemix.palette_line,
                              color: readColor(),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: Text(
                                "主题颜色",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        Builder(builder: (BuildContext context) {
                          return DropdownButton(
                            value: AppData.persistentData["color"] ?? null,
                            icon: Icon(
                              FlutterRemix.arrow_down_s_line,
                              size: 18,
                            ),
                            enableFeedback: true,
                            iconEnabledColor: readColor(),
                            elevation: 0,
                            items: [
                              DropdownMenuItem(
                                  child: Text(
                                    "red",
                                    style: TextStyle(color: Colors.redAccent),
                                  ),
                                  value: "red"),
                              DropdownMenuItem(
                                  child: Text(
                                    "blue",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                  value: "blue"),
                              DropdownMenuItem(
                                  child: Text(
                                    "cyan",
                                    style: TextStyle(color: Colors.cyan[400]),
                                  ),
                                  value: "cyan"),
                              DropdownMenuItem(
                                  child: Text(
                                    "pink",
                                    style: TextStyle(color: Colors.pinkAccent[100]),
                                  ),
                                  value: "pink"),
                              DropdownMenuItem(
                                  child: Text(
                                    "yellow",
                                    style: TextStyle(color: Colors.yellow[600]),
                                  ),
                                  value: "yellow"),
                            ],
                            underline: Container(),
                            onChanged: (value) {
                              setState(() {
                                AppData.persistentData["color"] = value.toString();
                              });
                              writeConfig();
                              eventBus.fire(SetPageIndex());
                              Navigator.pushAndRemoveUntil(
                                context,
                                CustomRouter(CustomView()),
                                (route) => false,
                              );
                            },
                          );
                        })
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              FlutterRemix.apps_2_line,
                              color: readColor(),
                            ),
                            Container(
                              padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: Text(
                                "APP生命",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        Builder(builder: (BuildContext context) {
                          return DropdownButton(
                            icon: Icon(
                              FlutterRemix.arrow_down_s_line,
                              size: 18,
                            ),
                            enableFeedback: true,
                            // style: TextStyle(color: readColor()),
                            iconEnabledColor: readColor(),
                            elevation: 0,
                            hint: Text(
                              (AppData.persistentData["threshold"] ?? "5") + "分钟",
                              style: TextStyle(color: readColor(), fontSize: 14),
                            ),
                            items: thresholdItemList(),
                            underline: Container(height: 0),
                            onChanged: (value) {
                              setState(() {
                                AppData.persistentData["threshold"] = value.toString();
                              });
                              writeConfig();
                            },
                          );
                        })
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScheduleManagePage()));
                      },
                      child: mineItem(FlutterRemix.edit_box_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "课程管理", readColor()),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(MaterialPageRoute(builder: (context) => TimeManagePage()));
                      },
                      child: mineItem(FlutterRemix.timer_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "课节时间", readColor()),
                    ),
                    CustomExpansionTile.ExpansionTile(
                      onExpansionChanged: (e) {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      collapsedIconColor: Colors.black45,
                      iconColor: Colors.redAccent,
                      tilePadding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: Row(
                        children: [
                          Icon(_isExpanded ? FlutterRemix.alarm_warning_line : FlutterRemix.delete_bin_2_line,
                              color: _isExpanded ? Colors.redAccent : readColor()),
                          Container(
                            padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
                            child: Text(
                              "清除数据",
                              style: TextStyle(
                                fontSize: 16,
                                color: _isExpanded ? Colors.redAccent : Colors.black,
                              ),
                            ),
                          )
                        ],
                      ),
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              "此操作不可逆",
                              style: TextStyle(
                                color: _isExpanded ? Colors.redAccent : Colors.black,
                              ),
                            ),
                            TextButton(
                              style: buttonStyle(),
                              onPressed: () {
                                clear();
                              },
                              child: Text(
                                "确定清除",
                                style: TextStyle(
                                  color: _isExpanded ? Colors.redAccent : Colors.black,
                                ),
                              ),
                            )
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void clear() async {
    await clearAll();
    AppData.persistentData["username"] = "";
    AppData.persistentData["name"] = "";
    AppData.persistentData["password"] = "";
    await initSchedule();
    AppData.todaySchedule = [];
    AppData.tomorrowSchedule = [];
    eventBus.fire(ReloadTodayListState());
    eventBus.fire(ReloadTomorrowListState());
    // await Global.todayCourseListKey.currentState!.reloadState();
    // await Global.tomorrowCourseListKey.currentState!.reloadState();
    eventBus.fire(SetPageIndex());
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => Init(),
      ),
      (route) => false,
    );
  }
}

Widget settingItem(IconData icon, EdgeInsets padding, String title, int type) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon),
          Container(
            padding: padding,
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
      SizedBox(
        width: 40,
        child: TextField(
          keyboardType: (type == 0 ? TextInputType.number : TextInputType.text),
          textAlign: TextAlign.end,
          decoration: InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  );
}

List<DropdownMenuItem<Object>>? yearList(int type) {
  List<DropdownMenuItem<Object>>? list = [];
  if (type == 0) {
    list.add(
      DropdownMenuItem(child: Text("全部"), value: "全部"),
    );
  } else {
    list.add(DropdownMenuItem(child: Text((int.parse(AppData.persistentData["year"] ?? "") + 1).toString()), value: (int.parse(AppData.persistentData["year"] ?? "") + 1).toString()));
  }

  for (int i = int.parse(AppData.persistentData["year"] ?? ""); i > (int.parse(AppData.persistentData["year"] ?? "") - 5); i--) {
    list.add(DropdownMenuItem(child: Text(i.toString()), value: i.toString()));
  }
  return list;
}

List<DropdownMenuItem<String>> thresholdItemList() {
  List<DropdownMenuItem<String>> list = [];
  Map<String, String> cache = const {"5分钟": "5", "10分钟": "10", "20分钟": "20", "40分钟": "40", "不限": "-1"};

  cache.forEach((key, value) {
    print(key);
    print(value);
    list.add(DropdownMenuItem(
        child: Text(
          key,
          style: TextStyle(fontSize: 14),
        ),
        value: value));
  });
  print(list[0]);
  return list;
}
