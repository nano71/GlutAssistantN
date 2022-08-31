// 引入 eventBus 包文件
import 'dart:async';

import 'package:badges/badges.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/config.dart';
import 'package:glutassistantn/pages/login.dart';
import 'package:glutassistantn/pages/setting.dart';
import 'package:package_info/package_info.dart';

import '../data.dart';
import 'dialog.dart';
import 'icons.dart';

class HomeTopBar extends StatelessWidget {
  const HomeTopBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              const Text(
                "今日一览",
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              InkWell(
                child: const Icon(FlutterRemix.more_fill, size: 24),
                onTap: () {
                  Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const SettingPage(title: "设置")));
                },
              )
            ],
          ),
          titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 12)),
    );
  }
}

SliverAppBar publicTopBar(String title,
    [inkWell = const Text(""), color = Colors.white, color2 = Colors.black, double e = 0.3]) {
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
        titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 12)),
  );
}

class ScheduleTopBar extends StatefulWidget {
  const ScheduleTopBar({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => ScheduleTopBarState();
}

class ScheduleTopBarState extends State<ScheduleTopBar> {
  String _week = writeData["week"];

  @override
  Widget build(BuildContext context) {
    return AppBar(
      automaticallyImplyLeading: false,
      elevation: 0.3,
      backgroundColor: Colors.white,
      title: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Week $_week",
            style: const TextStyle(color: Colors.black),
          ),
          InkWell(
            child: goCurrent,
            onTap: () {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(3, "回到当前!", 1));
              pageBus.fire(ReState(1));
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
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  late StreamSubscription<SetPageIndex> eventBusFn;
  String version = writeData["newVersion"];
  bool newVersion = false;

  @override
  void initState() {
    print("初始化");
    super.initState();
    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      version = packageInfo.version;
    });
    eventBusFn = pageBus.on<SetPageIndex>().listen((event) {
      Global.pageControl.jumpToPage(event.index);
      Global.pageIndex = event.index;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    eventBusFn.cancel();
  }

  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      border: const Border(
        top: BorderSide(
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.white,
      activeColor: readColor(),
      inactiveColor: Colors.black87,
      currentIndex: Global.pageIndex,
      onTap: (int index) {
        if (version != writeData["newVersion"]) if (index != 2) {
          newVersion = true;
        } else {
          newVersion = false;
        }
        if (Global.pageIndex != index) {
          Global.pageControl.jumpToPage(index);
          // Global.pageControl.animateToPage(index, duration: Duration(milliseconds: 500), curve: Curves.linear);
          Global.pageIndex = index;
        }
        setState(() {});
      },
      items: [
        BottomNavigationBarItem(
            tooltip: '',
            icon: Icon(
              FlutterRemix.home_3_line,
            ),
            label: ''),
        BottomNavigationBarItem(
            tooltip: '',
            icon: Icon(
              FlutterRemix.calendar_todo_line,
            ),
            label: ''),
        BottomNavigationBarItem(
            tooltip: '',
            icon: Badge(
              animationType: BadgeAnimationType.scale,
              showBadge: newVersion,
              badgeContent: Text(
                "1",
                style: TextStyle(color: Colors.white),
              ),
              child: Icon(
                FlutterRemix.emotion_happy_line,
              ),
            ),
            label: ''),
      ],
    );
  }
}

SnackBar jwSnackBar(int type, String text, [int hideSnackBarSeconds = 2]) {
  Widget setIcon() {
    if (type == 0)
      return const Icon(
        FlutterRemix.error_warning_line,
        color: Colors.red,
      );
    if (type == 1)
      return const Icon(
        FlutterRemix.checkbox_circle_line,
        color: Colors.green,
      );
    if (type == 2)
      return const Icon(
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
    margin: EdgeInsets.fromLTRB(100, 0, 100, 50),
    padding: EdgeInsets.all(12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    elevation: 2,
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

SnackBar jwSnackBarAction(
  bool result,
  String text,
  BuildContext context, [
  int hideSnackBarSeconds = 2,
]) {
  Widget resultIcon = result
      ? const Icon(
          FlutterRemix.checkbox_circle_line,
          color: Colors.green,
        )
      : const Icon(
          FlutterRemix.error_warning_line,
          color: Colors.red,
        );
  return SnackBar(
    elevation: 2,
    margin: EdgeInsets.fromLTRB(100, 0, 100, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[resultIcon],
    ),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: text,
      onPressed: () {
        codeCheckDialog(context);
      },
    ),
  );
}

SnackBar jwSnackBarActionL(
  bool result,
  String text,
  BuildContext context, [
  int hideSnackBarSeconds = 2,
]) {
  Widget resultIcon = result
      ? const Icon(
          FlutterRemix.checkbox_circle_line,
          color: Colors.green,
        )
      : const Icon(
          FlutterRemix.error_warning_line,
          color: Colors.red,
        );
  return SnackBar(
    elevation: 2,
    margin: EdgeInsets.fromLTRB(100, 0, 100, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[resultIcon],
    ),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: text,
      onPressed: () {
        Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const LoginPage(),
            ));
      },
    ),
  );
}

SnackBar jwSnackBarActionQ(
  bool result,
  String text,
  BuildContext context, [
  int hideSnackBarSeconds = 2,
]) {
  Widget resultIcon = result
      ? const Icon(
          FlutterRemix.checkbox_circle_line,
          color: Colors.green,
        )
      : const Icon(
          FlutterRemix.error_warning_line,
          color: Colors.red,
        );
  return SnackBar(
    elevation: 2,
    margin: EdgeInsets.fromLTRB(100, 0, 100, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[resultIcon],
    ),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: text,
      onPressed: () {
        codeCheckDialogQ(context);
      },
    ),
  );
}

SnackBar jwSnackBarActionQ2(
  bool result,
  String text,
  BuildContext context, [
  int hideSnackBarSeconds = 2,
]) {
  Widget resultIcon = result
      ? const Icon(
          FlutterRemix.checkbox_circle_line,
          color: Colors.green,
        )
      : const Icon(
          FlutterRemix.error_warning_line,
          color: Colors.red,
        );
  return SnackBar(
    elevation: 2,
    margin: EdgeInsets.fromLTRB(100, 0, 100, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[resultIcon],
    ),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: text,
      onPressed: () {
        codeCheckDialogQ2(context);
      },
    ),
  );
}

SnackBar jwSnackBarActionQ3(
  bool result,
  String text,
  BuildContext context, [
  int hideSnackBarSeconds = 2,
]) {
  Widget resultIcon = result
      ? const Icon(
          FlutterRemix.checkbox_circle_line,
          color: Colors.green,
        )
      : const Icon(
          FlutterRemix.error_warning_line,
          color: Colors.red,
        );
  return SnackBar(
    elevation: 2,
    margin: EdgeInsets.fromLTRB(100, 0, 100, 50),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(50.0),
    ),
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[resultIcon],
    ),
    behavior: SnackBarBehavior.floating,
    action: SnackBarAction(
      label: text,
      onPressed: () {
        codeCheckDialogQ3(context);
      },
    ),
  );
}
