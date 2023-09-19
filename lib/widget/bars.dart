// 引入 eventBus 包文件
import 'dart:async';

import 'package:badges/badges.dart' as badges;
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:flutter_swiper_view/flutter_swiper_view.dart';

import '/config.dart';
import '/pages/setting.dart';
import '../common/get.dart';
import '../common/style.dart';
import '../data.dart';
import 'dialog.dart';
import 'icons.dart';

SliverAppBar homeTopBar(BuildContext context) {
  return SliverAppBar(
    pinned: true,
    collapsedHeight: 56.00,
    primary: true,
    backgroundColor: Colors.white,
    stretch: true,
    expandedHeight: 125.0,
    elevation: 0.3,
    automaticallyImplyLeading: false,
    flexibleSpace: FlexibleSpaceBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "今日一览",
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            InkWell(
              child: Icon(FlutterRemix.more_fill, size: 24),
              onTap: () {
                Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingPage(title: "设置")));
              },
            )
          ],
        ),
        titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 12)),
  );
}

SliverAppBar publicTopBar(String title, [dynamic inkWell = const Text(""), color = Colors.white, color2 = Colors.black, double e = 0.3]) {
  return SliverAppBar(
    pinned: true,
    shadowColor: color,
    collapsedHeight: 56.00,
    primary: true,
    backgroundColor: color,
    stretch: true,
    expandedHeight: 125.0,
    elevation: e,
    automaticallyImplyLeading: false,
    flexibleSpace: FlexibleSpaceBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            (title),
            style: TextStyle(
              color: color2,
            ),
          ),
          inkWell,
        ],
      ),
      titlePadding: EdgeInsets.fromLTRB(16, 0, 16, 12),
    ),
  );
}

class ScheduleTopBar extends StatefulWidget {
  ScheduleTopBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ScheduleTopBarState();
}

class ScheduleTopBarState extends State<ScheduleTopBar> {
  String _week = AppData.persistentData["week"] ?? "";

  void back() {
    ScaffoldMessenger.of(context).removeCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(3, "回到当前!", 1));
    eventBus.fire(ReloadSchedulePageState());
  }

  String date() {
    DateTime d = DateTime.now();
    return "${d.year}-${d.month}-${d.day}";
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0.3,
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          InkWell(
            child: Text(
              "Week $_week",
              style: TextStyle(color: Colors.black),
            ),
            onTap: () {
              back();
            },
          ),
          InkWell(
            child: Row(
              children: [
                Text(
                  date(),
                  style: TextStyle(color: Colors.black, fontSize: 14),
                ),
                goCurrent
              ],
            ),
            onTap: () {
              back();
            },
          )
        ],
      ),
    );
  }

  void onPressed(int week) {
    setState(() => _week = week.toString());
  }
}

class BottomNavBar extends StatefulWidget {
  BottomNavBar({Key? key}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  late StreamSubscription<SetPageIndex> eventBusListener;

  @override
  void initState() {
    super.initState();
    eventBusListener = eventBus.on<SetPageIndex>().listen((event) {
      setState(() {
        AppConfig.pageControl.jumpToPage(event.index);
        AppConfig.pageIndex = event.index;
      });
    });
  }

  @override
  void dispose() {
    eventBusListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("BottomNavBar create");
    return NavigationBar(
      // border: Border(
      //   top: BorderSide(
      //     color: Colors.white,
      //   ),
      // ),
      animationDuration: Duration(seconds: 1),
      backgroundColor: Colors.grey.shade50,
      indicatorColor: readColorEnd(),
      shadowColor: Colors.transparent,
      surfaceTintColor: Colors.black87,
      selectedIndex: AppConfig.pageIndex,
      onDestinationSelected: (int index) {
        if (AppConfig.pageIndex != index) {
          AppConfig.pageControl.jumpToPage(index);
          AppConfig.pageIndex = index;
        }
        setState(() {});
      },
      destinations: [
        NavigationDestination(
          icon: Icon(
            FlutterRemix.home_3_line,
          ),
          selectedIcon: Icon(
            FlutterRemix.home_3_fill,
            color: readColor(),
          ),
          label: "一览",
        ),
        NavigationDestination(
          icon: Icon(
            FlutterRemix.calendar_todo_line,
          ),
          selectedIcon: Icon(
            FlutterRemix.calendar_todo_fill,
            color: readColor(),
          ),
          label: "课表",
        ),
        NavigationDestination(
          selectedIcon: badges.Badge(
            // animationType: BadgeAnimationType.scale,
            showBadge: AppData.hasNewVersion,
            badgeContent: Text(
              "1",
              style: TextStyle(color: Colors.white),
            ),
            child: Icon(
              FlutterRemix.emotion_happy_fill,
              color: readColor(),
            ),
          ),
          icon: badges.Badge(
            // animationType: BadgeAnimationType.scale,
            showBadge: AppData.hasNewVersion,
            badgeContent: Text(
              "1",
              style: TextStyle(color: Colors.white),
            ),
            child: Icon(
              FlutterRemix.emotion_happy_line,
            ),
          ),
          label: "我的",
        ),
      ],
    );
  }
}

class ExamsTipsBar extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => ExamsTipsBarState();
}

