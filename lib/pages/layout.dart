import 'package:flutter/material.dart';
import 'package:glutassistantn/common/log.dart';
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
import '../common/homeWidget.dart';
import '../data.dart';
import '../type/packageInfo.dart';

class AppRouter extends PageRouteBuilder {
  final Widget widget;

  AppRouter(this.widget, [int milliseconds = 300])
      : super(
            transitionDuration: Duration(milliseconds: milliseconds),
            pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
              return widget;
            },
            transitionsBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
              return FadeTransition(opacity: Tween(begin: 0.0, end: 1.0).animate(CurvedAnimation(parent: animation, curve: Curves.ease)), child: child);
            });
}

class DataPreloadPage extends StatefulWidget {
  DataPreloadPage({Key? key}) : super(key: key);

  @override
  _DataPreloadPageState createState() => _DataPreloadPageState();
}

class _DataPreloadPageState extends State<DataPreloadPage> {
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
    getWeek(isPreloading: true);
    getUpdateForEveryday();
    AppData.isInitialized = true;
    updateAppwidget();
    Navigator.pushAndRemoveUntil(
      context,
      AppRouter(Layout(), 2000),
      (route) => false,
    );
  }

  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Container(color: Colors.white);
  }
}

class Layout extends StatefulWidget {
  final bool refresh;

  Layout({Key? key, this.refresh = false}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  late final AppLifecycleListener _listener;
  bool isResumed = true;

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: didChangeAppLifecycleState,
    );
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        print("AppLifecycleState.resumed");
        isResumed = true;
        updateAppwidget();
        break;
      case AppLifecycleState.detached:
        print("AppLifecycleState.detached");
        // TODO: Handle this case.
        break;
      case AppLifecycleState.inactive:
        if (!isResumed || sharing) return;
        isResumed = false;
        print("AppLifecycleState.inactive");
        writeLog();
        // TODO: Handle this case.
        break;
      case AppLifecycleState.paused:
        // TODO: Handle this case.
        print("AppLifecycleState.paused");
        break;
      case AppLifecycleState.hidden:
        // TODO: Handle this case.
        break;
    }
  }

  @override
  void dispose() {
    // 注销监听器
    _listener.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("View build");
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        physics: NeverScrollableScrollPhysics(),
        controller: AppConfig.pageControl,
        children: [HomePage(refresh: widget.refresh), SchedulePage(), MinePage()],
      ),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

Future<void> updateAppwidget() async {
  print('updateAppwidget');
  await Workmanager().cancelByUniqueName("com.nano71.glutassistantn.updateHomeWidget");
  bool isAdded = await HomeWidgetUtils.isWidgetAdded();

  if (isAdded) {
    print("桌面微件已经添加");
    Workmanager().registerPeriodicTask("com.nano71.glutassistantn.updateHomeWidget", "updateHomeWidget", initialDelay: Duration(seconds: 0));
    HomeWidget.registerInteractivityCallback(backgroundCallback);
  } else {
    print("桌面微件尚未添加");
  }
}
