import 'package:flutter/material.dart';
import 'package:glutassistantn/common/init.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/common/style.dart';
import 'package:glutassistantn/pages/schedulemanage.dart';
import 'package:glutassistantn/pages/timemanage.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../config.dart';
import '../data.dart';
import 'init.dart';
import 'mine.dart';

class SettingPage extends StatefulWidget {
  final String title;

  const SettingPage({Key? key, this.title = "返回"}) : super(key: key);

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

    _textFieldController1.text = writeData["year"];
    _textFieldController2.text = writeData["semester"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
              "设置",
              InkWell(
                child: const Icon(Icons.close_outlined, size: 24),
                onTap: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  textDirection: TextDirection.ltr,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.date_range_outlined,
                              color: readColor(),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: const Text(
                                "当前学年",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        DropdownButton(
                          iconEnabledColor: readColor(),
                          elevation: 0,
                          hint: Text(
                            writeData["yearBk"],
                            style: TextStyle(
                              color: readColor(),
                            ),
                          ),
                          items: yearList(),
                          underline: Container(height: 0),
                          onChanged: (value) {
                            setState(() {
                              writeData["yearBk"] = value;
                            });
                          },
                        )
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.toys_outlined,
                              color: readColor(),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: const Text(
                                "当前学期",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            )
                          ],
                        ),
                        DropdownButton(
                          iconEnabledColor: readColor(),
                          isDense: true,
                          elevation: 0,
                          hint: Text(writeData["semesterBk"],
                              style: TextStyle(
                                color: readColor(),
                              )),
                          underline: Container(height: 0),
                          items: const [
                            DropdownMenuItem(child: Text("春"), value: "春"),
                            DropdownMenuItem(child: Text("秋"), value: "秋"),
                          ],
                          onChanged: (value) {
                            setState(() {
                              writeData["semesterBk"] = value;
                            });
                          },
                        ),
                      ],
                    ),
                    topLine,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Icon(
                              !focusNodeType ? Icons.date_range_outlined : Icons.edit_outlined,
                              color: readColor(),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: const Text(
                                "主题颜色",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        Builder(builder: (BuildContext context) {
                          return DropdownButton(
                            iconEnabledColor: readColor(),
                            elevation: 0,
                            hint: Text(
                              writeData["color"],
                              style: TextStyle(color: readColor()),
                            ),
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
                            underline: Container(height: 0),
                            onChanged: (value) {
                              setState(() {
                                writeData["color"] = value;
                              });
                              writeConfig();
                              pageBus.fire(SetPageIndex(0));
                              Navigator.pushAndRemoveUntil(
                                context,
                                CustomRouteMs300(
                                  const Index(
                                    type: 0,
                                  ),
                                ),
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
                              Icons.flip_to_back,
                              color: readColor(),
                            ),
                            Container(
                              padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
                              child: const Text(
                                "APP生命",
                                style: TextStyle(fontSize: 16, color: Colors.black),
                              ),
                            )
                          ],
                        ),
                        Builder(builder: (BuildContext context) {
                          return DropdownButton(
                            iconEnabledColor: readColor(),
                            elevation: 0,
                            hint: Text(
                              writeData["threshold"] != null
                                  ? writeData["threshold"] + "分钟"
                                  : "5分钟",
                              style: TextStyle(color: readColor()),
                            ),
                            items: [
                              DropdownMenuItem(
                                  child: Text(
                                    "5分钟",
                                  ),
                                  value: "5"),
                              DropdownMenuItem(
                                  child: Text(
                                    "10分钟",
                                  ),
                                  value: "10"),
                              DropdownMenuItem(
                                  child: Text(
                                    "20分钟",
                                  ),
                                  value: "20"),
                              DropdownMenuItem(
                                  child: Text(
                                    "30分钟",
                                  ),
                                  value: "30"),
                              DropdownMenuItem(
                                  child: Text(
                                    "40分钟",
                                  ),
                                  value: "40"),
                              DropdownMenuItem(
                                  child: Text(
                                    "不限",
                                  ),
                                  value: "9999999999"),
                            ],
                            underline: Container(height: 0),
                            onChanged: (value) {
                              setState(() {
                                writeData["threshold"] = value;
                              });
                              writeConfig();
                            },
                          );
                        })
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => const ScheduleManagePage()));
                      },
                      child: mineItem(Icons.grid_view_outlined,
                          const EdgeInsets.fromLTRB(16, 14, 0, 14), "课程管理", readColor()),
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context)
                            .push(MaterialPageRoute(builder: (context) => const TimeManagePage()));
                      },
                      child: mineItem(Icons.more_time_outlined,
                          const EdgeInsets.fromLTRB(16, 14, 0, 14), "课节时间", readColor()),
                    ),
                    ExpansionTile(
                      onExpansionChanged: (e) {
                        setState(() {
                          _isExpanded = !_isExpanded;
                        });
                      },
                      collapsedIconColor: Colors.black45,
                      iconColor: Colors.redAccent,
                      tilePadding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                      title: Row(
                        children: [
                          Icon(
                            _isExpanded
                                ? Icons.warning_amber_rounded
                                : Icons.cleaning_services_outlined,
                            color: _isExpanded ? Colors.redAccent : readColor(),
                          ),
                          Container(
                            padding: const EdgeInsets.fromLTRB(16, 14, 0, 14),
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
    writeData["username"] = "";
    writeData["name"] = "";
    writeData["password"] = "";
    await initSchedule();
    todaySchedule = [];
    tomorrowSchedule = [];
    await todayCourseListKey.currentState!.reSate();
    await tomorrowCourseListKey.currentState!.reSate();
    pageBus.fire(SetPageIndex(0));
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (context) => const InitPage(),
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
              style: const TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
      SizedBox(
        width: 40,
        child: TextField(
          keyboardType: (type == 0 ? TextInputType.number : TextInputType.text),
          textAlign: TextAlign.end,
          decoration: const InputDecoration(
            border: InputBorder.none,
          ),
        ),
      ),
    ],
  );
}

List<DropdownMenuItem<Object>>? yearList() {
  List<DropdownMenuItem<Object>>? list = [];
  list.add(DropdownMenuItem(child: Text("全部"), value: "全部"),);
  for (int i = int.parse(writeData["year"]); i > (int.parse(writeData["year"]) - 5); i--) {
    list.add(DropdownMenuItem(child: Text(i.toString()), value: i.toString()));
  }
  return list;
}
