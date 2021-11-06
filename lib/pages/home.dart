import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:glutnnbox/widget/bars.dart';
import 'package:glutnnbox/widget/cards.dart';
import 'package:glutnnbox/widget/icons.dart';
import 'package:glutnnbox/widget/lists.dart';

import '../data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> with SingleTickerProviderStateMixin {
  late Animation<double> animation;
  late AnimationController controller;

  final ScrollController _scrollController = ScrollController();
  GlobalKey<IconWidgetState> iconKey = GlobalKey();
  bool _timeOutBool = true;
  double offset_ = 0.0;

  @override
  void initState() {
    super.initState();


    _scrollController.addListener(() {
      if (_timeOutBool) {
        int _offset = _scrollController.position.pixels.toInt();
        _offset < 0 ? iconKey.currentState!.onPressed((_offset / 25.0).abs()) : "";
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
    });
  }

  void _goTop() async {
    print("刷新${DateTime.now()}");
    Scaffold.of(context).removeCurrentSnackBar();
    Scaffold.of(context).showSnackBar(jwSnackBar(true, "刷新"));
    int _count = 0;
    const period = const Duration(milliseconds: 10);
    print(DateTime.now().toString());
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
// InkWell(
//   child: _codeImgSrc.length > 1
//       ? Image.memory(_codeImgSrc, height: 25)
//       : Container(
//           height: 25,
//         ),
//   onTap: () {
//     _getCode();
//   },
// ),
// TextField(
//   controller: _textFieldController,
// ),
// FlatButton(
//   child: const Text('提交'),
//   onPressed: () {
//     if (Global.logined) {
//       _getWeek();
//     } else {
//       _codeCheck();
//     }
//   },
// ),
                const HomeCard(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  mainAxisSize: MainAxisSize.max,
                  children: [
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 8, 4, 16),
                      height: 100,
                      width: width / 3 - 48 / 3,
                      decoration: HomeCardsState.cardDecoration,
                      child: Stack(
                        children: [
                          Align(
                            child: Container(
                              margin: HomeCardsState.iconMargin,
                              child: IconWidget(iconKey),
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
                    homeCard2(width),
                    homeCard3(width),
                  ],
                ),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(todayScheduleTitle, style: _tomorrowAndTodayTextStyle()),
                ),
              ],
            ),
          )),
          const ToDayCourse(),
          SliverToBoxAdapter(
              child: Container(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Align(
                alignment: Alignment.centerLeft,
                child: Text(tomorrowScheduleTitle, style: _tomorrowAndTodayTextStyle())),
          )),
          const TomorrowCourse(),
        ],
      ),
    );
  }
}
