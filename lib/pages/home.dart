import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:home_widget/home_widget.dart';

import '/common/get.dart';
import '/common/init.dart';
import '/pages/queryExams.dart';
import '/pages/queryScores.dart';
import '/widget/bars.dart';
import '/widget/cards.dart';
import '/widget/icons.dart';
import '/widget/lists.dart';
import '../common/homeWidget.dart';
import '../common/io.dart';
import '../common/style.dart';
import '../config.dart';
import '../data.dart';
import 'layout.dart';
import 'login.dart';

class HomePage extends StatefulWidget {
  final bool refresh;

  HomePage({Key? key, this.refresh = false}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with TickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;
  final ScrollController scrollController = ScrollController();
  GlobalKey<RefreshIconWidgetDynamicState> iconKey = GlobalKey();
  bool isTimeout = true;
  double basePullOffset = 0.0;
  late AnimationController animationControllerForLeftCard;
  late AnimationController animationControllerForCenterCard;
  late AnimationController animationControllerForRightCard;
  late Animation animationForLeftCard;
  late Animation animationForCenterCard;
  late Animation animationForRightCard;
  ColorTween homeCardsColorTween = ColorTween(begin: readColorBegin(), end: readColorEnd());
  int updateButtonClickCount = 0;
  bool clickCooldown = false;
  Timer updateIntervalTimer = Timer(Duration(), () {});
  Timer rotationAnimationTimer = Timer(Duration(), () {});
  late StreamSubscription<ReloadHomePageState> eventBusListener;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      DateTime now = DateTime.now();
      if (now.minute == 59 && now.hour == 23) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, "明天再来!", 3));
        Future.delayed(Duration(seconds: 3), () {
          exit(0);
        });
      } else if (widget.refresh) {
        refresh();
      }
    });

    animationControllerForLeftCard = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    animationControllerForCenterCard = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });
    animationControllerForRightCard = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 150),
    )..addListener(() {
        setState(() {});
      });

    animationForLeftCard = homeCardsColorTween.animate(animationControllerForLeftCard);
    animationForCenterCard = homeCardsColorTween.animate(animationControllerForCenterCard);
    animationForRightCard = homeCardsColorTween.animate(animationControllerForRightCard);

    scrollController.addListener(handlePullToRefresh);

    eventBusListener = eventBus.on<ReloadHomePageState>().listen((event) {
      setState(() {});
    });
  }

  void handlePullToRefresh() {
    if (isTimeout) {
      int currentScrollOffset = scrollController.position.pixels.toInt();
      if (currentScrollOffset < 0) {
        double pullDistance = (currentScrollOffset / 25.0).abs();
        iconKey.currentState!.onPressed(pullDistance + basePullOffset);
        if (pullDistance >= 5.0) {
          final double lastRecordedPullDistance = pullDistance;
          if (lastRecordedPullDistance == pullDistance || lastRecordedPullDistance + 0.25 < pullDistance) {
            Future.delayed(
              Duration(milliseconds: 200),
              () {
                if (isTimeout) {
                  basePullOffset = pullDistance;
                  refresh();
                }
                isTimeout = false;
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
    HomeWidget.initiallyLaunchedFromHomeWidget().then(launchedFromWidget);
    HomeWidget.widgetClicked.listen(launchedFromWidget);
  }

  void launchedFromWidget(Uri? uri) {
    print('_HomePageState.launchedFromWidget: ${uri?.host}');
    if (uri?.host == "refresh") refresh();
  }

  void refresh() {
    print('_HomePageState.refresh');
    updateIntervalTimer.cancel();
    rotationAnimationTimer.cancel();
    if (updateButtonClickCount < 8) {
      int maxRotationCount = 10000;
      updateButtonClickCount++;
      if (updateButtonClickCount == 7) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, "你太快了!"));
      } else if (updateButtonClickCount == 1) {
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "准备更新...", 10));
      }
      scrollController.animateTo(
        scrollController.position.minScrollExtent,
        duration: Duration(milliseconds: 300),
        curve: Curves.linear,
      );
      afterSuccess() async {
        print('_HomePageState.afterSuccess');
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "处理数据...", 10));
        await writeSchedule();
        await initTodaySchedule();
        await initTomorrowSchedule();
        eventBus.fire(ReloadSchedulePageState());
        eventBus.fire(ReloadTodayListState());
        eventBus.fire(ReloadTomorrowListState());
        setState(() {});
        maxRotationCount = 0;
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(1, "数据已更新!", 1));
        HomeWidgetUtils.updateWidgetContent();
        // throw Error();
        // throw UnimplementedError();
      }

      scheduleParser(dynamic result) async {
        if (result is bool) {
          if (result) {
            await afterSuccess();
          } else {
            if (!AppData.isLoggedIn) {
              // codeCheckDialog(context),
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, AppConfig.notLoggedInErrorMessage));
              rotationAnimationTimer.cancel();
            } else {
              ScaffoldMessenger.of(context).removeCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(CustomSnackBarWithAction(
                false,
                "需要验证",
                context,
                () async {
                  // Future<dynamic> getSchedule()
                  if (await getSchedule() == true) {
                    Navigator.pushAndRemoveUntil(context, AppRouter(Layout(refresh: true)), (route) => false);
                  }
                },
                duration: 10,
              ));
              rotationAnimationTimer.cancel();
            }
          }
        } else {
          ScaffoldMessenger.of(context).removeCurrentSnackBar();
          ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, result, 4));
          rotationAnimationTimer.cancel();
        }
      }

      updateIntervalTimer = Timer(Duration(seconds: 1), () async {
        print("更新开始");
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "连接教务...", 10));
        await getWeek();
        ScaffoldMessenger.of(context).removeCurrentSnackBar();
        ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(2, "获取课表...", 10));
        await scheduleParser(await getSchedule());
        isTimeout = true;
        updateButtonClickCount = 0;
      });
      int count = 0;
      Duration period = Duration(milliseconds: 10);
      rotationAnimationTimer = Timer.periodic(period, (timer) {
        count++;
        basePullOffset += 0.15;
        iconKey.currentState!.onPressed(basePullOffset);
        if (count >= maxRotationCount) {
          timer.cancel();
        }
      });
    } else {
      if (clickCooldown) {
        return;
      }
      clickCooldown = true;
      ScaffoldMessenger.of(context).removeCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(CustomSnackBar(0, "你慢一点!"));
      updateIntervalTimer.cancel();
      updateIntervalTimer = Timer(Duration(seconds: 5), () {
        Future.delayed(Duration(seconds: 5), () {
          isTimeout = true;
          clickCooldown = false;
          updateButtonClickCount = 0;
        });
      });
    }
  }

  @override
  void dispose() {
    animationControllerForRightCard.dispose();
    animationControllerForCenterCard.dispose();
    animationControllerForLeftCard.dispose();
    scrollController.dispose();
    eventBusListener.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AppData.homeContext = context;
    double width = MediaQuery.of(context).size.width;
    // print("HomePage create");
    return CustomScrollView(
      controller: scrollController,
      physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
      slivers: [
        HomePageTopNavigationBar(context),
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
                child: HomePageSemesterProgressCard(),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                mainAxisSize: MainAxisSize.max,
                children: [
                  GestureDetector(
                    onTapCancel: () {
                      animationControllerForLeftCard.reverse();
                    },
                    onTapUp: (d) {
                      Future.delayed(Duration(milliseconds: 100), () {
                        if (!AppData.isLoggedIn) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                        } else {
                          refresh();
                        }
                        animationControllerForLeftCard.reverse();
                      });
                    },
                    onTapDown: (d) {
                      animationControllerForLeftCard.forward();
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(0, 8, 4, 16),
                      height: 110,
                      width: width / 3 - 48 / 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)), color: animationForLeftCard.value),
                      child: Stack(
                        children: [
                          Align(
                            child: Container(
                              margin: HomePageCardsState.iconMargin,
                              child: RefreshIconWidgetDynamic(key: iconKey),
                            ),
                          ),
                          Align(
                            child: Container(
                              margin: HomePageCardsState.textMargin,
                              child: Text(
                                HomePageCardsState.iconTexts[0],
                                style: TextStyle(color: readHomePageSmallCardTextColor()),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapCancel: () {
                      animationControllerForCenterCard.reverse();
                    },
                    onTapUp: (d) {
                      Future.delayed(Duration(milliseconds: 100), () {
                        if (!AppData.isLoggedIn) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueryScoresPage()));
                        }
                        animationControllerForCenterCard.reverse();
                      });
                    },
                    onTapDown: (d) {
                      animationControllerForCenterCard.forward();
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(4, 8, 4, 16),
                      height: 110,
                      width: width / 3 - 48 / 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)), color: animationForCenterCard.value),
                      child: Stack(
                        children: [
                          Align(
                            child: Container(
                              margin: HomePageCardsState.iconMargin,
                              child: Icon(
                                HomePageCardsState.icons[1],
                                color: readColor(),
                                size: HomePageCardsState.iconSize,
                              ),
                            ),
                          ),
                          Align(
                            child: Container(
                              margin: HomePageCardsState.textMargin,
                              child: Text(HomePageCardsState.iconTexts[1],
                                  style: TextStyle(color: readHomePageSmallCardTextColor())),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTapCancel: () {
                      animationControllerForRightCard.reverse();
                    },
                    onTapUp: (d) {
                      Future.delayed(Duration(milliseconds: 100), () {
                        if (!AppData.isLoggedIn) {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => LoginPage()));
                        } else {
                          Navigator.of(context).push(MaterialPageRoute(builder: (context) => QueryExamsPage()));
                        }
                        animationControllerForRightCard.reverse();
                      });
                    },
                    onTapDown: (d) {
                      animationControllerForRightCard.forward();
                    },
                    child: Container(
                      margin: EdgeInsets.fromLTRB(4, 8, 0, 16),
                      height: 110,
                      width: width / 3 - 48 / 3,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12.0)), color: animationForRightCard.value),
                      child: Stack(
                        children: [
                          Align(
                            child: Container(
                              margin: HomePageCardsState.iconMargin,
                              child: Icon(
                                HomePageCardsState.icons[2],
                                color: readColor(),
                                size: HomePageCardsState.iconSize,
                              ),
                            ),
                          ),
                          Align(
                            child: Container(
                              margin: HomePageCardsState.textMargin,
                              child: Text(HomePageCardsState.iconTexts[2],
                                  style: TextStyle(color: readHomePageSmallCardTextColor())),
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
          child: Align(
              alignment: Alignment.centerLeft, child: Text(tomorrowScheduleTitle, style: tomorrowAndTodayTextStyle())),
        )),
        TomorrowCourseList(),
        !AppData.isLoggedIn ? _LoginTip() : SliverToBoxAdapter(child: Center()),
      ],
    );
  }
}

class _LoginTip extends StatelessWidget {
  _LoginTip({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Center(
        child: TextButton(
          onPressed: () {
            Navigator.of(context).push(
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
