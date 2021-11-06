import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutnnbox/config.dart';
import 'package:glutnnbox/pages/home.dart';
import 'package:glutnnbox/pages/mine.dart';
import 'package:glutnnbox/pages/schedule.dart';
import 'package:glutnnbox/widget/bars.dart';

class Index extends StatelessWidget {
  const Index({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return   const Scaffold(
      backgroundColor: Colors.white,
      body: Body(),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

class Body extends StatefulWidget {
  const Body({Key? key}) : super(key: key);

  @override
  BodyState createState() => BodyState();
}

class BodyState extends State<Body> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: Global.pageControl,
        children: const [HomePage(), SchedulePage(), MinePage()]);
  }
}
