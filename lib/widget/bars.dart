import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutnnbox/config.dart';

import '../data.dart';

SliverAppBar homeTopBar = SliverAppBar(
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
        children: const [
          Text(
            '今日一览',
            style: TextStyle(
              color: Colors.black,
            ),
          ),
          Icon(Icons.settings, size: 24)
        ],
      ),
      titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 12)),
);
AppBar scheduleTopBar = AppBar(
  automaticallyImplyLeading: false,
  elevation: 0.3,
  backgroundColor: Colors.white,
  title: Text(
    "第 ${writeData['week']} 周",
    style: const TextStyle(color: Colors.black),
  ),
);

class BottomNavBar extends StatefulWidget {
  const BottomNavBar({Key? key}) : super(key: key);

  @override
  BottomNavBarState createState() => BottomNavBarState();
}

class BottomNavBarState extends State<BottomNavBar> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      border: const Border(
          top: BorderSide(
        color: Colors.white,
      )),
      backgroundColor: Colors.white,
      activeColor: Colors.blue,
      // 图标高亮颜色
      inactiveColor: Colors.grey,
      // 图
      currentIndex: Global.pageIndex,
      onTap: (int index) {
        setState(() {
          if (Global.pageIndex != index) {
            // Global.pageControl.animateToPage(index,
            //     duration: const Duration(milliseconds: 300), curve: Curves.easeOutCirc);
            Global.pageControl.jumpToPage(index);
            Global.pageIndex = index;
          }
        });
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
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      children: <Widget>[resultIcon, Text(text)],
    ),
    behavior: SnackBarBehavior.floating,
  );
}
