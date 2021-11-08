import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  final String title;

  const InfoPage({Key? key, this.title = "说明"}) : super(key: key);

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
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
