import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistantn/common/log.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

import '/pages/Layout.dart';
import 'common/service.dart';
import 'config.dart';

void main() async {
  runZoned(() {
    SentryFlutter.init((options) {
      options.tracesSampleRate = 1.0;
      options.profilesSampleRate = 1.0;
      options.experimental.replay.sessionSampleRate = 1.0;
      options.experimental.replay.onErrorSampleRate = 1.0;
    }, appRunner: () {
      WidgetsFlutterBinding.ensureInitialized();
      Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
      SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.white));
      print("startApp...");
      runApp(App());
    });
  }, zoneSpecification: new ZoneSpecification(print: (Zone self, ZoneDelegate parent, Zone zone, String line) {
    parent.print(zone, line);
    record(line);
  }));
}

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
        ),
        title: AppConfig.appTitle,
        home: DataPreloadPage());
  }
}
