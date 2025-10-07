//
//  screen_two.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

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
          title: const Text('Screen Two'),
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
