import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_remix/flutter_remix.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/init.dart';
import 'package:glutassistantn/pages/queryexam.dart';
import 'package:glutassistantn/pages/queryscore.dart';
import 'package:glutassistantn/pages/update.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/cards.dart';
import 'package:glutassistantn/widget/dialog.dart';
import 'package:glutassistantn/widget/icons.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../common/io.dart';
import '../common/style.dart';
import '../config.dart';
import '../data.dart';
import 'init.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final bool refresh;

  HomePage({Key? key, this.refresh = false}) : super(key: key);

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
  ColorTween homeCardsColorTween = ColorTween(begin: readColorBegin(), end: readColorEnd());
  int _goTopInitCount = 0;
  bool _bk = true;
  Timer _time = Timer(Duration(), () {});
  Timer _time2 = Timer(Duration(), () {});
  bool firstBuild = true;

  @override
  void initState() {
    super.initState();
    _animationControllerForHomeCards1 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    _animationControllerForHomeCards2 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    _animationControllerForHomeCards3 = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
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
      if (_offset < 0) {
        double _offsetAbs = (_offset / 25.0).abs();
        iconKey.currentState!.onPressed(_offsetAbs + offset_);
        if (_offsetAbs >= 5.0) {
          final double __offset = _offsetAbs;
          if (__offset == _offsetAbs || __offset + 0.25 < _offsetAbs) {
            Future.delayed(
              Duration(milliseconds: 200),
              () {
                if (_timeOutBool) {
                  offset_ = _offsetAbs;
                  _goTop();
                }
                _timeOutBool = false;
              },
            );
          }
        }
      }
    }
  }

  void _goTop() {
    print('_goTop');
    _time.cancel();
    _time2.cancel();
    if (_goTopInitCount < 8) {
      int _endCount = 10000;
      print("刷新${DateTime.now()}");
      _goTopInitCount++;
      if (_goTopInitCount == 7) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "你太快了!"));
      } else if (_goTopInitCount == 1) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "准备更新...", 10));
      }
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
      );
      _next() async {
        await readSchedule();
        Map _schedule = schedule;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "清除缓存...", 10));
        schedule = {};
        todaySchedule = [];
        tomorrowSchedule = [];
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "初始化...", 10));
        await initSchedule();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取课表...", 10));
        schedule = _schedule;
        await writeSchedule(jsonEncode(_schedule));
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "处理数据...", 10));
        await initTodaySchedule();
        await initTomorrowSchedule();
        eventBus.fire(ReloadSchedulePageState());
        eventBus.fire(ReloadTodayListState());
        eventBus.fire(ReloadTomorrowListState());
        setState(() {});
        _endCount = 0;
        print("刷新结束${DateTime.now()}");
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "数据已更新!", 1));
      }

      _scheduleParser(String response) {
        if (response == "fail") {
          if (writeData["username"] == "") {
            // codeCheckDialog(context),
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "请先登录!"));
            _time2.cancel();
          } else {
            ScaffoldMessenger.of(context).removeCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
              false,
              "需要验证",
              context,
              () async => await getSchedule().then((value) => {
                    if (value == "success") {Navigator.pushAndRemoveUntil(context, CustomRoute(View(refresh: true)), (route) => false)}
                  }),
              hideSnackBarSeconds: 10,
            ));
            _time2.cancel();
          }
        } else if (response == "success")
          _next();
        else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, response, 4));
          _time2.cancel();
        }
      }

      _time = Timer(Duration(seconds: 1), () async {
        print("更新开始");
        getWeek();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "连接教务...", 10));
        await getSchedule().then((response) => _scheduleParser(response));
        _timeOutBool = true;
        _goTopInitCount = 0;
      });
      int _count = 0;
      Duration period = Duration(milliseconds: 10);
      _time2 = Timer.periodic(period, (timer) {
        _count++;
        offset_ += 0.15;
        iconKey.currentState!.onPressed(offset_);
        if (_count >= _endCount) {
          timer.cancel();
        }
      });
    } else {
      if (_bk) {
        _bk = false;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "你慢一点!"));
        _time.cancel();
        _time = Timer(Duration(seconds: 5), () {
          Future.delayed(Duration(seconds: 5), () {
            _timeOutBool = true;
            _bk = true;
            _goTopInitCount = 0;
          });
        });
      }
    }
  }

  @override
  void dispose() {
    _animationControllerForHomeCards3.dispose();
    _animationControllerForHomeCards2.dispose();
    _animationControllerForHomeCards1.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  TextStyle _tomorrowAndTodayTextStyle() {
    return TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.none);
  }

  @override
  Widget build(BuildContext context) {
    homeContext = context;
    Future.delayed(Duration(seconds: 0), () {
      if (DateTime.now().minute == 59 && DateTime.now().hour == 23) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "明天再来!", 3));
        Future.delayed(Duration(seconds: 3), () {
          exit(0);
        });
      }
    });
    if (widget.refresh && firstBuild) {
      Future.delayed(Duration(seconds: 0), () {
        _goTop();
        firstBuild = false;
      });
    }
    double width = MediaQuery.of(context).size.width;
    // print("HomePage create");
    return Container(
      color: Colors.white,
      margin: EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: CustomScrollView(
        controller: _scrollController,
        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          homeTopBar(context),
          SliverToBoxAdapter(
              child: Container(
            width: double.infinity,
            padding: EdgeInsets.fromLTRB(16, 0, 16, 0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              verticalDirection: VerticalDirection.down,
              textDirection: TextDirection.ltr,
              children: [
                InkWell(
                  onTap: () {
                    eventBus.fire(SetPageIndex(index: 1));
                    eventBus.fire(ReloadSchedulePageState());
                  },
                  child: HomeCard(),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    GestureDetector(
                      onTapCancel: () {
                        _animationControllerForHomeCards1.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (writeData["username"] == "") {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                          } else {
                            _goTop();
                          }
                          _animationControllerForHomeCards1.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards1.forward();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 8, 4, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12.0)), color: _animationForHomeCards1.value),
                        child: Stack(
                          children: [
                            Align(
                              child: Container(
                                margin: HomeCardsState.iconMargin,
                                child: RefreshIconWidgetDynamic(key: iconKey),
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
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (writeData["username"] == "") {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueryPage()));
                          }
                          _animationControllerForHomeCards2.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards2.forward();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(4, 8, 4, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12.0)), color: _animationForHomeCards2.value),
                        child: Stack(
                          children: [
                            Align(
                              child: Container(
                                margin: HomeCardsState.iconMargin,
                                child: Icon(
                                  HomeCardsState.icons[1],
                                  color: readColor(),
                                  size: HomeCardsState.iconSize,
                                ),
                              ),
                            ),
                            Align(
                              child: Container(
                                margin: HomeCardsState.textMargin,
                                child: Text(HomeCardsState.iconTexts[1], style: HomeCardsState.textStyle),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTapCancel: () {
                        _animationControllerForHomeCards3.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (writeData["username"] == "") {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueryExamPage()));
                          }
                          _animationControllerForHomeCards3.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards3.forward();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(4, 8, 0, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12.0)), color: _animationForHomeCards3.value),
                        child: Stack(
                          children: [
                            Align(
                              child: Container(
                                margin: HomeCardsState.iconMargin,
                                child: Icon(
                                  HomeCardsState.icons[2],
                                  color: readColor(),
                                  size: HomeCardsState.iconSize,
                                ),
                              ),
                            ),
                            Align(
                              child: Container(
                                margin: HomeCardsState.textMargin,
                                child: Text(HomeCardsState.iconTexts[2], style: HomeCardsState.textStyle),
                              ),
                            ),
                          ],
                        ),
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
          TodayCourseList(),
          SliverToBoxAdapter(
              child: Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Align(alignment: Alignment.centerLeft, child: Text(tomorrowScheduleTitle, style: _tomorrowAndTodayTextStyle())),
          )),
          TomorrowCourseList(),
          LoginCheck(),
        ],
      ),
    );
  }
}

class LoginCheck extends StatelessWidget {
  LoginCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (writeData["username"] != "") {
      return SliverToBoxAdapter(child: Center());
    }
    return SliverToBoxAdapter(
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(
              // 在FormPage()里传入参数
              MaterialPageRoute(
                builder: (context) => LoginPage(),
              ),
            );
          },
          child: Text(
            "请先登录",
            style: TextStyle(color: readColor()),
          ),
        ),
      ),
    );
  }
}
