import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:glutnnbox/get/get.dart';

import 'config.dart';
import 'widget/materialapphome.dart';

main() async {
  SystemUiOverlayStyle systemUiOverlayStyle =
      const SystemUiOverlayStyle(statusBarColor: Colors.white);
  SystemChrome.setSystemUIOverlayStyle(systemUiOverlayStyle);
  print("--start--");
  await getWeek();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(fontFamily: 'SourceHanSansCN'),
        title: Global.appTitle,
        home: const MaterialAppHome());
  }
}
