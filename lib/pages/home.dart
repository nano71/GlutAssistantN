import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutnnbox/common/cookie.dart';
import 'package:glutnnbox/common/init.dart';
import 'package:glutnnbox/get/get.dart';
import 'package:glutnnbox/login/login.dart';
import 'package:glutnnbox/widget/bars.dart';
import 'package:glutnnbox/widget/cards.dart';
import 'package:glutnnbox/widget/icons.dart';
import 'package:glutnnbox/widget/lists.dart';
import 'package:http/http.dart';

import '../config.dart';
import '../data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  final ScrollController _scrollController = ScrollController();
  GlobalKey<RefreshIconWidgetDynamicState> iconKey = GlobalKey();
  bool _timeOutBool = true;
  double offset_ = 0.0;
  late AnimationController _animationControllerForHomeCards1;
  late AnimationController _animationControllerForHomeCards2;
  late AnimationController _animationControllerForHomeCards3;
  late Animation _animationForHomeCards1;
  late Animation _animationForHomeCards2;
  late Animation _animationForHomeCards3;
  ColorTween homeCardsColorTween = ColorTween(
      begin: const Color.fromARGB(42, 199, 229, 253),
      end: const Color.fromARGB(110, 199, 229, 253));

  @override
  void initState() {
    super.initState();
    _getCode();
    _animationControllerForHomeCards1 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    _animationControllerForHomeCards2 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    _animationControllerForHomeCards3 = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });

    _animationForHomeCards1 = homeCardsColorTween.animate(_animationControllerForHomeCards1);
    _animationForHomeCards2 = homeCardsColorTween.animate(_animationControllerForHomeCards2);
    _animationForHomeCards3 = homeCardsColorTween.animate(_animationControllerForHomeCards3);

    _scrollController.addListener(_scrollControllerListener);
  }

  void _scrollControllerListener() {
    if (_timeOutBool) {
      int _offset = _scrollController.position.pixels.toInt();
      _offset < 0 ? iconKey.currentState!.onPressed((_offset / 25.0).abs()) : "";
      if (_offset < 0) {
        if ((_offset / 25.0).abs() >= 6.0) {
          final double __offset = (_offset / 25.0).abs();
          if (__offset == (_offset / 25.0).abs() || __offset + 0.25 < (_offset / 25.0).abs()) {
            Future.delayed(const Duration(milliseconds: 200), () {
              if (_timeOutBool) {
                offset_ = (_offset / 25.0).abs();
                _goTop();
              }
              _timeOutBool = false;
            });
          }
        }
      }
    }
  }

  void _goTop() async {
    print("刷新${DateTime.now()}");
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(jwSnackBar(true, "刷新"));
    int _count = 0;
    const period = Duration(milliseconds: 10);
    initTodaySchedule();
    initTomorrowSchedule();
    todayCourseListKey.currentState!.reSate();
    tomorrowCourseListKey.currentState!.reSate();
    Timer.periodic(period, (timer) {
      // print(DateTime.now().toString());
      _count++;
      offset_ += 0.15;
      iconKey.currentState!.onPressed(offset_);
      if (_count >= 500) {
        timer.cancel();
      }
    });
    await _scrollController.animateTo(
      _scrollController.position.minScrollExtent,
      duration: const Duration(milliseconds: 300),
      curve: Curves.linear,
    );
    if (!_timeOutBool) {
      Future.delayed(const Duration(milliseconds: 5000), () {
        _timeOutBool = true;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  TextStyle _tomorrowAndTodayTextStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.none);
  }

  void _getCode() async {
    try {
      setState(() {
        _textFieldController.text = "";
      });
      print("getCode...");
      var response = await get(Global.getCodeUrl).timeout(const Duration(milliseconds: 6000));
      parseRawCookies(response.headers['set-cookie']);
      setState(() {
        _codeImgSrc = response.bodyBytes;
      });
    } catch (e) {
      Scaffold.of(context).removeCurrentSnackBar();
      Scaffold.of(context).showSnackBar(jwSnackBar(false, "网络错误"));
    }
  }

  void _codeCheck() async {
    void _next(String value) {
      if (value == "success") {
        _loginJW();
      } else {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "验证码错误"));
        setState(() {
          _textFieldController.text = "";
        });
      }
    }

    await codeCheck(_textFieldController.text.toString()).then((String value) => _next(value));
  }

  void _loginJW() async {
    void _next(String value) {
      if (value == "success") {
        Global.logined = true;
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(true, "登陆成功"));
        _getWeek();
      } else if (value == "fail") {
        Scaffold.of(context).removeCurrentSnackBar();
        Scaffold.of(context).showSnackBar(jwSnackBar(false, "请重试"));
        _getCode();
      } else {
        if (Global.logined) {
          Scaffold.of(context).removeCurrentSnackBar();
          Scaffold.of(context).showSnackBar(jwSnackBar(false, "登录成功,但程序发生了错误"));
          _getCode();
        }
      }
    }

    await login("5191963403", "sr20000923++", _textFieldController.text.toString())
        .then((String value) => _next(value));
  }

  void _getWeek() async {
    setState(() {
      _textFieldController.text = "";
      _week = int.parse(writeData["week"]);
    });
    // print("_getWeek...");
    getSchedule();
  }

  final TextEditingController _textFieldController = TextEditingController();

  Uint8List _codeImgSrc = const Base64Decoder().convert(
      "iVBORw0KGgoAAAANSUhEUgAAAEgAAAAeCAYAAACPOlitAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAAHYcAAB2HAY/l8WUAAABYSURBVGhD7dChAcAgEMDAb/ffGSpqIQvcmfg86zMcvX85MCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBgWDgkHBoGBQMCgYFAwKBl3NbAiZBDiX3e/AAAAAAElFTkSuQmCC");
  Map<String, String> headers = {"cookie": ""};
  int _week = int.parse(writeData["week"]);

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          homeTopBar,
          SliverToBoxAdapter(
              child: Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              textDirection: TextDirection.ltr,
              children: [
                InkWell(
                  child: _codeImgSrc.length > 1
                      ? Image.memory(_codeImgSrc, height: 25)
                      : Container(
                          height: 25,
                        ),
                  onTap: () {
                    _getCode();
                  },
                ),
                TextField(
                  controller: _textFieldController,
                ),
                InkWell(
                  child: const Text('提交'),
                  onTap: () {
                    if (Global.logined) {
                      _getWeek();
                    } else {
                      _codeCheck();
                    }
                  },
                ),
                const HomeCard(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GestureDetector(
                      onTapCancel: () {
                        _animationControllerForHomeCards1.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _goTop();
                          _animationControllerForHomeCards1.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards1.forward();
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(0, 8, 4, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                            color: _animationForHomeCards1.value),
                        child: Stack(
                          children: [
                            Align(
                              child: Container(
                                margin: HomeCardsState.iconMargin,
                                child: RefreshIconWidgetDynamic(iconKey),
                              ),
                            ),
                            Align(
                              child: Container(
                                margin: HomeCardsState.textMargin,
                                child: Text(
                                  HomeCardsState.iconTexts[0],
                                  style: HomeCardsState.textStyle,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTapCancel: () {
                        _animationControllerForHomeCards2.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _animationControllerForHomeCards2.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards2.forward();
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 8, 4, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                            color: _animationForHomeCards2.value),
                        child: homeCard2,
                      ),
                    ),
                    GestureDetector(
                      onTapCancel: () {
                        _animationControllerForHomeCards3.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(const Duration(milliseconds: 100), () {
                          _animationControllerForHomeCards3.reverse();
                        });
                      },
                      onTapDown: (d) {
                        print(9);
                        _animationControllerForHomeCards3.forward();
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 8, 0, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(6.0)),
                            color: _animationForHomeCards3.value),
                        child: homeCard3,
                      ),
                    ),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(todayScheduleTitle, style: _tomorrowAndTodayTextStyle()),
                ),
              ],
            ),
          )),
          TodayCourseList(
            key: todayCourseListKey,
          ),
          SliverToBoxAdapter(
              child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(tomorrowScheduleTitle, style: _tomorrowAndTodayTextStyle())),
          )),
          TomorrowCourseList(
            key: tomorrowCourseListKey,
          ),
        ],
      ),
    );
  }
}
