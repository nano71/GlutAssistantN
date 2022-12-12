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

  CustomRoute(this.widget, [int milliseconds = 300])
      : super(
            transitionDuration: Duration(milliseconds: milliseconds),
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
              return widget;
            },
            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
              return FadeTransition(opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.ease)), child: child);
            });
}

class Init extends StatefulWidget {
  Init({Key? key}) : super(key: key);

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
    getPermissions();
    await readConfig();
    await readCookie();
    await readSchedule();
    await initTodaySchedule();
    await initTomorrowSchedule();
    getWeek();
    getUpdateForEveryday();
    Navigator.pushAndRemoveUntil(
      context,
      CustomRoute(View(), 2000),
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

  View({Key? key, this.refresh = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("View build");
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: Global.pageControl,
        children: [HomePage(refresh: refresh), SchedulePage(), MinePage()],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
