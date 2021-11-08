import 'package:flutter/material.dart';

class CareerPage extends StatefulWidget {
  final String title;

  const CareerPage({Key? key, this.title = "生涯"}) : super(key: key);

  @override
  State<CareerPage> createState() => _CareerPageState();
}

class _CareerPageState extends State<CareerPage> {
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
