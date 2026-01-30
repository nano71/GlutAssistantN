import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistantn/common/log.dart';
import 'package:glutassistantn/pages/layout.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:workmanager/workmanager.dart';

import 'common/io.dart';
import 'common/service.dart';
import 'config.dart';
import 'data.dart';

void main() async {
  Future<void> run() async {
    WidgetsFlutterBinding.ensureInitialized();
    Workmanager().initialize(callbackDispatcher, isInDebugMode: true);
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent));
    print("startApp...");

    await readConfig();
    isDark = AppData.theme == "dark";
    AppData.isDarkTheme = AppData.theme == "dark";
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
  Color labelTextColor = readTextColor();
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
    setSystemNavigationBarColor(readBackgroundColor());

    eventBusListener = eventBus.on<UpdateAppThemeState>().listen((event) {
      print("更换主题");
      setSystemNavigationBarColor(readCardBackgroundColor());
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
        navigatorObservers: [routeObserver],
        theme: ThemeData(
          useMaterial3: false,
          navigationBarTheme: NavigationBarThemeData(
            labelTextStyle: WidgetStateProperty.resolveWith<TextStyle>(
              (states) {
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
