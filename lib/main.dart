import 'dart:async';
import 'dart:collection';

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
    // SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
    //   statusBarColor: Colors.transparent,
    //   systemNavigationBarColor: Colors.white,
    //   systemNavigationBarIconBrightness: Brightness.dark, // 导航栏按钮为黑色
    // ));
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
        options.beforeSend = (SentryEvent event, Hint? hint) {
          final isRealError = event.throwable != null || (event.exceptions?.isNotEmpty ?? false);
          if (isRealError) {
            final errorMessage = event.throwable.toString();
            print("意外错误:");
            print(errorMessage);
            eventBus.fire(ErrorEvent("意外错误"));
          }
          return event;
        };
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
  late StreamSubscription<UpdateAppThemeState> eventBusListener;
  Color labelTextColor = Colors.black;
  Color selectedLabelTextColor = readColor();
  void restartApp() {
    setState(() {
      appKey = UniqueKey(); // 重新生成 Key，触发整个应用重建
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    eventBusListener = eventBus.on<UpdateAppThemeState>().listen((event) {
      print("更换主题");
      setState(() {
        labelTextColor = readTextColor();
        selectedLabelTextColor = readColor();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        key: appKey,
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: false,
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>((states) {
                if (states.contains(WidgetState.selected)) {
                  return TextStyle(color: selectedLabelTextColor);
                }
                return TextStyle(color: labelTextColor);
              },
            ),
          ),
        ),
        title: AppConfig.appTitle,
        home: DataPreloadPage());
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    eventBusListener.cancel();
  }
}
