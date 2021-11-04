import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutnnbox/common/global.dart';

Widget indexZeroAppBar = SliverAppBar(
  pinned: true,
  collapsedHeight: 56.00,
  primary: true,
  backgroundColor: Colors.white,
  stretch: true,
  expandedHeight: 125.0,
  elevation: 0.3,
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

class PageControl extends StatefulWidget {
  const PageControl({Key? key}) : super(key: key);

  @override
  BottomNavBar createState() => BottomNavBar();
}

class BottomNavBar extends State<PageControl> {
  @override
  Widget build(BuildContext context) {
    return CupertinoTabBar(
      border: const Border(
          top: BorderSide(
        color: Colors.white,
      )),
      backgroundColor: Colors.white,
      activeColor: Colors.blue, // 图标高亮颜色
      inactiveColor: Colors.grey, // 图
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
        print(Global.pageIndex);
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
