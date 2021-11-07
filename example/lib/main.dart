import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:infobip_mobilemessaging/models/IOSChatSettings.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/Configuration.dart';
import 'package:infobip_mobilemessaging/models/UserData.dart';
import 'package:infobip_mobilemessaging/models/Installation.dart';
import 'package:infobip_mobilemessaging/models/LibraryEvent.dart';
import 'package:infobip_mobilemessaging/models/Message.dart';
import 'sign_in_http.dart';
import 'package:infobip_mobilemessaging/models/PersonalizeContext.dart';

void main() async {
  runApp(MyApp());
}

final pages = [
  Page(
    name: 'Personalize',
    route: '/signin_http',
    builder: (context) => SignInHttpDemo(),
  ),
];

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

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
        applicationCode: "Your Application Code",
        inAppChatEnabled: true,
        androidSettings: AndroidSettings(firebaseSenderId: "Your Firebase ID"),
        iosSettings: IOSSettings(
            notificationTypes: ["alert", "badge", "sound"],
            forceCleanup: false,
            logging: true)));
    InfobipMobilemessaging.setupiOSChatSettings(IOSChatSettings(
      title: 'Flutter Example Chat',
      sendButtonColor: '#ff5722',
      navigationBarItemsColor: '#ff8a50',
      navigationBarColor: '#c41c00',
      navigationBarTitleColor: '#000000',
    ));
    InfobipMobilemessaging.on(LibraryEvent.TOKEN_RECEIVED, (String token) {
      print("Callback. TOKEN_RECEIVED event:" + token);
      _HomePageState.addLibraryEvent("Token Received");
    });

    InfobipMobilemessaging.on(
        LibraryEvent.MESSAGE_RECEIVED,
        (Message message) => {
              print("Callback. MESSAGE_RECEIVED event, message title: " +
                  message.title +
                  " body: " +
                  message.body),
              _HomePageState.addLibraryEvent("Message Received")
            });
    InfobipMobilemessaging.on(
        LibraryEvent.USER_UPDATED,
        (event) => {
              print("Callback. USER_UPDATED event:" + event.toString()),
              _HomePageState.addLibraryEvent("User Updated")
            });
    InfobipMobilemessaging.on(
        LibraryEvent.PERSONALIZED,
        (event) => {
              print("Callback. PERSONALIZED event:" + event.toString()),
              _HomePageState.addLibraryEvent("Personalized")
            });
    InfobipMobilemessaging.on(
        LibraryEvent.INSTALLATION_UPDATED,
        (String event) => {
              print("Callback. INSTALLATION_UPDATED event:" + event.toString()),
              _HomePageState.addLibraryEvent("Installation Updated")
            });
    InfobipMobilemessaging.on(
        LibraryEvent.DEPERSONALIZED,
        (event) => {
              print("Callback. DEPERSONALIZED event:" + event.toString()),
              _HomePageState.addLibraryEvent("Depersonalized")
            });
    InfobipMobilemessaging.on(
        LibraryEvent.NOTIFICATION_ACTION_TAPPED,
        (event) => {
              print("Callback. NOTIFICATION_ACTION_TAPPED event:" +
                  event.toString()),
              _HomePageState.addLibraryEvent("Notification Action Tapped")
            });
    InfobipMobilemessaging.on(
        LibraryEvent.NOTIFICATION_TAPPED,
        (Message message) => {
              print(
                  "Callback. NOTIFICATION_TAPPED event:" + message.toString()),
              _HomePageState.addLibraryEvent("Notification Tapped"),
              if (message.chat) {print('Chat Message Tapped')}
            });
    InfobipMobilemessaging.on(
        LibraryEvent.REGISTRATION_UPDATED,
        (String token) => {
              print("Callback. REGISTRATION_UPDATED event:" + token),
              _HomePageState.addLibraryEvent("Registration Updated")
            });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Form Samples',
      theme: ThemeData(primarySwatch: Colors.teal),
      routes: Map.fromEntries(pages.map((d) => MapEntry(d.route, d.builder))),
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int counter = 0;
  static List<String> libraryEvents = [''];

  int get _counter {
    return counter;
  }

  static void add() {
    counter++;
  }

  static String getLibraryEvents() {
    String str = '';
    if (libraryEvents == null || libraryEvents.isEmpty) {
      str = 'Zero library events so far!';
    } else {
      libraryEvents.forEach((element) {
        str += element + '\n';
      });
    }
    return str;
  }

  static void addLibraryEvent(String libraryEvent) {
    libraryEvents.add(libraryEvent);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Push Demo Application'),
      ),
      body: ListView(
        children: [
          ...pages.map((d) => DemoTile(demo: d)),
          ListTile(
              title: Text('Depersonalize'),
              onTap: () {
                InfobipMobilemessaging.depersonalize();
              }),
          ListTile(
              title: Text('Get Installation Data'),
              onTap: () async {
                var res = await InfobipMobilemessaging.getInstallation();
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Installation Data'),
                    content: Text(res.toJson().toString() + '\n'),
                    actions: [
                      TextButton(
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              }),
          ListTile(
              title: Text('Save User Data'),
              onTap: () {
                InfobipMobilemessaging.saveUser(UserData(
                    externalUserId: null,
                    firstName: null,
                    lastName: null,
                    middleName: 'Middle Name',
                    //gender: Gender.Male,
                    birthday: null,
                    //phones: ['79123456789'],
                    //emails: ['some.email@gmail.com'],
                    tags: []));
              }),
          ListTile(
              title: Text('Get User Data'),
              onTap: () async {
                var res = await InfobipMobilemessaging.getUser();
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Get User Data'),
                    content: Text(res.toJson().toString() + '\n'),
                    actions: [
                      TextButton(
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              }),
          ListTile(
              title: Text('Depersonalize Installation'),
              onTap: () {
                InfobipMobilemessaging.depersonalizeInstallation(
                    'pushRegistrationId to depersonalize');
              }),
          ListTile(
              title: Text('Set Installation as Primary'),
              onTap: () async {
                InstallationPrimary installation = InstallationPrimary(
                    'pushRegistrationId to set as primary', true);
                InfobipMobilemessaging.setInstallationAsPrimary(installation);
              }),
          ListTile(
              title: Text('Show Library Events'),
              onTap: () {
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('Library Events'),
                    content: Text(getLibraryEvents()),
                    actions: [
                      TextButton(
                        child: const Text('Done'),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      ),
                    ],
                  ),
                );
              }),
          ListTile(
              title: Text('Show Chat'),
              onTap: () {
                InfobipMobilemessaging.showChat();
              }),
          ListTile(
              title: Text('Send Event'),
              onTap: () {
                print("Trying to send event");
                InfobipMobilemessaging.submitEvent({
                  "definitionId": "alEvent1",
                  "properties": {
                    "alEvent1String": "SomeString",
                    "alEvent1Number": 12345,
                    "alEvent1Boolean": true,
                    "alEvent1Date": "2021-10-19"
                  }
                });
              }),
        ],
      ),
    );
  }
}

class DemoTile extends StatelessWidget {
  final Page demo;

  const DemoTile({this.demo, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(demo.name),
      onTap: () {
        Navigator.pushNamed(context, demo.route);
      },
    );
  }
}

class Page {
  String name;
  String route;
  WidgetBuilder builder;

  Page({this.name, this.route, this.builder});
}
