import 'package:flutter/material.dart';
import 'package:glutassistantn/common/log.dart';
import 'package:remixicon/remixicon.dart';

import '/common/io.dart';
import '/common/style.dart';
import '/custom/expansiontile.dart' as CustomExpansionTile;
import '/pages/timeManager.dart';
import '/widget/bars.dart';
import '../config.dart';
import '../data.dart';
import '../widget/cards.dart';
import '../widget/lists.dart';
import 'layout.dart';
import 'mine.dart';

List<DropdownMenuItem<String>> dropdownMenuColorItems() {
  List<DropdownMenuItem<String>> widgets = [];
  for (var color in colorTexts) {
    widgets.add(DropdownMenuItem(
        child: Text(
          color,
          style: TextStyle(color: readColor(color)),
        ),
        value: color));
  }
  return widgets;
}

class SettingPage extends StatefulWidget {
  final String title;

  SettingPage({Key? key, this.title = "设置"}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> with WidgetsBindingObserver {
  FocusNode focusNode = FocusNode();
  FocusNode focusNode2 = FocusNode();
  bool _isExpanded = false;
  bool focusNode2Type = false;
  bool focusNodeType = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: readBackgroundColor(),
      body: Container(
        margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
                "设置",
                InkWell(
                  child: Icon(
                    Remix.close_line,
                    size: 24,
                    color: readTextColor(),
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                readBackgroundColor(),
                readTextColor()),
            SliverToBoxAdapter(
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
                child: Column(
                  textDirection: TextDirection.ltr,
                  children: [
                    CustomCard(
                      child: Column(
                        children: [
                          settingItem(
                            Remix.calendar_line,
                            "当前学年",
                            Text(
                              AppData.year.toString(),
                              style: TextStyle(
                                color: readColor(),
                              ),
                            ),
                          ),
                          ColumnGap(),
                          settingItem(
                            Remix.mickey_line,
                            "当前学期",
                            Text(
                              AppData.semester,
                              style: TextStyle(
                                color: readColor(),
                              ),
                            ),
                          ),
                          ColumnGap(),
                          settingItem(
                            Remix.game_line,
                            "当前周数",
                            Text(
                              AppData.week.toString(),
                              style: TextStyle(
                                color: readColor(),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    ColumnGap(16),
                    CustomCard(
                      child: Column(children: [
                        settingItem(
                          Remix.palette_line,
                          "主题颜色",
                          Builder(
                            builder: (BuildContext context) {
                              return DropdownButton<String>(
                                value: AppData.theme,
                                icon: Icon(
                                  Remix.arrow_down_s_line,
                                  size: 18,
                                ),
                                enableFeedback: true,
                                iconEnabledColor: readColor(),
                                elevation: 0,
                                items: dropdownMenuColorItems(),
                                underline: Container(),
                                onChanged: (value) {
                                  setState(() {
                                    AppData.theme = value!;
                                  });
                                  AppData.isDarkTheme = value == "dark";
                                  writeConfig();
                                  eventBus.fire(SetPageIndex());
                                  eventBus.fire(UpdateAppThemeState());
                                  Navigator.pushAndRemoveUntil(
                                    context,
                                    AppRouter(Layout()),
                                    (route) => false,
                                  );
                                },
                              );
                            },
                          ),
                        ),
                        ColumnGap(),
                        settingItem(Remix.apps_2_line, "程序生命", Builder(builder: (BuildContext context) {
                          return DropdownButton<int>(
                            icon: Icon(
                              Remix.arrow_down_s_line,
                              size: 18,
                            ),
                            enableFeedback: true,
                            // style: TextStyle(color: readColor()),
                            iconEnabledColor: readColor(),
                            elevation: 0,
                            hint: Text(
                              AppData.programBackendSurvivalThreshold.toString() + "分钟",
                              style: TextStyle(color: readColor(), fontSize: 14),
                            ),
                            items: thresholdItemList(),
                            underline: Container(height: 0),
                            onChanged: (value) {
                              setState(() {
                                AppData.programBackendSurvivalThreshold = value!;
                              });
                              writeConfig();
                            },
                          );
                        })),
                        ColumnGap(),
                        settingItem(
                          Remix.timer_2_line,
                          "小节时间",
                          Builder(
                            builder: (BuildContext context) {
                              return DropdownButton<bool>(
                                icon: Icon(
                                  Remix.arrow_down_s_line,
                                  size: 18,
                                ),
                                enableFeedback: true,
                                // style: TextStyle(color: readColor()),
                                iconEnabledColor: readColor(),
                                elevation: 0,
                                hint: Text(
                                  AppData.showLessonTimeInList ? "显示" : "隐藏",
                                  style: TextStyle(color: readColor(), fontSize: 14),
                                ),
                                items: [
                                  DropdownMenuItem(
                                      child: Text(
                                        "显示",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      value: true),
                                  DropdownMenuItem(
                                      child: Text(
                                        "隐藏",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      value: false)
                                ],
                                underline: Container(height: 0),
                                onChanged: (value) {
                                  setState(() {
                                    AppData.showLessonTimeInList = value!;
                                  });
                                  writeConfig();
                                },
                              );
                            },
                          ),
                        ),
                        ColumnGap(),
                        settingItem(
                          Remix.calendar_2_line,
                          "课表日期",
                          Builder(
                            builder: (BuildContext context) {
                              return DropdownButton<bool>(
                                icon: Icon(
                                  Remix.arrow_down_s_line,
                                  size: 18,
                                ),
                                enableFeedback: true,
                                // style: TextStyle(color: readColor()),
                                iconEnabledColor: readColor(),
                                elevation: 0,
                                hint: Text(
                                  AppData.showDayByWeekDay ? "显示" : "隐藏",
                                  style: TextStyle(color: readColor(), fontSize: 14),
                                ),
                                items: [
                                  DropdownMenuItem(
                                      child: Text(
                                        "显示",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      value: true),
                                  DropdownMenuItem(
                                      child: Text(
                                        "隐藏",
                                        style: TextStyle(fontSize: 14),
                                      ),
                                      value: false)
                                ],
                                underline: Container(height: 0),
                                onChanged: (value) {
                                  setState(() {
                                    AppData.showDayByWeekDay = value!;
                                  });
                                  writeConfig();
                                  eventBus.fire(ReloadSchedulePageState());
                                },
                              );
                            },
                          ),
                        ),
                        ColumnGap(),
                        settingItem(Remix.exchange_2_line, "调课补课", Builder(builder: (BuildContext context) {
                          return DropdownButton<bool>(
                            icon: Icon(
                              Remix.arrow_down_s_line,
                              size: 18,
                            ),
                            enableFeedback: true,
                            // style: TextStyle(color: readColor()),
                            iconEnabledColor: readColor(),
                            elevation: 0,
                            hint: Text(
                              AppData.showScheduleChange ? "显示" : "隐藏",
                              style: TextStyle(color: readColor(), fontSize: 14),
                            ),
                            items: [
                              DropdownMenuItem(
                                  child: Text(
                                    "显示",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  value: true),
                              DropdownMenuItem(
                                  child: Text(
                                    "隐藏",
                                    style: TextStyle(fontSize: 14),
                                  ),
                                  value: false)
                            ],
                            underline: Container(height: 0),
                            onChanged: (value) {
                              setState(() {
                                AppData.showScheduleChange = value!;
                              });
                              writeConfig();
                            },
                          );
                        })),
                      ]),
                    ),
                    ColumnGap(16),
                    CustomCard(
                      child: Column(
                        children: [
                          InkWell(
                            onTap: () {
                              Navigator.of(context).push(MaterialPageRoute(builder: (context) => TimeManagePage()));
                            },
                            child: LinkItem(Remix.timer_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "课节时间", readColor()),
                          ),
                          ColumnGap(),
                          InkWell(
                            onTap: () async {
                              ScaffoldMessenger.of(context).removeCurrentSnackBar();
                              ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "准备文件中...", 4));
                              shareLogFile();
                            },
                            child: LinkItem(Remix.bug_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "导出日志", readColor()),
                          ),
                          ColumnGap(),
                          // InkWell(
                          //   onTap: () {
                          //     Navigator.of(context).push(MaterialPageRoute(builder: (context) => ScheduleManagePage()));
                          //   },
                          //   child: mineItem(Remix.edit_box_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "课程管理", readColor()),
                          // ),
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
                                Icon(_isExpanded ? Remix.alarm_warning_line : Remix.delete_bin_2_line,
                                    color: _isExpanded ? Colors.redAccent : readColor()),
                                Container(
                                  padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
                                  child: Text(
                                    "清除数据",
                                    style: TextStyle(
                                        fontSize: 16, color: _isExpanded ? Colors.redAccent : readTextColor()),
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
                    ColumnGap(16),
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
    AppData.studentId = "";
    AppData.studentName = "";
    AppData.password = "";
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
        builder: (context) => DataPreloadPage(),
      ),
      (route) => false,
    );
  }
}

Widget settingItem(IconData icon, String title, Widget rightWidget) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(
            icon,
            color: readColor(),
          ),
          Container(
            padding: EdgeInsets.fromLTRB(16, 14, 0, 14),
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: readTextColor()),
            ),
          )
        ],
      ),
      rightWidget
    ],
  );
}

List<DropdownMenuItem<String>>? yearList(int type) {
  final int year= AppData.year;
  List<DropdownMenuItem<String>>? list = [];
  if (type == 0) {
    list.add(
      DropdownMenuItem(child: Text("全部"), value: "全部"),
    );
  } else {
    list.add(DropdownMenuItem(
        child: Text((year + 1).toString()),
        value: (year + 1).toString()));
  }

  for (int i = year; i > year - 5; i--) {
    list.add(DropdownMenuItem(child: Text(i.toString()), value: i.toString()));
  }
  return list;
}

List<DropdownMenuItem<int>> thresholdItemList() {
  List<DropdownMenuItem<int>> list = [];
  Map<String, int> cache = const {"5分钟": 5, "10分钟": 10, "20分钟": 20, "40分钟": 40, "不限": -1};

  cache.forEach((key, value) {
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
