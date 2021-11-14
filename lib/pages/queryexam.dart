import 'package:flutter/material.dart';
import 'package:glutassistantn/common/get.dart';
import 'package:glutassistantn/config.dart';
import 'package:glutassistantn/pages/home.dart';
import 'package:glutassistantn/widget/bars.dart';
import 'package:glutassistantn/widget/lists.dart';

import '../data.dart';
import 'login.dart';

class QueryExamPage extends StatefulWidget {
  final String title;

  const QueryExamPage({Key? key, this.title = "生涯"}) : super(key: key);

  @override
  State<QueryExamPage> createState() => _QueryExamPageState();
}

class _QueryExamPageState extends State<QueryExamPage> {
  bool login = true;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getExam().then((value) => process(value));
    getCareer();
  }

  process(String value) {
    if (value == "success") {
      setState(() {});
    } else if (value == "fail") {
      Navigator.of(context).push(
          // 在FormPage()里传入参数
          MaterialPageRoute(builder: (context) => const LoginPage()));
    } else {
      print(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Container(
        color: Colors.white,
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
          slivers: [
            publicTopBar(
                "我的考试",
                InkWell(
                  child: const Icon(
                    Icons.close_outlined,
                    size: 24,
                    color: Colors.white,
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                  },
                ),
                readColor(),
                Colors.white,
                0),
            SliverToBoxAdapter(
              child: Container(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                color: readColor(),
                margin: const EdgeInsets.fromLTRB(0, 0, 0, 16),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          width: 50,
                          child: Text(
                            "$examListA",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        Container(
                          width: 50,
                          child: Text(
                            "$examListB",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                        Container(
                          width: 50,
                          child: Text(
                            "NaN",
                            textAlign: TextAlign.center,
                            style: TextStyle(color: Colors.white, fontSize: 24),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 8,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "已经历的",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "即将到来",
                          style: TextStyle(color: Colors.white),
                        ),
                        Text(
                          "生涯预估",
                          style: TextStyle(color: Colors.white),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            ExamList(),
          ],
        ),
      ),
    );
  }
}
