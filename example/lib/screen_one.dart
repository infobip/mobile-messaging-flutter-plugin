import 'package:flutter/material.dart';

class ScreenOneDemo extends StatefulWidget {
  const ScreenOneDemo({Key key,}) : super(key: key);

  @override
  _ScreenOneDemoState createState() => _ScreenOneDemoState();
}

class _ScreenOneDemoState extends State<ScreenOneDemo>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Screen One"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}