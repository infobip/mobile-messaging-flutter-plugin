//
//  screen_one.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'package:flutter/material.dart';

class ScreenOneDemo extends StatefulWidget {
  const ScreenOneDemo({super.key});

  @override
  State createState() => _ScreenOneDemoState();
}

class _ScreenOneDemoState extends State<ScreenOneDemo> {
  @override
  Widget build(context) => Scaffold(
        appBar: AppBar(
          title: const Text('Screen One'),
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
