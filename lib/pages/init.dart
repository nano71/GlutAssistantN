import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/init.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/config.dart';
import 'package:glutassistantn/pages/home.dart';
import 'package:glutassistantn/pages/mine.dart';
import 'package:glutassistantn/pages/schedule.dart';
import 'package:glutassistantn/pages/update.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:package_info/package_info.dart';

import '../data.dart';

class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  CustomRoute(this.widget, [int s = 2])
      : super(
            //父类的方法
            //设置动画持续的时间，建议再1和2之间
            transitionDuration: Duration(seconds: s),
            //页面的构造器
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              //次级动画
              Animation<double> secondaryAnimation,
            ) {
              return widget;
            },
            //过度效果
            transitionsBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation, Widget child) {
              // 过度的动画的值
              return FadeTransition(
                // 过度的透明的效果
                opacity: Tween(begin: 0.0, end: 1.0)
                    // 给他个透明度的动画   CurvedAnimation：设置动画曲线
                    .animate(CurvedAnimation(parent: animation, curve: Curves.ease)),
                child: child,
              );
            });
}

class CustomRouteMs300 extends PageRouteBuilder {
  final Widget widget;

  CustomRouteMs300(this.widget)
      : super(
            //父类的方法
            //设置动画持续的时间，建议再1和2之间
            transitionDuration: const Duration(milliseconds: 300),
            //页面的构造器
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              //次级动画
              Animation<double> secondaryAnimation,
            ) {
              return widget;
            },
            //过度效果
            transitionsBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation, Widget child) {
              // 过度的动画的值
              return FadeTransition(
                // 过度的透明的效果
                opacity: Tween(begin: 0.0, end: 1.0)
                    // 给他个透明度的动画   CurvedAnimation：设置动画曲线
                    .animate(CurvedAnimation(parent: animation, curve: Curves.ease)),
                child: child,
              );
            });
}

class InitPage extends StatefulWidget {
  const InitPage({Key? key}) : super(key: key);

  @override
  InitPageState createState() => InitPageState();
}

class InitPageState extends State<InitPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    PackageInfo.fromPlatform().then((PackageInfo info) {
      packageInfo["appName"] = info.appName;
      packageInfo["packageName"] = info.packageName;
      packageInfo["version"] = info.version;
      // packageInfo["version"] = "1.3.220801";
    });
    await readConfig();
    await readCookie();
    getWeek();
    await readSchedule();
    await initTodaySchedule();
    await initTomorrowSchedule();
    getUpdateForEveryday();
    Navigator.pushAndRemoveUntil(
      context,
      CustomRoute(
        const Index(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}

class Index extends StatelessWidget {
  final int type;

  const Index({Key? key, this.type = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Body(type: type),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}

class Body extends StatelessWidget {
  final int type;

  const Body({Key? key, this.type = 0}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: Global.pageControl,
        children: [HomePage(type: type), const SchedulePage(), const MinePage()]);
  }
}
