//
//  demo_tile.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'package:flutter/material.dart';

import '../widgets/page.dart' as navigation;

class DemoTile extends StatelessWidget {
  final navigation.Page demo;

  const DemoTile({required this.demo, super.key});

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(demo.name),
        onTap: () {
          Navigator.pushNamed(context, demo.route);
        },
      );
}
