import 'package:flutter/material.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/init.dart';
import 'package:glutassistantn/common/io.dart';
import 'package:glutassistantn/config.dart';
import 'package:glutassistantn/pages/home.dart';
import 'package:glutassistantn/pages/mine.dart';
import 'package:glutassistantn/pages/schedule.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:package_info/package_info.dart';

import '../data.dart';

class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  CustomRoute(this.widget, [int milliseconds = 300])
      : super(
            //父类的方法
            //设置动画持续的时间，建议再1和2之间
            transitionDuration: Duration(milliseconds: milliseconds),
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
            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
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

class Init extends StatefulWidget {
  const Init({Key? key}) : super(key: key);

  @override
  InitState createState() => InitState();
}

class InitState extends State<Init> {
  @override
  void initState() {
    super.initState();
    init();
  }

  void init() async {
    PackageInfo.fromPlatform().then((PackageInfo info) {
      packageInfo["appName"] = info.appName;
      packageInfo["packageName"] = info.packageName;
      packageInfo["version"] = info.version;
      // packageInfo["version"] = "1.3.220801";
    });

    await readConfig();
    await readCookie();
    await readSchedule();
    await initTodaySchedule();
    await initTomorrowSchedule();
    getWeek();
    getUpdateForEveryday();
    Navigator.pushAndRemoveUntil(
      context,
      CustomRoute(const View(), 2000),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}

class View extends StatelessWidget {
  final bool refresh;

  const View({Key? key, this.refresh = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: Global.pageControl,
        children: [HomePage(refresh: refresh), const SchedulePage(), const MinePage()],
      ),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}
