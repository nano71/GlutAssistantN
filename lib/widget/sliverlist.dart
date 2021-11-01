import 'package:flutter/material.dart';

class MaterialAppSliverList extends StatelessWidget {
  const MaterialAppSliverList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
            //创建列表项
            return Container(
                margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                height: 50,
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.all(Radius.circular(6.0)),
                ),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Text('A409D' '|',
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xff666666))),
                              Text('课程$index',
                                  style: const TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xff333333))),
                            ],
                          ),
                          Row(
                            children: [
                              const Text('1-2节' '|',
                                  style: TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xff666666))),
                              Text('老师$index',
                                  style: const TextStyle(
                                      decoration: TextDecoration.none,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w300,
                                      color: Color(0xff666666))),
                            ],
                          ),
                        ],
                      ),
                      const Text("还有10分钟",
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              fontWeight: FontWeight.w300,
                              color: Color(0xff666666))),
                    ]));
          }, childCount: 4 //30个列表项
      ),
    );
  }
}
