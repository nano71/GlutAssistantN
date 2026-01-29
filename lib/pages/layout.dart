import 'dart:async';

import 'package:flutter/material.dart';
import 'package:glutassistantn/common/log.dart';
import 'package:home_widget/home_widget.dart';
import 'package:package_info_plus/package_info_plus.dart' as PackageInfoPlus;
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '/common/get.dart';
import '/common/init.dart';
import '/common/io.dart';
import '/config.dart';
import '/pages/home.dart';
import '/pages/person.dart';
import '/pages/schedule.dart';
import '/widget/bars.dart';
import '../common/aes.dart';
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

Future<void> reinitialize({refreshState = false, ignoreReadConfig = false}) async {
  if (!ignoreReadConfig) await readConfig();
  await readWeek();
  await readSchedule();
  await initTodaySchedule();
  await initTomorrowSchedule();
  if (!refreshState) return;
  eventBus.fire(ReloadSchedulePageState());
  eventBus.fire(ReloadHomePageState());
  eventBus.fire(ReloadTodayListState());
  eventBus.fire(ReloadTomorrowListState());
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
    await reinitialize(ignoreReadConfig: true);
    await readCookie();
    getUpdateForEveryday();
    updateAppwidget();
    Timer(Duration(seconds: 1), () {
      setSystemNavigationBarColor(readCardBackgroundColor());
    });
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
    return Container(color: readBackgroundColor());
  }
}

class Layout extends StatefulWidget {
  final bool refresh;

  Layout({Key? key, this.refresh = false}) : super(key: key);

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> with RouteAware {
  late final AppLifecycleListener _listener;
  bool isResumed = true;
  late StreamSubscription<ErrorEvent> eventBusListener;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // 必须在这里订阅 RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void initState() {
    super.initState();
    _listener = AppLifecycleListener(
      onStateChange: didChangeAppLifecycleState,
    );
    eventBusListener = eventBus.on<ErrorEvent>().listen((event) {
      if (!mounted) return;
      Future.microtask(() {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, event.message, 4));
      });
    });

    Sentry.configureScope((scope) {
      final encrypted = AESHelper.encryptText(getAccount());
      scope.setTag("encrypted", encrypted);
    });
  }

  Future<void> didChangeAppLifecycleState(AppLifecycleState state) async {
    switch (state) {
      case AppLifecycleState.resumed:
        print("AppLifecycleState.resumed");
        isResumed = true;
        await reinitialize(refreshState: true);
        await updateAppwidget();
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
    eventBusListener.cancel();
    routeObserver.unsubscribe(this);

    super.dispose();
  }

  @override
  void didPush() {
    print('PageView 被 push');
  }

  @override
  void didPopNext() {
    print('PageView 覆盖的页面被 pop，自己重新显示');
    setSystemNavigationBarColor(readCardBackgroundColor());
  }

  @override
  void didPop() {
    print('PageView 被 pop');
  }

  @override
  void didPushNext() {
    print('PageView 上有新页面 push 进来');
    setSystemNavigationBarColor(readBackgroundColor());
  }

  @override
  Widget build(BuildContext context) {
    print("View build");
    return Scaffold(
      backgroundColor: readBackgroundColor(),
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
  await Workmanager().cancelAll();
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

final RouteObserver<ModalRoute<void>> routeObserver = RouteObserver<ModalRoute<void>>();
