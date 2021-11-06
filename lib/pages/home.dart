import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:glutnnbox/widget/bars.dart';
import 'package:glutnnbox/widget/cards.dart';
import 'package:glutnnbox/widget/lists.dart';

import '../data.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  TextStyle _tomorrowAndTodayTextStyle() {
    return const TextStyle(fontSize: 14, color: Colors.black, decoration: TextDecoration.none);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
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
                    const HomeCards(),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(todayScheduleTitle, style: _tomorrowAndTodayTextStyle()),
                    )
                  ]),
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
        ));
  }
}
