import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/Configuration.dart';
import 'package:infobip_mobilemessaging/models/UserData.dart';
import 'package:infobip_mobilemessaging/models/Installation.dart';
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
    InfobipMobilemessaging.on(LibraryEvent.TOKEN_RECEIVED, (String token) {
      print("Callback. TOKEN_RECEIVED event:" + token);

      InfobipMobilemessaging.saveUser(UserData(
          externalUserId: "ext-12345",
          firstName: "TestFlutterName 1",
          lastName: "TestFlutterLastName 1"
      ));

      InfobipMobilemessaging.getInstallation().then((Installation installation) => {
        print(installation)
      });
    });
    InfobipMobilemessaging.on(LibraryEvent.MESSAGE_RECEIVED, (Message message) => {
      print("Callback. MESSAGE_RECEIVED event,  message title: "  + message.title + " body: " + message.body)
    });
    InfobipMobilemessaging.on(LibraryEvent.USER_UPDATED, (event) => {
      print("Callback. USER_UPDATED event:" + event.toString())
    });
    InfobipMobilemessaging.on(LibraryEvent.PERSONALIZED, (event) => {
      print("Callback. PERSONALIZED event:" + event.toString())
    });
    InfobipMobilemessaging.on(LibraryEvent.INSTALLATION_UPDATED, (String event) => {
      print("Callback. INSTALLATION_UPDATED event:" + event.toString())
    });
    InfobipMobilemessaging.on(LibraryEvent.DEPERSONALIZED, (event) => {
      print("Callback. DEPERSONALIZED event:" + event.toString())
    });
    InfobipMobilemessaging.on(LibraryEvent.NOTIFICATION_ACTION_TAPPED, (event) => {
      print("Callback. NOTIFICATION_ACTION_TAPPED event:" + event.toString())
    });
    InfobipMobilemessaging.on(LibraryEvent.NOTIFICATION_TAPPED, (event) => {
      print("Callback. NOTIFICATION_TAPPED event:" + event.toString())
    });
    InfobipMobilemessaging.on(LibraryEvent.REGISTRATION_UPDATED, (String token) => {
      print("Callback. REGISTRATION_UPDATED event:" + token)
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
