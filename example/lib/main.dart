import 'dart:async';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/configuration.dart'
    as mmconfiguration;
import 'package:infobip_mobilemessaging/models/ios_chat_settings.dart';

import 'screens/homepage.dart';
import 'widgets/page.dart';
// import 'chat_customization.dart' as chatCustomization;

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    if (!mounted) return;

    await InfobipMobilemessaging.init(mmconfiguration.Configuration(
      applicationCode: 'Your Application Code',
      inAppChatEnabled: true,
      fullFeaturedInAppsEnabled: false,
      defaultMessageStorage: true,
      iosSettings: mmconfiguration.IOSSettings(
          notificationTypes: ['alert', 'badge', 'sound'],
          forceCleanup: false,
          logging: true,
          withoutRegisteringForRemoteNotifications: false),
      webRTCUI: mmconfiguration.WebRTCUI(
          configurationId: 'Your WEBRTC push configuration id'),
      // Comment out to apply In-app chat customization
      //inAppChatCustomization: chatCustomization.customTheme,
    ));
    // Comment out to automatically enable WebRTC
    // try {
    //   await InfobipMobilemessaging.enableChatCalls();
    //   print('Calls enabled.');
    // } catch (err) {
    //   print('Calls enable error: $err');
    // }
    InfobipMobilemessaging.setupiOSChatSettings(IOSChatSettings(
      title: 'Flutter Example Chat',
      sendButtonColor: '#ff5722',
      navigationBarItemsColor: '#8DFF33',
      navigationBarColor: '#c41c00',
      navigationBarTitleColor: '#000000',
    ));
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Infobip Flutter Example',
        routes: Map.fromEntries(pages.map((d) => MapEntry(d.route, d.builder))),
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
