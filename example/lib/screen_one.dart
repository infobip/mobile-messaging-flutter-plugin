import 'package:flutter/material.dart';

class ScreenOneDemo extends StatefulWidget {
  const ScreenOneDemo({Key key,}) : super(key: key);

  @override
  State createState() => _ScreenOneDemoState();
}

class _ScreenOneDemoState extends State<ScreenOneDemo>{
  @override
  Widget build(context) => Scaffold(
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