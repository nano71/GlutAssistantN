import 'package:badges/badges.dart' as badges;
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutassistantn/widget/cards.dart';
import 'package:glutassistantn/widget/lists.dart';
import 'package:remixicon/remixicon.dart';

import '/pages/career.dart';
import '/pages/queryClassRoom.dart';
import '/pages/setting.dart';
import '/pages/update.dart';
import '/widget/bars.dart';
import '/widget/icons.dart';
import '../config.dart';
import '../data.dart';
import 'about.dart';
import 'layout.dart';
import 'login.dart';

class MinePage extends StatefulWidget {
  MinePage({Key? key}) : super(key: key);

  @override
  _MinePageState createState() => _MinePageState();
}

class _MinePageState extends State<MinePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // checkNewVersion(context, skipShowSnackBar: true);
  }

  @override
  Widget build(BuildContext context) {
    String text;
    if (AppData.isLoggedIn) {
      text = "Hi! " + AppData.studentName;
    } else {
      text = "请先登录教务";
    }
    return CustomScrollView(physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), slivers: [
      publicTopBar(text, Text(""), readBackgroundColor(), readTextColor()),
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
                InkWell(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => LoginPage(),
                      ),
                    );
                  },
                  child: LinkItem(
                    Remix.user_5_line,
                    EdgeInsets.fromLTRB(16, 14, 0, 14),
                    (AppData.isLoggedIn ? "更换账号" : "登录教务"),
                    readColor(),
                  ),
                ),
                ColumnGap(),
                InkWell(
                  onTap: () {
                    if (!AppData.isLoggedIn) {
                      // Navigator.push(context, SlideTopRoute(page: LoginPage()));
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => CareerPage()));
                    }
                  },
                  child: LinkItem(Remix.timer_flash_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "课程生涯", readColor()),
                ),
                ColumnGap(),
                InkWell(
                  onTap: () {
                    if (!AppData.isLoggedIn) {
                      // Navigator.push(context, SlideTopRoute(page: LoginPage()));
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                    } else {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueryRoomPage()));
                    }
                  },
                  child: LinkItem(Remix.building_4_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "教室查询", readColor()),
                ),
              ],
            )),
            ColumnGap(16),
            CustomCard(
              child: Column(
                children: [
                  InkWell(
                    onTap: () {
                      // launch("https://github.com/ChinaGamer/GlutAssistantN/releases/latest");

                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdatePage()));
                    },
                    child: AppData.hasNewVersion
                        ? mineItem5(
                            Remix.download_cloud_2_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "版本更新", readColor())
                        : LinkItem(
                            Remix.download_cloud_2_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "版本更新", readColor()),
                  ),
                  ColumnGap(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => AboutPage()));
                    },
                    child: LinkItem(Remix.information_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "说明", readColor()),
                  ),
                  ColumnGap(),
                  InkWell(
                    onTap: () {
                      Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingPage()));
                    },
                    child: LinkItem(Remix.settings_3_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "设置", readColor()),
                  ),
                ],
              ),
            ),
          ],
        ),
      )),
    ]);
  }
}

Widget LinkItem(IconData icon, EdgeInsets padding, String title, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, color: color),
          Container(
            padding: padding,
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: readTextColor()),
            ),
          )
        ],
      ),
      chevronRight()
    ],
  );
}

Widget mineItem5(IconData icon, EdgeInsets padding, String title, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, color: color),
          Container(
              padding: padding,
              child: badges.Badge(
                badgeContent: Text(''),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16),
                ),
              ))
        ],
      ),
      chevronRight()
    ],
  );
}

Widget mineItem4(IconData icon, EdgeInsets padding, String title, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, color: color),
          Container(
            padding: padding,
            child: Text(
              title,
              style: TextStyle(fontSize: 16, color: readTextColor()),
            ),
          )
        ],
      )
    ],
  );
}

Widget mineItem3(IconData icon, EdgeInsets padding, String title, Color color) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(icon, color: color),
          Container(
            padding: padding,
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
      Icon(
        Icons.link,
        color: Colors.black45,
      ),
    ],
  );
}

Widget mineItem2(IconData icon, EdgeInsets padding, String title) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Row(
        children: [
          Icon(
            icon,
          ),
          Container(
            padding: padding,
            child: Text(
              title,
              style: TextStyle(fontSize: 16),
            ),
          )
        ],
      ),
      chevronDown()
    ],
  );
}
