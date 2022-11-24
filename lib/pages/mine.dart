import 'package:badges/badges.dart';
import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/pages/career.dart';
import 'package:glutassistantn/pages/queryroom.dart';
import 'package:glutassistantn/pages/setting.dart';
import 'package:glutassistantn/pages/update.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/icons.dart';

import '../config.dart';
import '../data.dart';
import 'info.dart';
import 'login.dart';

class MinePage extends StatefulWidget {
  MinePage({Key? key}) : super(key: key);

  @override
  MinePageState createState() => MinePageState();
}

class MinePageState extends State<MinePage> {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    // checkNewVersion(context, skipShowSnackBar: true);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: CustomScrollView(physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()), slivers: [
        publicTopBar(writeData["name"] != "" ? "Hi! " + (writeData["name"] ?? "") : "请先登录教务"),
        SliverToBoxAdapter(
            child: Container(
          width: double.infinity,
          padding: EdgeInsets.fromLTRB(16, 14, 16, 0),
          child: Column(
            textDirection: TextDirection.ltr,
            children: [
              InkWell(
                onTap: () {
                  Navigator.of(context).push(
                    // 在FormPage()里传入参数
                    MaterialPageRoute(
                      builder: (context) => LoginPage(),
                    ),
                  );
                },
                child: mineItem(
                  FlutterRemix.user_5_line,
                  EdgeInsets.fromLTRB(16, 14, 0, 14),
                  (writeData["name"] != "" ? "更换账号" : "登录教务"),
                  readColor(),
                ),
              ),
              InkWell(
                onTap: () {
                  if (writeData["username"] == "") {
                    // Navigator.push(context, SlideTopRoute(page: LoginPage()));
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => CareerPage()));
                  }
                },
                child: mineItem(FlutterRemix.timer_flash_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "课程生涯", readColor()),
              ),
              InkWell(
                onTap: () {
                  if (writeData["username"] == "") {
                    // Navigator.push(context, SlideTopRoute(page: LoginPage()));
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                  } else {
                    Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueryRoomPage()));
                  }
                },
                child: mineItem(FlutterRemix.building_4_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "教室查询", readColor()),
              ),
              topLine,
              InkWell(
                onTap: () {
                  // launch("https://github.com/ChinaGamer/GlutAssistantN/releases/latest");

                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => UpdatePage()));
                },
                child: hasNewVersion
                    ? mineItem5(FlutterRemix.download_cloud_2_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "版本更新", readColor())
                    : mineItem(FlutterRemix.download_cloud_2_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "版本更新", readColor()),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => InfoPage()));
                },
                child: mineItem(FlutterRemix.information_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "说明", readColor()),
              ),
              InkWell(
                onTap: () {
                  Navigator.of(context).push(MaterialPageRoute(builder: (context) => SettingPage(title: "设置2")));
                },
                child: mineItem(FlutterRemix.settings_3_line, EdgeInsets.fromLTRB(16, 14, 0, 14), "设置", readColor()),
              ),
            ],
          ),
        )),
      ]),
    );
  }
}

Container topLine = Container(
  width: double.infinity,
  margin: EdgeInsets.fromLTRB(16, 14, 16, 14),
  decoration: BoxDecoration(
    border: Border(
      top: BorderSide(
        width: 1, //宽度
        color: Color(0x60eeeeee), //边框颜色
      ),
    ),
  ),
);

Widget mineItem(IconData icon, EdgeInsets padding, String title, Color color) {
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
      chevronRight
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
              child: Badge(
                toAnimate: false,
                badgeContent: Text(''),
                child: Text(
                  title,
                  style: TextStyle(fontSize: 16),
                ),
              ))
        ],
      ),
      chevronRight
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
              style: TextStyle(fontSize: 16),
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
      chevronDown
    ],
  );
}
