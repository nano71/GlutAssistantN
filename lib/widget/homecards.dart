import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../data.dart';

class HomeCard extends StatefulWidget {
  const HomeCard({Key? key}) : super(key: key);

  @override
  HomeCardState createState() => HomeCardState();
}

class HomeCardState extends State<HomeCard> with AutomaticKeepAliveClientMixin {
  final int _week = int.parse(writeData["week"]);

  @override
  void initState() {
    super.initState();
    // _getWeek();
  }

  String _weekProgressText() {
    return ((_week * 5) + (DateTime.now().weekday / 7 * 5)).toInt().toString() + "%";
  }

  double _weekProgressDouble() {
    return (_week * 5 / 100) + (DateTime.now().weekday / 7 * 5 / 100);
  }

  String _weekText() {
    if (_week == 20) {
      return "学期即将结束";
    } else if (_week >= 17) {
      return "期末来临,复习为重";
    } else if (_week >= 10) {
      return "学期过半,珍惜当下";
    } else if (_week >= 5) {
      return "已过小半,集中精力";
    } else if (_week >= 1) {
      return "开学不久,好好玩吧";
    } else {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: Colors.blue,
      ),
      child: Stack(children: [
        Align(
          alignment: Alignment.centerRight,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 0, 18, 0),
            child: SizedBox(
              //限制进度条的高度
              height: 60.0,
              //限制进度条的宽度
              width: 60,
              child: CircularProgressIndicator(
                  strokeWidth: 8,
                  //0~1的浮点数，用来表示进度多少;如果 value 为 null 或空，则显示一个动画，否则显示一个定值
                  value: _weekProgressDouble(),
                  //背景颜色
                  backgroundColor: const Color.fromARGB(128, 255, 255, 255),
                  //进度颜色
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white)),
            ),
          ),
        ),
        Align(
            alignment: Alignment.centerRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 32, 0),
              child: Text(_weekProgressText(), style: const TextStyle(color: Colors.white)),
            )),
        Align(
          alignment: Alignment.topRight,
          child: Container(
            margin: const EdgeInsets.fromLTRB(0, 24, 90, 0),
            child: Text(
              "第$_week周",
              style:
                  const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900),
            ),
          ),
        ),
        Align(
            alignment: Alignment.bottomRight,
            child: Container(
              margin: const EdgeInsets.fromLTRB(0, 0, 90, 24),
              child: Text(_weekText(), style: const TextStyle(color: Colors.white)),
            )),
        Align(
            alignment: Alignment.centerLeft,
            child: Container(
                // height: 40,
                width: 60,
                // decoration: const BoxDecoration(
                //   borderRadius: BorderRadius.all(Radius.circular(6.0)),
                //   color: Color.fromARGB(32, 0, 0, 0),
                // ),
                margin: const EdgeInsets.fromLTRB(12, 0, 0, 0),
                child: Center(
                    child: Text(DateTime.now().weekday.toString(),
                        style: const TextStyle(
                            color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)))))
      ]),
    );
  }

  @override
  bool get wantKeepAlive => true;
}

class HomeCards extends StatefulWidget {
  const HomeCards({Key? key}) : super(key: key);

  @override
  HomeCardsState createState() => HomeCardsState();
}

class HomeCardsState extends State<HomeCards> {
  @override
  Widget build(BuildContext context) {
    double _iconSize = 36;
    List _icons = [Icons.refresh, Icons.child_friendly, Icons.library_books_sharp];
    List _iconTexts = ["课表刷新", "学习生涯", "我的考试"];
    EdgeInsetsGeometry _textMargin = const EdgeInsets.fromLTRB(0, 44, 0, 0);
    EdgeInsetsGeometry _iconMargin = const EdgeInsets.fromLTRB(0, 0, 0, 32);
    Decoration? _cardDecoration = const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(6.0)),
        color: Color.fromARGB(42, 199, 229, 253));
    double _width = MediaQuery.of(context).size.width;
    TextStyle _textStyle = const TextStyle(color: Colors.black54);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      mainAxisSize: MainAxisSize.max,
      children: [
        Container(
          margin: const EdgeInsets.fromLTRB(0, 8, 4, 16),
          height: 100,
          width: _width / 3 - 48 / 3,
          decoration: _cardDecoration,
          child: Stack(children: [
            Align(
                child: Container(
                    margin: _iconMargin,
                    child: Icon(
                      _icons[0],
                      color: Colors.blue,
                      size: _iconSize,
                    ))),
            Align(
                child: Container(
                    margin: _textMargin,
                    child: Text(
                      _iconTexts[0],
                      style: _textStyle,
                    )))
          ]),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(4, 8, 4, 16),
          height: 100,
          width: _width / 3 - 48 / 3,
          decoration: _cardDecoration,
          child: Stack(children: [
            Align(
                child: Container(
                    margin: _iconMargin,
                    child: Icon(
                      _icons[1],
                      color: Colors.blue,
                      size: _iconSize,
                    ))),
            Align(
                child:
                    Container(margin: _textMargin, child: Text(_iconTexts[1], style: _textStyle)))
          ]),
        ),
        Container(
          margin: const EdgeInsets.fromLTRB(4, 8, 0, 16),
          height: 100,
          width: _width / 3 - 48 / 3,
          decoration: _cardDecoration,
          child: Stack(children: [
            Align(
                child: Container(
                    margin: _iconMargin,
                    child: Icon(
                      _icons[2],
                      color: Colors.blue,
                      size: _iconSize,
                    ))),
            Align(
                child:
                    Container(margin: _textMargin, child: Text(_iconTexts[2], style: _textStyle)))
          ]),
        )
      ],
    );
  }
}
