import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Global {
  static String appTitle = "桂工助手";
  static int pageIndex = 0;
  static Map<String, String> cookie = {};
  static Uri getCodeUrl = Uri.http("jw.glutnn.cn", "/academic/getCaptcha.do");
  static Uri loginUrl = Uri.http("jw.glutnn.cn", "/academic/j_acegi_security_check");
  static Uri loginUrl2 = Uri.http("jw.glutnn.cn", "/academic/index_new.jsp");
  static Uri getWeekUrl = Uri.http("jw.glutnn.cn", "/academic/listLeft.do");
  static Uri getScoreUrl = Uri.http("jw.glutnn.cn", "/academic/manager/score/studentOwnScore.do");
  static int hideSnackBarSeconds = 2;
  static String jwErrorReSnackBarText = "请重试";
  static String jwErrorSnackBarText = "教务系统服务器瘫痪";
  static SnackBar jwErrorSnackBar = SnackBar(
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      children: <Widget>[
        const Icon(
          Icons.mood_bad,
          color: Colors.red,
        ),
        Text(jwErrorSnackBarText)
      ],
    ),
    behavior: SnackBarBehavior.floating,
  );
  static SnackBar jwSuccessSnackBar = SnackBar(
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      children: const <Widget>[
        Icon(
          Icons.mood,
          color: Colors.green,
        ),
        Text('登录成功')
      ],
    ),
    behavior: SnackBarBehavior.floating,
  );
  static SnackBar jwErrorReSnackBar = SnackBar(
    duration: Duration(seconds: hideSnackBarSeconds),
    content: Row(
      children: <Widget>[
        const Icon(
          Icons.mood_bad,
          color: Colors.red,
        ),
        Text(jwErrorReSnackBarText)
      ],
    ),
    behavior: SnackBarBehavior.floating,
  );
  static PageController pageControl = PageController(
    initialPage: 0,
    keepPage: true,
  );
}
