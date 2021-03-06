import 'dart:async';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/common/init.dart';
import 'package:glutassistantn/pages/query.dart';
import 'package:glutassistantn/pages/queryexam.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/cards.dart';
import 'package:glutassistantn/widget/icons.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../config.dart';
import '../data.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final int type;

  const HomePage({Key? key, this.type = 0}) : super(key: key);

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
  Timer? _time;
  Timer? _time2;
  bool _type = true;

  @override
  void initState() {
    super.initState();

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
      if (_offset < 0) {
        iconKey.currentState!.onPressed((_offset / 25.0).abs() + offset_);
        if ((_offset / 25.0).abs() >= 6.0) {
          final double __offset = (_offset / 25.0).abs();
          if (__offset == (_offset / 25.0).abs() || __offset + 0.25 < (_offset / 25.0).abs()) {
            Future.delayed(
              const Duration(milliseconds: 200),
              () {
                if (_timeOutBool) {
                  offset_ = (_offset / 25.0).abs();
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
    _time?.cancel();
    _time2?.cancel();
    if (_goTopInitCount < 8) {
      int _endCount = 10000;
      // print("??????${DateTime.now()}");
      _goTopInitCount++;
      if (_goTopInitCount == 7) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "????????????!"));
      } else if (_goTopInitCount == 1) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "????????????...", 10));
      }
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.linear,
      );
      _next() async {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "????????????...", 10));
        schedule = {};
        todaySchedule = [];
        tomorrowSchedule = [];
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "?????????...", 10));
        await initSchedule();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "????????????...", 10));
        await getSchedule();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "????????????...", 10));
        await initTodaySchedule();
        await initTomorrowSchedule();
        pageBus.fire(ReState(1));
        pageBus.fire(ReTodayListState(1));
        pageBus.fire(ReTomorrowListState(1));
        setState(() {});
        _endCount = 0;
        // print("????????????${DateTime.now()}");
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(1, "???????????????!", 1));
      }

      _time = Timer(const Duration(seconds: 1), () async {
        // print("????????????");
        getWeek();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "????????????...", 10));
        await getSchedule().then((value) => {
              if (value == "fail")
                {
                  if (writeData["username"] == "")
                    {
                      // codeCheckDialog(context),
                      ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "????????????!")),
                      _time2?.cancel()
                    }
                  else
                    {
                      ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                      ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
                        false,
                        "????????????",
                        context,
                        10,
                      )),
                      _time2?.cancel()
                    }
                }
              else if (value == "success")
                _next()
              else
                {
                  ScaffoldMessenger.of(context).removeCurrentSnackBar(),
                  ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, value, 4)),
                  _time2?.cancel()
                }
            });
        _timeOutBool = true;
        _goTopInitCount = 0;
      });
      int _count = 0;
      const period = Duration(milliseconds: 10);
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
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "????????????!"));
        _time?.cancel();
        _time = Timer(const Duration(seconds: 5), () {
          Future.delayed(const Duration(seconds: 5), () {
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
    return const TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.none);
  }

  @override
  Widget build(BuildContext context) {
    Future.delayed(const Duration(seconds: 0), () {
      if (DateTime.now().minute == 59 && DateTime.now().hour == 23) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "????????????!", 3));
        Future.delayed(const Duration(seconds: 3), () {
          exit(0);
        });
      }
    });
    if (widget.type == 1 && _type) {
      Future.delayed(const Duration(seconds: 0), () {
        _goTop();
        _type = false;
      });
    }
    double width = MediaQuery.of(context).size.width;
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
      child: CustomScrollView(
        controller: _scrollController,
        physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
        slivers: [
          const HomeTopBar(),
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
                  onTap: () {
                    pageBus.fire(SetPageIndex(1));
                    pageBus.fire(ReState(1));
                  },
                  child: const HomeCard(),
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
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (writeData["username"] == "") {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) => const LoginPage()));
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
                        margin: const EdgeInsets.fromLTRB(0, 8, 4, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            color: _animationForHomeCards1.value),
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
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (writeData["username"] == "") {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) => const LoginPage()));
                          } else {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) => const QueryPage()));
                          }
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
                            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            color: _animationForHomeCards2.value),
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
                                child: Text(HomeCardsState.iconTexts[1],
                                    style: HomeCardsState.textStyle),
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
                        Future.delayed(const Duration(milliseconds: 100), () {
                          if (writeData["username"] == "") {
                            Navigator.of(context)
                                .push(MaterialPageRoute(builder: (context) => const LoginPage()));
                          } else {
                            Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) => const QueryExamPage()));
                          }
                          _animationControllerForHomeCards3.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForHomeCards3.forward();
                      },
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(4, 8, 0, 16),
                        height: 100,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(12.0)),
                            color: _animationForHomeCards3.value),
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
                                child: Text(HomeCardsState.iconTexts[2],
                                    style: HomeCardsState.textStyle),
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
          const LoginCheck(),
        ],
      ),
    );
  }
}

class LoginCheck extends StatelessWidget {
  const LoginCheck({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (writeData["username"] != "") {
      return const SliverToBoxAdapter(child: Center());
    }
    return SliverToBoxAdapter(
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(
              // ???FormPage()???????????????
              MaterialPageRoute(
                builder: (context) => const LoginPage(),
              ),
            );
          },
          child: Text(
            "????????????",
            style: TextStyle(color: readColor()),
          ),
        ),
      ),
    );
  }
}
