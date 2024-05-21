import 'dart:async';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/configuration.dart' as mmconfiguration;
import 'package:infobip_mobilemessaging/models/installation.dart';
import 'package:infobip_mobilemessaging/models/ios_chat_settings.dart';
import 'package:infobip_mobilemessaging/models/library_event.dart';
import 'package:infobip_mobilemessaging/models/message.dart';
import 'package:infobip_mobilemessaging/models/user_data.dart';

import 'language.dart';
import 'screen_one.dart';
import 'screen_two.dart';
import 'screens/cloud_inbox.dart';
import 'sign_in_http.dart';
import 'chat_customization.dart' as chatCustomization;

void main() async {
  runApp(const MyApp());
}

final pages = [
  Page(
    name: 'Cloud Inbox Demo',
    route: '/cloud_inbox',
    builder: (context) => const CloudInboxScreen(),
  ),
  Page(
    name: 'Personalize',
    route: '/signin_http',
    builder: (context) => const SignInHttpDemo(),
  ),
  Page(
    name: 'screen_one',
    route: '/screen_one',
    builder: (context) => const ScreenOneDemo(),
  ),
  Page(
    name: 'screen_two',
    route: '/screen_two',
    builder: (context) => const ScreenTwoDemo(),
  ),
];

class MyApp extends StatefulWidget {
  const MyApp({Key key}) : super(key: key);

  @override
  State createState() => _MyAppState();
}

final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

