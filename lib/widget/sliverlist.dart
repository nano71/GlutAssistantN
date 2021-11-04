import 'package:flutter/material.dart';

class MaterialAppSliverList extends StatelessWidget {
  final List list = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15];

  MaterialAppSliverList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((BuildContext context, int index) {
        return Container(
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            height: 50,
            decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(6.0)),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text('A409D|',
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 14,
                              color: Color(0xff333333))),
                      Text('课程$index',
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 16,
                              color: Color(0xff333333))),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('1-2节' '|',
                          style: TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff999999))),
                      Text('老师$index',
                          style: const TextStyle(
                              decoration: TextDecoration.none,
                              fontSize: 12,
                              color: Color(0xff999999))),
                    ],
                  ),
                ],
              ),
              const Text("还有10分钟",
                  style: TextStyle(
                      decoration: TextDecoration.none, fontSize: 12, color: Color(0xff333333))),
            ]));
      }, childCount: 4),
    );
  }
}
