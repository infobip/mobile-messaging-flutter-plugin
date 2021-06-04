import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/Configuration.dart';
import 'package:infobip_mobilemessaging/models/LibraryEvent.dart';
import 'package:infobip_mobilemessaging/models/Message.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    await InfobipMobilemessaging.init(Configuration(
        applicationCode: "<Yours app code>",
        androidSettings: AndroidSettings(
            firebaseSenderId: "<Yours Firebase sender ID>"
        ),
        iosSettings: IOSSettings(
            notificationTypes: ["alert", "badge", "sound"],
            forceCleanup: false,
            logging: true
        )
    ));
    InfobipMobilemessaging.on(LibraryEvent.TOKEN_RECEIVED, (event) => {
      print("Callback. TOKEN_RECEIVED event:" + event.toString())
    });
    InfobipMobilemessaging.on(LibraryEvent.MESSAGE_RECEIVED, (Map<String, dynamic> event) => {
      print("Callback. MESSAGE_RECEIVED event,  message title: "  + event["body"])
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Plugin example app'),
        ),
        body: Center(
          child: Text('Running'),
        ),
      ),
    );
  }
}
