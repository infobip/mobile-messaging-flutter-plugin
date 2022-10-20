import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/models/Configuration.dart';
import 'dart:async';

import 'package:infobip_mobilemessaging/models/IOSChatSettings.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/Configuration.dart' as mmconfiguration;
import 'package:infobip_mobilemessaging/models/UserData.dart';
import 'package:infobip_mobilemessaging/models/Installation.dart';
import 'package:infobip_mobilemessaging/models/LibraryEvent.dart';
import 'package:infobip_mobilemessaging/models/Message.dart';
import 'language.dart';
import 'screen_one.dart';
import 'screen_two.dart';
import 'sign_in_http.dart';

void main() async {
  runApp(MyApp());
}

final pages = [
  Page(
    name: 'Personalize',
    route: '/signin_http',
    builder: (context) => SignInHttpDemo(),
  ),
  Page(
    name: 'screen_one',
    route: '/screen_one',
    builder: (context) => ScreenOneDemo(),
  ),
  Page(
    name: 'screen_two',
    route: '/screen_two',
    builder: (context) => ScreenTwoDemo(),
  )
];

class MyApp extends StatefulWidget {
  MyApp({Key key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = new GlobalKey<NavigatorState>();

handleDeeplinkEvent(Message message) {
  if (message.deeplink != null) {
    Uri uri = Uri.parse(message.deeplink.toString());
    List<String> pathSegments = uri.pathSegments;
    for (var pathSegment in pathSegments) {
      navigatorKey.currentState.pushNamed('/' + pathSegment);
    }
  }
}

var storedFunction = (Message message) => handleDeeplinkEvent(message);
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

    await InfobipMobilemessaging.init(mmconfiguration.Configuration(
        applicationCode: "Your Application Code",
        inAppChatEnabled: true,
        defaultMessageStorage: true,
        iosSettings: mmconfiguration.IOSSettings(
            notificationTypes: ["alert", "badge", "sound"],
            forceCleanup: false,
            logging: true
        )
    ));
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
              _HomePageState.addLibraryEvent("Message Received"),
              print("defaultMessageStorage().findAll():"),
              print(InfobipMobilemessaging.defaultMessageStorage().findAll())
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
      routes: Map.fromEntries(pages.map((d) => MapEntry(d.route, d.builder))),
      home: HomePage(),
      navigatorKey: navigatorKey,
      theme: ThemeData(
          primarySwatch: Colors.deepOrange,
          pageTransitionsTheme: const PageTransitionsTheme(
              builders: <TargetPlatform, PageTransitionsBuilder>{
                TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
                TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
              })),
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

  static Future<String> printAllMesages() async {
    String str = '';
    List<Message> messages = await InfobipMobilemessaging.defaultMessageStorage().findAll();
    if (messages == null || messages.isEmpty) {
      str = 'Empty message storage';
    } else {
      messages.forEach((element) {
        print("element:");
        print(element.messageId);
        str += element.toString() + '\n';
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
                UserData user = UserData(
                    externalUserId: null,
                    firstName: null,
                    lastName: null,
                    middleName: 'Middle Name',
                    //gender: Gender.Male,
                    birthday: null,
                    //phones: ['79123456789'],
                    //emails: ['some.email@email.com'],
                    tags: [],
                    customAttributes: {
                      'alList': [
                        {
                          'alDate': '2021-10-11',
                          'alWhole': 2,
                          'alString': 'someAnotherString',
                          'alBoolean': true,
                          'alDecimal': 0.66
                        }
                      ]
                    });
                print(user.toJson());
                InfobipMobilemessaging.saveUser(user);
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
              title: Text('Set chat language'),
              onTap: () {
                showChatLanguageDialog(context);
              }),
          ListTile(
              title: Text('Show Chat'),
              onTap: () {
                InfobipMobilemessaging.showChat();
              }),
          ListTile(
              title: Text('Show Chat and send Contextual Data'),
              onTap: () {
                  Future.delayed(const Duration(milliseconds: 3000), () {
			               // Metadata must be sent after chat is presented, so we delay it
			               InfobipMobilemessaging.sendContextualData("{ demoKey: 'InAppChat Metadata Value' }", false);	
		              });
		              InfobipMobilemessaging.showChat();
              }),
          ListTile(
              title: Text('Send Event'),
              onTap: () {
                print("Trying to send event");
                InfobipMobilemessaging.submitEvent({
                  'definitionId': 'alEvent1',
                  'properties': {
                    'alEvent1String': 'SomeString',
                    'alEvent1Number': 12345,
                    'alEvent1Boolean': true,
                    'alEvent1Date': '2021-10-19'
                  }
                });
              }),
          ListTile(
              title: Text('Register Deeplink on Tap'),
              onTap: () {
                print('Tile "Register Deeplink on Tap" tapped');
                InfobipMobilemessaging.on('notificationTapped', storedFunction);
              }),
          ListTile(
              title: Text('Unregister Deeplink on Tap'),
              onTap: () {
                print('Tile "Unregister Deeplink on Tap" tapped');
                InfobipMobilemessaging.unregister(
                    LibraryEvent.NOTIFICATION_TAPPED, storedFunction);
              }),
          ListTile(
              title: Text('Unregister All Handlers'),
              onTap: () {
                print('Tile "Unregister All Handlers" tapped');
                InfobipMobilemessaging.unregisterAllHandlers(
                    'notificationTapped');
              }),
          ListTile(
              title: Text('Default MessageStorage findAll'),
              onTap: () async {
                var res = await printAllMesages();
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('findAll'),
                    content: Text(res),
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
              title: Text('MessageStorage find first message'),
              onTap: () async {
                String str = '';
                List<Message> messages = await InfobipMobilemessaging.defaultMessageStorage().findAll();
                if (messages == null || messages.isEmpty) {
                  str = 'Empty message storage';
                } else {
                  Message message = messages.first;
                  Message foundedMessage = await InfobipMobilemessaging.defaultMessageStorage().find(message.messageId);
                  str = 'Find message for ${message.messageId}: $foundedMessage';
                }

                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('find'),
                    content: Text(str),
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
              title: Text('MessageStorage: delete first message'),
              onTap: () async {
                String str = '';
                List<Message> messages = await InfobipMobilemessaging.defaultMessageStorage().findAll();
                if (messages == null || messages.isEmpty) {
                  str = 'Empty message storage';
                } else {
                  Message message = messages.first;
                  await InfobipMobilemessaging.defaultMessageStorage().delete(message.messageId);
                  str = 'Delete message with ID: ${message.messageId}';
                }

                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('delete'),
                    content: Text(str),
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
              title: Text('Default MessageStorage deleteAll'),
              onTap: () async {
                var res = InfobipMobilemessaging.defaultMessageStorage().deleteAll();
                showDialog<void>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: const Text('deleteAll'),
                    content: Text(res),
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
        ],
      ),
    );
  }

  // replace this function with the examples above
  showChatLanguageDialog(BuildContext context) {
     List<Language> languages = List<Language>();
     languages.add(Language("ENGLISH","en-US"));
     languages.add(Language("TURKISH","tr-TR"));
     languages.add(Language("KOREAN","ko-KR"));
     languages.add(Language("RUSSIAN","ru-RU"));
     languages.add(Language("CHINESE","zh-TW"));
     languages.add(Language("SPANISH","es-ES"));
     languages.add(Language("SPANISH_LA","es-LA"));
     languages.add(Language("PORTUGUESE","pt-PT"));
     languages.add(Language("PORTUGUESE_BR","pt-BR"));
     languages.add(Language("POLISH","pl-PL"));
     languages.add(Language("ROMANIAN","ro-RO"));
     languages.add(Language("ARABIC","ar-AE"));
     languages.add(Language("BOSNIAN","bs-BA"));
     languages.add(Language("CROATIAN","hr-HR"));
     languages.add(Language("GREEK","el-GR"));
     languages.add(Language("SWEDISH","sv-SE"));
     languages.add(Language("THAI","th-TH"));
     languages.add(Language("LITHUANIAN","lt-LT"));
     languages.add(Language("DANISH","da-DK"));
     languages.add(Language("LATVIAN","lv-LV"));
     languages.add(Language("HUNGARIAN","hu-HU"));
     languages.add(Language("ITALIAN","it-IT"));
     languages.add(Language("FRENCH","fr-FR"));
     languages.add(Language("SLOVENIAN","sl-SI"));
     languages.add(Language("UKRAINIAN","uk-UA"));
     languages.add(Language("JAPANESE","ja-JP"));

     final children = <Widget>[];
     languages.forEach((language) =>
         children.add(
           SimpleDialogOption(
               child: Text(language.name),
               onPressed: () {
                 InfobipMobilemessaging.setLanguage(language.code);
                 Navigator.pop(context, true);
               },
           )
         )
     );

     // set up the SimpleDialog
     SimpleDialog dialog = SimpleDialog(
       title: const Text('Choose chat language'),
       children: children
     );

     // show chat languages dialog
     showDialog(
       context: context,
       builder: (BuildContext context) {
         return dialog;
       },
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
