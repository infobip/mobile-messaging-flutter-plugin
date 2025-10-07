//
//  main.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/configurations/configuration.dart' as mmconf;

import 'screens/homepage.dart';
import 'widgets/page.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

final mmconf.Configuration ibConfig = mmconf.Configuration(
  applicationCode: 'your_app_code',
  inAppChatEnabled: true,
  fullFeaturedInAppsEnabled: true,
  defaultMessageStorage: true,
  androidSettings: mmconf.AndroidSettings(
    multipleNotifications: true,
  ),
  iosSettings: mmconf.IOSSettings(
    notificationTypes: ['alert', 'badge', 'sound'],
    forceCleanup: false,
    logging: true,
    withoutRegisteringForRemoteNotifications: false,
  ),
  webRTCUI: mmconf.WebRTCUI(configurationId: 'Your WEBRTC push configuration id'),
);

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    await InfobipMobilemessaging.init(ibConfig);
    // Comment out to automatically enable WebRTC
    // try {
    //   await InfobipMobilemessaging.enableChatCalls();
    //   print('Calls enabled.');
    // } catch (err) {
    //   print('Calls enable error: $err');
    // }
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Infobip Flutter Example',
        routes: Map.fromEntries(appNavigationRoutes.map((d) => MapEntry(d.route, d.builder))),
        home: const HomePage(),
        navigatorKey: navigatorKey,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
          scaffoldBackgroundColor: const Color(0xfff4f4f2),
          useMaterial3: true,
          fontFamily: 'RobotoMono',
        ),
      );
}
