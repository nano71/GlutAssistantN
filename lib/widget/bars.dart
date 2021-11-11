// 引入 eventBus 包文件
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutassistantn/config.dart';
import 'package:glutassistantn/pages/setting.dart';

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
                '今日一览',
                style: TextStyle(
                  color: Colors.black,
                ),
              ),
              InkWell(
                child: const Icon(Icons.settings, size: 24),
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

SliverAppBar publicTopBar(String title, [inkWell = const Text("")]) {
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
              (title),
              style: const TextStyle(
                color: Colors.black,
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
            "第 $_week 周",
            style: const TextStyle(color: Colors.black),
          ),
          InkWell(
            child: goCurrent,
            onTap: () {
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
  var eventBusFn;

  @override
  void initState() {
    super.initState();
    eventBusFn = pageBus.on<SetPageIndex>().listen((event) {
      Global.pageControl.jumpToPage(event.index);

      Global.pageIndex = event.index;
      setState(() {});
    });
  }

  @override
  void dispose() {
    super.dispose();
    //取消订阅
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
      activeColor: Colors.blue,
      inactiveColor: Colors.grey,
      currentIndex: Global.pageIndex,
      onTap: (int index) {
        setState(
          () {
            if (Global.pageIndex != index) {
              Global.pageControl.jumpToPage(index);
              Global.pageIndex = index;
            }
          },
        );
      },
      items: const [
        BottomNavigationBarItem(
            tooltip: '',
            icon: Icon(
              Icons.home,
            ),
            label: ''),
        BottomNavigationBarItem(
            tooltip: '',
            icon: Icon(
              Icons.insert_invitation_sharp,
            ),
            label: ''),
        BottomNavigationBarItem(
            tooltip: '',
            icon: Icon(
              Icons.mood,
            ),
            label: ''),
      ],
    );
  }
}

SnackBar jwSnackBar(bool result, String text, [int hideSnackBarSeconds = 2]) {
  Widget resultIcon = result
      ? const Icon(
          Icons.mood,
          color: Colors.green,
        )
      : const Icon(
          Icons.mood_bad,
          color: Colors.red,
        );
  return SnackBar(
    elevation: 2,
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[resultIcon, Text(text)],
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
          Icons.mood,
          color: Colors.green,
        )
      : const Icon(
          Icons.mood_bad,
          color: Colors.red,
        );
  return SnackBar(
    elevation: 2,
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
