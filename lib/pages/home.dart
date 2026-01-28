import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '../common/homeWidget.dart';
import '/common/get.dart';
import '/common/init.dart';
import '/pages/queryExam.dart';
import '/pages/queryScore.dart';
import '/widget/bars.dart';
import '/widget/cards.dart';
import '/widget/icons.dart';
import '/widget/lists.dart';
import '../common/io.dart';
import '../common/style.dart';
import '../config.dart';
import '../data.dart';

import 'login.dart';
import 'layout.dart';

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
  late AnimationController _animationControllerForLeftCard;
  late AnimationController _animationControllerForCenterCard;
  late AnimationController _animationControllerForRightCard;
  late Animation _animationForLeftCard;
  late Animation _animationForCenterCard;
  late Animation _animationForRightCard;
  ColorTween homeCardsColorTween = ColorTween(begin: readColorBegin(), end: readColorEnd());
  int _updateButtonClickCount = 0;
  bool _clickCooldown = false;
  Timer _updateIntervalTimer = Timer(Duration(), () {});
  Timer _rotationAnimationTimer = Timer(Duration(), () {});
  bool _firstBuild = true;
  late StreamSubscription<ReloadHomePageState> eventBusListener;

  @override
  void initState() {
    super.initState();
    _animationControllerForLeftCard = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    _animationControllerForCenterCard = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    _animationControllerForRightCard = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });

    _animationForLeftCard = homeCardsColorTween.animate(_animationControllerForLeftCard);
    _animationForCenterCard = homeCardsColorTween.animate(_animationControllerForCenterCard);
    _animationForRightCard = homeCardsColorTween.animate(_animationControllerForRightCard);

    _scrollController.addListener(_scrollControllerListener);

    eventBusListener = eventBus.on<ReloadHomePageState>().listen((event) {
      setState(() {});
    });
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
                  _refresh();
                }
                _timeOutBool = false;
              },
            );
          }
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    HomeWidget.initiallyLaunchedFromHomeWidget().then(_launchedFromWidget);
    HomeWidget.widgetClicked.listen(_launchedFromWidget);
  }

  void _launchedFromWidget(Uri? uri) {
    print('HomePageState._launchedFromWidget');
    print(uri?.host);
    if (uri?.host == "refresh") _refresh();
  }

  void _refresh() {
    print('HomePageState._refresh');
    _updateIntervalTimer.cancel();
    _rotationAnimationTimer.cancel();
    if (_updateButtonClickCount < 8) {
      int _endCount = 10000;
      print("刷新${DateTime.now()}");
      _updateButtonClickCount++;
      if (_updateButtonClickCount == 7) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "你太快了!"));
      } else if (_updateButtonClickCount == 1) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "准备更新...", 10));
      }
      _scrollController.animateTo(
        _scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
      );
      afterSuccess() async {
        print('HomePageState.afterSuccess');
        await readSchedule();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "清除缓存...", 10));
        Map _schedule = Map.from(AppData.schedule);
        AppData.schedule = {};
        AppData.todaySchedule = [];
        AppData.tomorrowSchedule = [];
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "处理数据...", 10));
        await initSchedule();
        AppData.schedule = _schedule;
        await writeSchedule(jsonEncode(_schedule));
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
        HomeWidgetUtils.updateWidgetContent();
        // throw Error();
        // throw UnimplementedError();
      }

      _scheduleParser(dynamic result) async {
        if (result is bool) {
          if (result) {
            await afterSuccess();
          } else {
            if (!isLoggedIn()) {
              // codeCheckDialog(context),
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, AppConfig.notLoginError));
              _rotationAnimationTimer.cancel();
            } else {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(jwSnackBarAction(
                false,
                "需要验证",
                context,
                () async {
                  // Future<dynamic> getSchedule()
                  if (await getSchedule() == true) {
                    Navigator.pushAndRemoveUntil(context, AppRouter(Layout(refresh: true)), (route) => false);
                  }
                },
                hideSnackBarSeconds: 10,
              ));
              _rotationAnimationTimer.cancel();
            }
          }
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, result, 4));
          _rotationAnimationTimer.cancel();
        }
      }

      _updateIntervalTimer = Timer(Duration(seconds: 1), () async {
        print("更新开始");
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "连接教务...", 10));
        await getWeek();
        await readWeek();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(2, "获取课表...", 10));
        await _scheduleParser(await getSchedule());
        _timeOutBool = true;
        _updateButtonClickCount = 0;
      });
      int _count = 0;
      Duration period = Duration(milliseconds: 10);
      _rotationAnimationTimer = Timer.periodic(period, (timer) {
        _count++;
        offset_ += 0.15;
        iconKey.currentState!.onPressed(offset_);
        if (_count >= _endCount) {
          timer.cancel();
        }
      });
    } else {
      if (_clickCooldown) {
        return;
      }
      _clickCooldown = true;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "你慢一点!"));
      _updateIntervalTimer.cancel();
      _updateIntervalTimer = Timer(Duration(seconds: 5), () {
        Future.delayed(Duration(seconds: 5), () {
          _timeOutBool = true;
          _clickCooldown = false;
          _updateButtonClickCount = 0;
        });
      });
    }
  }

  @override
  void dispose() {
    _animationControllerForRightCard.dispose();
    _animationControllerForCenterCard.dispose();
    _animationControllerForLeftCard.dispose();
    _scrollController.dispose();
    eventBusListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppData.homeContext = context;
    Future.delayed(Duration(seconds: 0), () {
      if (DateTime.now().minute == 59 && DateTime.now().hour == 23) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(jwSnackBar(0, "明天再来!", 3));
        Future.delayed(Duration(seconds: 3), () {
          exit(0);
        });
      }
    });
    if (widget.refresh && _firstBuild) {
      Future.delayed(Duration(seconds: 0), () {
        _refresh();
        _firstBuild = false;
      });
    }
    double width = MediaQuery.of(context).size.width;
    // print("HomePage create");
    return Container(
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
                        _animationControllerForLeftCard.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (AppData.persistentData["username"] == "") {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                          } else {
                            _refresh();
                          }
                          _animationControllerForLeftCard.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForLeftCard.forward();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(0, 8, 4, 16),
                        height: 110,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12.0)), color: _animationForLeftCard.value),
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
                        _animationControllerForCenterCard.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (AppData.persistentData["username"] == "") {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueryPage()));
                          }
                          _animationControllerForCenterCard.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForCenterCard.forward();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(4, 8, 4, 16),
                        height: 110,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12.0)), color: _animationForCenterCard.value),
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
                        _animationControllerForRightCard.reverse();
                      },
                      onTapUp: (d) {
                        Future.delayed(Duration(milliseconds: 100), () {
                          if (AppData.persistentData["username"] == "") {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                          } else {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueryExamPage()));
                          }
                          _animationControllerForRightCard.reverse();
                        });
                      },
                      onTapDown: (d) {
                        _animationControllerForRightCard.forward();
                      },
                      child: Container(
                        margin: EdgeInsets.fromLTRB(4, 8, 0, 16),
                        height: 110,
                        width: width / 3 - 48 / 3,
                        decoration: BoxDecoration(borderRadius: BorderRadius.all(Radius.circular(12.0)), color: _animationForRightCard.value),
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
                // ExamsTipsBar(),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(todayScheduleTitle, style: tomorrowAndTodayTextStyle()),
                ),
              ],
            ),
          )),
          TodayCourseList(),
          SliverToBoxAdapter(
              child: Container(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Align(alignment: Alignment.centerLeft, child: Text(tomorrowScheduleTitle, style: tomorrowAndTodayTextStyle())),
          )),
          TomorrowCourseList(),
          !isLoggedIn() ? NeedLogin() : SliverToBoxAdapter(child: Center()),
        ],
      ),
    );
  }
}

class NeedLogin extends StatelessWidget {
  NeedLogin({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
