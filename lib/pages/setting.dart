import 'package:flutter/material.dart';

class SettingPage extends StatefulWidget {
  final String title;

  const SettingPage({Key? key, this.title = "返回"}) : super(key: key);

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
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
