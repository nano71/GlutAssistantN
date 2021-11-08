import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:glutnnbox/common/get.dart';
import 'package:glutnnbox/common/init.dart';
import 'package:glutnnbox/common/io.dart';
import 'package:glutnnbox/config.dart';
import 'package:glutnnbox/pages/home.dart';
import 'package:glutnnbox/pages/mine.dart';
import 'package:glutnnbox/pages/schedule.dart';
import 'package:glutnnbox/widget/bars.dart';

class CustomRoute extends PageRouteBuilder {
  final Widget widget;

  CustomRoute(this.widget)
      : super(
            //父类的方法
            //设置动画持续的时间，建议再1和2之间
            transitionDuration: const Duration(seconds: 2),
            //页面的构造器
            pageBuilder: (
              BuildContext context,
              Animation<double> animation,
              //次级动画
              Animation<double> secondaryAnimation,
            ) {
              return widget;
            },
            //过度效果
            transitionsBuilder: (BuildContext context, Animation<double> animation,
                Animation<double> secondaryAnimation, Widget child) {
              // 过度的动画的值
              return FadeTransition(
                // 过度的透明的效果
                opacity: Tween(begin: 0.0, end: 1.0)
                    // 给他个透明度的动画   CurvedAnimation：设置动画曲线
                    .animate(CurvedAnimation(parent: animation, curve: Curves.ease)),
                child: child,
              );
            });
}

class InitPage extends StatefulWidget {
  const InitPage({Key? key}) : super(key: key);

  @override
  InitPageState createState() => InitPageState();
}

class InitPageState extends State<InitPage> {
  @override
  void initState() {
    super.initState();
    _init();
  }

  _init() async {
    await getWeek();
    print("getWeek End");
    await readSchedule();
    await initTodaySchedule();
    await initTomorrowSchedule();
    print("initSchedule End");
    //跳转并关闭当前页面

    Navigator.pushAndRemoveUntil(
      context,
      CustomRoute(
        const Index(),
      ),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.white,
        child: const Center(
          child: Text(
            "",
            style: TextStyle(
                color: Colors.blue, fontWeight: FontWeight.w100, decoration: TextDecoration.none),
          ),
        ));
  }
}

class Index extends StatelessWidget {
  const Index({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Body(),
      bottomNavigationBar: BottomNavBar(),
    );
  }
}

class Body extends StatelessWidget {
  const Body({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: Global.pageControl,
        children: const [HomePage(), SchedulePage(), MinePage()]);
  }
}
