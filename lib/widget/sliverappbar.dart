import 'package:flutter/material.dart';
class MaterialAppSliverAppBar extends StatelessWidget {
  const MaterialAppSliverAppBar({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      collapsedHeight: 56.00,
      primary: true,
      backgroundColor: Colors.white,
      stretch: true,
      expandedHeight: 125.0,
      elevation: 0.3,
      flexibleSpace: FlexibleSpaceBar(
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: const [
              Text(
                '今日一览',
                style:
                    TextStyle(color: Colors.black, fontWeight: FontWeight.w400),
              ),
              Icon(Icons.settings, size: 24)
            ],
          ),
          titlePadding: const EdgeInsets.fromLTRB(16, 0, 16, 12)),
    );
  }
}
