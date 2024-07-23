import 'package:flutter/material.dart';

class ScreenTwoDemo extends StatefulWidget {
  const ScreenTwoDemo({super.key});

  @override
  State createState() => _ScreenTwoDemoState();
}

class _ScreenTwoDemoState extends State<ScreenTwoDemo> {
  @override
  Widget build(context) => Scaffold(
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