handleDeeplinkEvent(Message message) {
  if (message.deeplink != null) {
    Uri uri = Uri.parse(message.deeplink.toString());
    List<String> pathSegments = uri.pathSegments;
    for (var pathSegment in pathSegments) {
      navigatorKey.currentState.pushNamed('/$pathSegment');
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
      applicationCode: 'Your Application Code',
      inAppChatEnabled: true,
      fullFeaturedInAppsEnabled: false,
      defaultMessageStorage: true,
      iosSettings: mmconfiguration.IOSSettings(
          notificationTypes: ['alert', 'badge', 'sound'],
          forceCleanup: false,
          logging: true,
          withoutRegisteringForRemoteNotifications: false),
      webRTCUI: mmconfiguration.WebRTCUI(configurationId: 'Your WEBRTC push configuration id'),
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
    InfobipMobilemessaging.on(LibraryEvent.tokenReceived, (String token) {
      log('Callback. TOKEN_RECEIVED event: $token');
      _HomePageState.addLibraryEvent('Token Received');
    });
    InfobipMobilemessaging.on(
        LibraryEvent.messageReceived,
        (Message message) => {
              log('Callback. MESSAGE_RECEIVED event, message title: ${message.title} body: ${message.body}'),
              _HomePageState.addLibraryEvent('Message Received'),
              log('defaultMessageStorage().findAll():'),
              log(InfobipMobilemessaging.defaultMessageStorage()
                  .findAll()
                  .toString())
            });
    InfobipMobilemessaging.on(
        LibraryEvent.userUpdated,
        (UserData userData) => {
              log('Callback. USER_UPDATED event: $userData'),
              _HomePageState.addLibraryEvent('User Updated')
            });
    InfobipMobilemessaging.on(
        LibraryEvent.personalized,
        (event) => {
              log('Callback. PERSONALIZED event: $event'),
              _HomePageState.addLibraryEvent('Personalized')
            });
    InfobipMobilemessaging.on(
        LibraryEvent.installationUpdated,
        (String event) => {
              log('Callback. INSTALLATION_UPDATED event: $event'),
              _HomePageState.addLibraryEvent('Installation Updated')
            });
    InfobipMobilemessaging.on(
        LibraryEvent.depersonalized,
        (event) => {
              log('Callback. DEPERSONALIZED event: $event'),
              _HomePageState.addLibraryEvent('Depersonalized')
            });
    InfobipMobilemessaging.on(
        LibraryEvent.actionTapped,
        (event) => {
              log('Callback. NOTIFICATION_ACTION_TAPPED event: $event'),
              _HomePageState.addLibraryEvent('Notification Action Tapped')
            });
    InfobipMobilemessaging.on(
        LibraryEvent.notificationTapped,
        (Message message) => {
              log('Callback. NOTIFICATION_TAPPED event: $message'),
              _HomePageState.addLibraryEvent('Notification Tapped'),
              if (message.chat) {log('Chat Message Tapped')}
            });
    InfobipMobilemessaging.on(
        LibraryEvent.registrationUpdated,
        (String token) => {
              log('Callback. REGISTRATION_UPDATED event: $token'),
              _HomePageState.addLibraryEvent('Registration Updated')
            });
    InfobipMobilemessaging.on(
        LibraryEvent.chatAvailabilityUpdated,
        (isAvailable) => {
              log('Callback. IN_APP_CHAT_AVAILABILITY_UPDATED event: $isAvailable'),
              _HomePageState.addLibraryEvent('Availability Updated')
          });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
        title: 'Form Samples',
        routes: Map.fromEntries(pages.map((d) => MapEntry(d.route, d.builder))),
        home: const HomePage(),
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

class HomePage extends StatefulWidget {
  const HomePage({Key key}) : super(key: key);

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static int counter = 0;
  static List<String> libraryEvents = [''];

  int get _counter => counter;

  static void add() {
    counter++;
  }

  static String getLibraryEvents() {
    String str = '';
    if (libraryEvents == null || libraryEvents.isEmpty) {
      str = 'Zero library events so far!';
    } else {
      for (var element in libraryEvents) {
        str += '$element\n';
      }
    }
    return str;
  }

  static Future<String> logAllMessages() async {
    String str = '';
    List<Message> messages =
        await InfobipMobilemessaging.defaultMessageStorage().findAll();
    if (messages == null || messages.isEmpty) {
      str = 'Empty message storage';
    } else {
      for (var element in messages) {
        log('element: ${element.messageId}');
        str += '$element\n';
      }
    }
    return str;
  }

  static void addLibraryEvent(String libraryEvent) {
    libraryEvents.add(libraryEvent);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Push Demo Application'),
        ),
        body: ListView(
          children: [
            ...pages.map((d) => DemoTile(demo: d)),
            ListTile(
                title: const Text('Depersonalize'),
                onTap: () {
                  InfobipMobilemessaging.depersonalize();
                }),
            ListTile(
                title: const Text('Get Installation Data'),
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
                title: const Text('Save User Data'),
                onTap: () async {
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
                  log(user.toJson().toString());
                  try {
                    await InfobipMobilemessaging.saveUser(user);
                  } catch (e) {
                    log('MobileMessaging: details ' + e.details);
                    log('MobileMessaging: code ' + e.code);

                    switch (e.code) {
                      case 'USER_MERGE_INTERRUPTED':
                        {
                          //do something with the error
                        }
                        break;
                      case 'PHONE_INVALID':
                        {
                          //the phone provided was not recognized as a valid one
                        }
                        break;
                      case 'EMAIL_INVALID':
                        {
                          //the email provided was not recognized as a valid one
                        }
                        break;
                      default:
                        {
                          log('MobileMessaging: error is $e');
                        }
                        break;
                    }
                  }
                }),
            ListTile(
                title: const Text('Get User Data'),
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
            if (Platform.isAndroid)
              ListTile(
                title: const Text('Register For Android 13 Notifications'),
                onTap: () {
                  log('trying to register for remote notifications');
                  InfobipMobilemessaging
                      .registerForAndroidRemoteNotifications();
                },
              ),
            if (Platform.isIOS)
              ListTile(
                title: const Text('Register For iOS Notifications'),
                onTap: () {
                  log('trying to register for ios remote notifications');
                  InfobipMobilemessaging.registerForRemoteNotifications();
                },
              ),
            ListTile(
                title: const Text('Depersonalize Installation'),
                onTap: () {
                  InfobipMobilemessaging.depersonalizeInstallation(
                      'pushRegistrationId to depersonalize');
                }),
            ListTile(
                title: const Text('Set Installation as Primary'),
                onTap: () async {
                  InstallationPrimary installation = InstallationPrimary(
                      'pushRegistrationId to set as primary', true);
                  InfobipMobilemessaging.setInstallationAsPrimary(installation);
                }),
            ListTile(
                title: const Text('Show Library Events'),
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
                title: const Text('Set Chat Language'),
                onTap: () {
                  showChatLanguageDialog(context);
                }),
            ListTile(
                title: const Text('Show Chat'),
                onTap: () {
                  // InfobipMobilemessaging.setJwt('your JWT'); // Comment out to automatically log-in using authentication
                  InfobipMobilemessaging.showChat();
                }),
            ListTile(
                title: const Text('Show Chat and Send Contextual Data'),
                onTap: () {
                  Future.delayed(const Duration(milliseconds: 3000), () {
                    // Metadata must be sent after chat is presented, so we delay it
                    InfobipMobilemessaging.sendContextualData(
                        "{ demoKey: 'InAppChat Metadata Value' }", false);
                  });
                  InfobipMobilemessaging.showChat();
                }),
            ListTile(
                title: const Text('Send Event'),
                onTap: () {
                  log('Trying to send event');
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
                title: const Text('Register Deeplink on Tap'),
                onTap: () {
                  log('Tile "Register Deeplink on Tap" tapped');
                  InfobipMobilemessaging.on(
                      'notificationTapped', storedFunction);
                }),
            ListTile(
                title: const Text('Unregister Deeplink on Tap'),
                onTap: () {
                  log('Tile "Unregister Deeplink on Tap" tapped');
                  InfobipMobilemessaging.unregister(
                      LibraryEvent.notificationTapped, storedFunction);
                }),
            ListTile(
                title: const Text('Unregister All Handlers'),
                onTap: () {
                  log('Tile "Unregister All Handlers" tapped');
                  InfobipMobilemessaging.unregisterAllHandlers(
                      'notificationTapped');
                }),
            ListTile(
                title: const Text('MessageStorage: findAll'),
                onTap: () async {
                  var res = await logAllMessages();
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
                title: const Text('MessageStorage: Find First Message'),
                onTap: () async {
                  String str = '';
                  List<Message> messages =
                      await InfobipMobilemessaging.defaultMessageStorage()
                          .findAll();
                  if (messages == null || messages.isEmpty) {
                    str = 'Empty message storage';
                  } else {
                    Message message = messages.first;
                    Message foundedMessage =
                        await InfobipMobilemessaging.defaultMessageStorage()
                            .find(message.messageId);
                    str =
                        'Find message for ${message.messageId}: $foundedMessage';
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
                title: const Text('MessageStorage: Delete First Message'),
                onTap: () async {
                  String str = '';
                  List<Message> messages =
                      await InfobipMobilemessaging.defaultMessageStorage()
                          .findAll();
                  if (messages == null || messages.isEmpty) {
                    str = 'Empty message storage';
                  } else {
                    Message message = messages.first;
                    await InfobipMobilemessaging.defaultMessageStorage()
                        .delete(message.messageId);
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
                title: const Text('MessageStorage: deleteAll'),
                onTap: () async {
                  await InfobipMobilemessaging.defaultMessageStorage()
                      .deleteAll();
                  showDialog<void>(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('deleteAll'),
                      content: const Text('All messages deleted'),
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
                title: const Text('Enable calls'),
                onTap: () {
                  log('Enabling calls');
                  try {
                    InfobipMobilemessaging.enableChatCalls();
                  } catch (e) {
                    log('Failed to enable calls. ' + e.toString());
                  }
                }),
            ListTile(
                title: const Text('Disable calls'),
                onTap: () {
                  log('Disabling calls');
                  try {
                    InfobipMobilemessaging.disableCalls();
                  } catch (e) {
                    log('Failed to disable calls. ' + e.toString());
                  }
                })
          ],
        ),
      );

  // replace this function with the examples above
  showChatLanguageDialog(BuildContext context) {
    List<Language> languages = <Language>[];
    languages.add(Language('ENGLISH', 'en-US'));
    languages.add(Language('TURKISH', 'tr-TR'));
    languages.add(Language('KOREAN', 'ko-KR'));
    languages.add(Language('RUSSIAN', 'ru-RU'));
    languages.add(Language('CHINESE SIMPLIFIED', 'zh-Hans'));
    languages.add(Language('CHINESE TRADITIONAL', 'zh-TW'));
    languages.add(Language('SPANISH', 'es-ES'));
    languages.add(Language('SPANISH_LA', 'es-LA'));
    languages.add(Language('PORTUGUESE', 'pt-PT'));
    languages.add(Language('PORTUGUESE_BR', 'pt-BR'));
    languages.add(Language('POLISH', 'pl-PL'));
    languages.add(Language('ROMANIAN', 'ro-RO'));
    languages.add(Language('ARABIC', 'ar-AE'));
    languages.add(Language('BOSNIAN', 'bs-BA'));
    languages.add(Language('CROATIAN', 'hr-HR'));
    languages.add(Language('GREEK', 'el-GR'));
    languages.add(Language('SWEDISH', 'sv-SE'));
    languages.add(Language('THAI', 'th-TH'));
    languages.add(Language('LITHUANIAN', 'lt-LT'));
    languages.add(Language('DANISH', 'da-DK'));
    languages.add(Language('LATVIAN', 'lv-LV'));
    languages.add(Language('HUNGARIAN', 'hu-HU'));
    languages.add(Language('ITALIAN', 'it-IT'));
    languages.add(Language('FRENCH', 'fr-FR'));
    languages.add(Language('SLOVENIAN', 'sl-SI'));
    languages.add(Language('UKRAINIAN', 'uk-UA'));
    languages.add(Language('JAPANESE', 'ja-JP'));

    final children = <Widget>[];
    for (var language in languages) {
      children.add(SimpleDialogOption(
        child: Text(language.name),
        onPressed: () {
          InfobipMobilemessaging.setLanguage(language.code);
          Navigator.pop(context, true);
        },
      ));
    }

    // set up the SimpleDialog
    SimpleDialog dialog = SimpleDialog(
        title: const Text('Choose Chat Language'), children: children);

    // show chat languages dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }
}

class DemoTile extends StatelessWidget {
  final Page demo;

  const DemoTile({this.demo, Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) => ListTile(
        title: Text(demo.name),
        onTap: () {
          Navigator.pushNamed(context, demo.route);
        },
      );
}

class Page {
  String name;
  String route;
  WidgetBuilder builder;

  Page({this.name, this.route, this.builder});
}
