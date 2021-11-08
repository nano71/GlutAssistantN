import 'package:flutter/material.dart';

class QueryPage extends StatefulWidget {
  final String title;

  const QueryPage({Key? key, this.title = "查询"}) : super(key: key);

  @override
  State<QueryPage> createState() => _QueryPageState();
}

class _QueryPageState extends State<QueryPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        child: Text(widget.title),
        onPressed: () {
          Navigator.of(context).pop();
        },
      ),
      backgroundColor: Colors.white,
      body: Text(widget.title),
    );
  }
}
