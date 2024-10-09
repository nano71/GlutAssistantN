import 'package:flutter/material.dart';
import 'package:glutassistantn/widget/appwidget.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart' as PackageInfoPlus;
import 'package:workmanager/workmanager.dart';

import '/common/get.dart';
import '/common/init.dart';
import '/common/io.dart';
import '/config.dart';
import '/pages/home.dart';
import '/pages/person.dart';
import '/pages/schedule.dart';
import '/widget/bars.dart';
import '../data.dart';
import '../type/packageInfo.dart';

class CustomRouter extends PageRouteBuilder {
  final Widget widget;

  CustomRouter(this.widget, [int milliseconds = 300])
      : super(
            transitionDuration: Duration(milliseconds: milliseconds),
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
              return widget;
            },
            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
              return FadeTransition(opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.ease)), child: child);
            });
}

class MainBody extends StatefulWidget {
  MainBody({Key? key}) : super(key: key);

  @override
  MainBodyState createState() => MainBodyState();
}

class MainBodyState extends State<MainBody> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initialize();
  }

  Future<void> readPackageInfo() async {
    PackageInfoPlus.PackageInfo packageInfo = await PackageInfoPlus.PackageInfo.fromPlatform();
    PackageInfo.appName = packageInfo.appName;
    PackageInfo.packageName = packageInfo.packageName;
    PackageInfo.version = packageInfo.version;
  }

  void initialize() async {
    // initService();
    getPermissions();
    readPackageInfo();
    await readConfig();
    await readCookie();
    await readSchedule();
    await initTodaySchedule();
    await initTomorrowSchedule();
    getWeek();
    getUpdateForEveryday();
    AppData.isInitialized = true;
    Workmanager().cancelAll();

    Navigator.pushAndRemoveUntil(
      context,
      CustomRouter(CustomView(), 2000),
      (route) => false,
    );

    bool isAdded = await Appwidget.isWidgetAdded();

    if (isAdded) {
      print("桌面微件已经添加");
      Appwidget.updateWidgetContent();
      Workmanager().registerPeriodicTask("task-identifier", "simpleTask");
      HomeWidget.registerInteractivityCallback(backgroundCallback);
    } else {
      print("桌面微件尚未添加");
    }
  }

  @override
  void dispose() {
    // 注销监听器
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

// 监听生命周期变化
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      // 应用切换回前台
      print("应用切换回前台");
    } else if (state == AppLifecycleState.paused) {
      // 应用切换到后台
      print("应用切换到后台");
    } else if (state == AppLifecycleState.inactive) {
      // 应用处于非活跃状态
      print("应用处于非活跃状态");
    } else if (state == AppLifecycleState.detached) {
      // 应用已完全关闭
      print("应用已完全关闭");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}

class CustomView extends StatelessWidget {
  final bool refresh;

  CustomView({Key? key, this.refresh = false}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print("View build");
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: AppConfig.pageControl,
        children: [HomePage(refresh: refresh), SchedulePage(), MinePage()],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}