class ExamsTipsBarState extends State<ExamsTipsBar> {
  @override
  Widget build(BuildContext context) {
    getRecentExam();
    return Column(
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Text("近期考试", style: tomorrowAndTodayTextStyle()),
        ),
        Container(
          margin: EdgeInsets.fromLTRB(0, 16, 0, 16),
          height: 150,
          child: new Swiper(
            itemBuilder: (BuildContext context, int index) {
              return Container(
                padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
                decoration: BoxDecoration(
                  color: readColorBegin(),
                  borderRadius: BorderRadius.all(
                    Radius.circular(12.0),
                  ),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        child: Text(
                          "大",
                          style: TextStyle(fontSize: 128, color: Color(0x66f1f1f1)),
                        ),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          courseLongText2Short("大学英语(二)"),
                          style: TextStyle(fontSize: 20, color: readColor()),
                        ),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                          "教师: ",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "地点: ",
                          style: TextStyle(color: Colors.black54),
                        ),
                        Text(
                          "时间: ",
                          style: TextStyle(color: Colors.black54),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
            itemCount: 1,
            viewportFraction: 0.8,
            scale: 0.9,
          ),
        ),
      ],
    );
  }
}

SnackBar jwSnackBar(int type, String text, [int hideSnackBarSeconds = 2, double margin = 100]) {
  Widget setIcon() {
    if (type == 0)
      return Icon(
        FlutterRemix.error_warning_line,
        color: Colors.red,
      );
    if (type == 1)
      return Icon(
        FlutterRemix.checkbox_circle_line,
        color: Colors.green,
      );
    if (type == 2)
      return Icon(
        FlutterRemix.link,
        color: Colors.blue,
      );
    return Icon(
      FlutterRemix.star_smile_line,
      color: randomColors2(),
    );
  }

  Widget resultIcon = setIcon();

  return SnackBar(
    margin: EdgeInsets.fromLTRB(margin, 0, margin, 50),
    padding: EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    elevation: 0,
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        resultIcon,
        Padding(
          padding: EdgeInsets.only(bottom: 2, right: 4),
          child: Text(
            text,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
    behavior: SnackBarBehavior.floating,
  );
}

SnackBar jwSnackBarAction(bool result, String text, BuildContext context, Function callback, {int hideSnackBarSeconds = 2, bool isDialogCallback = true}) {
  Widget resultIcon = result
      ? Icon(
          FlutterRemix.checkbox_circle_line,
          color: Colors.green,
        )
      : Icon(
          FlutterRemix.error_warning_line,
          color: Colors.red,
        );
  final screenWidth = MediaQuery.of(context).size.width;
  return SnackBar(
      elevation: 0,
      margin: EdgeInsets.fromLTRB(100, 0, 100, 50),
      padding: EdgeInsets.fromLTRB(12, 12, 16, 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(50.0),
      ),
      duration: Duration(seconds: hideSnackBarSeconds),
      content: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          resultIcon,
          InkWell(
            highlightColor: Colors.transparent, // 透明色
            splashColor: Colors.transparent, // 透明色
            onTap: () {
              if (isDialogCallback) {
                codeCheckDialog(context, callback);
              } else {
                callback();
              }
            },
            child: Text(
              text,
              style: TextStyle(color: Colors.blue),
            ),
          )
        ],
      ),
      behavior: SnackBarBehavior.floating);
}
