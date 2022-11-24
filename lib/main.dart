import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutassistantn/pages/init.dart';

import 'config.dart';

main() {
  SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(statusBarColor: Colors.transparent, systemNavigationBarColor: Colors.white));

  print("startApp...");
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(debugShowCheckedModeBanner: false, theme: ThemeData(), title: Global.appTitle, home: const Init());
  }
}
