import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistantn/common/log.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '/pages/Layout.dart';
import 'common/service.dart';
import 'config.dart';
import 'data.dart';

void main() async {
  void run() {
    WidgetsFlutterBinding.ensureInitialized();
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.white));
    print("startApp...");
    runApp(App());
  }

  if (AppData.isReleaseMode)
    runZoned(() {
      SentryFlutter.init((options) {
        options.tracesSampleRate = 1.0;
        options.profilesSampleRate = 1.0;
        options.experimental.replay.sessionSampleRate = 1.0;
        options.experimental.replay.onErrorSampleRate = 1.0;
      }, appRunner: run);
    }, zoneSpecification: new ZoneSpecification(print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
      parent.print(zone, line);
      record(line);
    }));
  else {
    run();
  }
}

class App extends StatefulWidget {
  App({Key? key}) : super(key: key);

  static void refreshApp(BuildContext context) {
    context.findAncestorStateOfType<_AppState>()?.restartApp();
  }

  @override
  State<App> createState() => _AppState();
}

class _AppState extends State<App> {
  Key appKey = UniqueKey();

  void restartApp() {
    setState(() {
      appKey = UniqueKey(); // 重新生成 Key，触发整个应用重建
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        key: appKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
        ),
        title: AppConfig.appTitle,
        home: DataPreloadPage());
  }
}
