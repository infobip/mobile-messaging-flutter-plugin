import 'package:flutter/material.dart';

class ScreenTwoDemo extends StatefulWidget {
  const ScreenTwoDemo({Key key,}) : super(key: key);

  @override
  _ScreenTwoDemoState createState() => _ScreenTwoDemoState();
}

class _ScreenTwoDemoState extends State<ScreenTwoDemo>{
  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        title: const Text("Screen Two"),
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