import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/data/installation.dart';
import 'package:infobip_mobilemessaging/models/data/message.dart';
import 'package:infobip_mobilemessaging/models/data/user_data.dart';
import 'package:infobip_mobilemessaging/models/library_event.dart';

import '../main.dart';
import '../widgets/demo_tile.dart';
import '../widgets/page.dart';
import 'chat/dialog_chat_examples.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  static List<String> libraryEvents = [''];

  @override
  void initState() {
    super.initState();
    _subscribeToEvents();
  }

  //#region MobileMessaging Library events
  void _subscribeToEvents() {
    if (!mounted) return;

    InfobipMobilemessaging.on(
      LibraryEvent.tokenReceived,
      (String token) {
        log('Callback. TOKEN_RECEIVED event: $token');
        _addLibraryEvent('Token Received');
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.messageReceived,
      (Message message) => {
        log('Callback. MESSAGE_RECEIVED event, message title: ${message.title} body: ${message.body}'),
        _addLibraryEvent('Message Received'),
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.userUpdated,
      (UserData userData) => {
        log('Callback. USER_UPDATED event: $userData'),
        _addLibraryEvent('User Updated'),
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.personalized,
      (event) => {
        log('Callback. PERSONALIZED event: $event'),
        _addLibraryEvent('Personalized'),
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.installationUpdated,
      (String event) => {
        log('Callback. INSTALLATION_UPDATED event: $event'),
        _addLibraryEvent('Installation Updated'),
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.depersonalized,
      (event) => {
        log('Callback. DEPERSONALIZED event: $event'),
        _addLibraryEvent('Depersonalized'),
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.actionTapped,
      (Message event) => {
        log('Callback. NOTIFICATION_ACTION_TAPPED event: $event'),
        _addLibraryEvent('Notification Action Tapped'),
        _handleDeeplinkEvent(event),
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.notificationTapped,
      (Message message) => {
        log('Callback. NOTIFICATION_TAPPED event: $message'),
        _addLibraryEvent('Notification Tapped'),
        if (message.chat != null && message.chat!) {log('Chat Message Tapped')},
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.registrationUpdated,
      (String token) => {
        log('Callback. REGISTRATION_UPDATED event: $token'),
        _addLibraryEvent('Registration Updated'),
      },
    );
    InfobipMobilemessaging.on(
      LibraryEvent.chatAvailabilityUpdated,
      (isAvailable) => {
        log('Callback. IN_APP_CHAT_AVAILABILITY_UPDATED event: $isAvailable'),
        _addLibraryEvent('Availability Updated'),
      },
    );
  }

  static void _addLibraryEvent(String libraryEvent) {
    libraryEvents.add(libraryEvent);
  }

  static String _getLibraryEvents() {
    String str = '';
    if (libraryEvents.isEmpty) {
      str = 'Zero library events so far!';
    } else {
      for (var element in libraryEvents) {
        str += '$element\n';
      }
    }
    return str;
  }

  //#endregion

  void _handleDeeplinkEvent(Message message) {
    if (message.deeplink != null) {
      Uri uri = Uri.parse(message.deeplink.toString());
      List<String> pathSegments = uri.pathSegments;
      for (var pathSegment in pathSegments) {
        navigatorKey.currentState?.pushNamed('/$pathSegment');
      }
    }
  }

  void _showDialog(String name, String value) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(name),
        content: Text(value),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  static Future<String> _logAllMessages() async {
    String str = '';
    List<Message>? messages = await InfobipMobilemessaging.defaultMessageStorage()?.findAll();
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

  void _onGetInstallation() async {
    try {
      var installation = await InfobipMobilemessaging.getInstallation();
      _showDialog('Installation Data', installation.toJson().toString());
    } on PlatformException catch (e) {
      log('Error happened: ${e.message}');
    }
  }

  void _onFetchInstallation() async {
    try {
      var installation = await InfobipMobilemessaging.fetchInstallation();
      _showDialog('Installation Data', installation.toJson().toString());
    } on PlatformException catch (e) {
      log('Error happened: ${e.message}');
    }
  }

  void _onSaveUser() async {
    var currentUser = await InfobipMobilemessaging.getUser();

    currentUser.middleName ??= 'Justin';
    // currentUser.phones ??= ['38516419710'];
    // currentUser.emails ??= ['some@email.com'];

    try {
      await InfobipMobilemessaging.saveUser(currentUser);
    } on PlatformException catch (e) {
      log('MobileMessaging: code ${e.code}');
      log('MobileMessaging: message ${e.message}');
      log('MobileMessaging: details ${e.details}');

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
  }

  void _onFetchUser() async {
    try {
      var user = await InfobipMobilemessaging.fetchUser();
      _showDialog('fetched User Data', user.toJson().toString());
    } on PlatformException catch (e) {
      log('Error happened: code is ${e.code}, \nmessage: ${e.message}, \ndetails: ${e.details}');

    }
  }

  void _onGetUser() async {
    try {
      var user = await InfobipMobilemessaging.getUser();
      log('trying to show installations');
      if (user.installations != null) {
        for (var installation in user.installations!) {
          log('Another installation is: ${installation.toJson()}');
        }
      }
      _showDialog('User Data', user.toJson().toString());
    } on PlatformException catch (e) {
      log('Error happened: ${e.message}');
    }
  }

  void _onFindFirstMessage() async {
    String str = '';
    List<Message>? messages = await InfobipMobilemessaging.defaultMessageStorage()?.findAll();
    if (messages == null || messages.isEmpty) {
      str = 'Message storage is empty';
    } else {
      Message message = messages.first;
      Message? foundMessage = await InfobipMobilemessaging.defaultMessageStorage()?.find(message.messageId);
      str = 'Found message with ID ${message.messageId}: ${foundMessage.toString()}';
    }

    _showDialog('Find First', str);
  }

  void _onDeleteFirstMessage() async {
    String str = '';
    List<Message>? messages = await InfobipMobilemessaging.defaultMessageStorage()?.findAll();
    if (messages == null || messages.isEmpty) {
      str = 'Empty message storage';
    } else {
      Message message = messages.first;
      await InfobipMobilemessaging.defaultMessageStorage()?.delete(message.messageId);
      str = 'Delete message with ID: ${message.messageId}';
    }

    _showDialog('Deleted First', str);
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
              title: const Text('Chat Examples'),
              onTap: () {
                ChatExamples.showChatExamplesDialog(context);
              },
            ),
            ListTile(
              title: const Text('Depersonalize'),
              onTap: () {
                InfobipMobilemessaging.depersonalize();
              },
            ),
            ListTile(
              title: const Text('Get Installation Data'),
              onTap: () => _onGetInstallation(),
            ),
            ListTile(
              title: const Text('Fetch Installation Data'),
              onTap: () => _onFetchInstallation(),
            ),
            ListTile(
              title: const Text('Save User Data'),
              onTap: () => _onSaveUser(),
            ),
            ListTile(
              title: const Text('Fetch User Data'),
              onTap: () => _onFetchUser(),
            ),
            ListTile(
              title: const Text('Get User Data'),
              onTap: () => _onGetUser(),
            ),
            if (Platform.isAndroid)
              ListTile(
                title: const Text('Register For Android 13 Notifications'),
                onTap: () {
                  log('trying to register for Android remote notifications');
                  InfobipMobilemessaging.registerForAndroidRemoteNotifications();
                },
              ),
            if (Platform.isIOS)
              ListTile(
                title: const Text('Register For iOS Notifications'),
                onTap: () {
                  log('trying to register for iOS remote notifications');
                  InfobipMobilemessaging.registerForRemoteNotifications();
                },
              ),
            ListTile(
              title: const Text('Depersonalize Installation'),
              onTap: () {
                InfobipMobilemessaging.depersonalizeInstallation(
                  'pushRegistrationId to depersonalize',
                );
              },
            ),
            ListTile(
              title: const Text('Set Installation as Primary'),
              onTap: () {
                InstallationPrimary installation = InstallationPrimary(
                  'pushRegistrationId to set as primary',
                  true,
                );
                InfobipMobilemessaging.setInstallationAsPrimary(installation);
              },
            ),
            ListTile(
              title: const Text('Show Library Events'),
              onTap: () {
                _showDialog('Library Events', _getLibraryEvents());
              },
            ),
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
                    'alEvent1Date': '2021-10-19',
                  },
                });
              },
            ),
            ListTile(
              title: const Text('Register Deeplink on Tap'),
              onTap: () {
                log('Tile "Register Deeplink on Tap" tapped');
                InfobipMobilemessaging.on(
                  'notificationTapped',
                  _handleDeeplinkEvent,
                );
              },
            ),
            ListTile(
              title: const Text('Unregister Deeplink on Tap'),
              onTap: () {
                log('Tile "Unregister Deeplink on Tap" tapped');
                InfobipMobilemessaging.unregister(
                  LibraryEvent.notificationTapped,
                  _handleDeeplinkEvent,
                );
              },
            ),
            ListTile(
              title: const Text('Unregister All Handlers'),
              onTap: () {
                log('Tile "Unregister All Handlers" tapped');
                InfobipMobilemessaging.unregisterAllHandlers(
                  'notificationTapped',
                );
              },
            ),
            ListTile(
              title: const Text('MessageStorage: findAll'),
              onTap: () async {
                var result = await _logAllMessages();
                _showDialog('Find All', result);
              },
            ),
            ListTile(
              title: const Text('MessageStorage: Find First Message'),
              onTap: _onFindFirstMessage,
            ),
            ListTile(
              title: const Text('MessageStorage: Delete First Message'),
              onTap: _onDeleteFirstMessage,
            ),
            ListTile(
              title: const Text('MessageStorage: deleteAll'),
              onTap: () async {
                await InfobipMobilemessaging.defaultMessageStorage()?.deleteAll();
                _showDialog('DeleteAll', 'All messages deleted');
              },
            ),
          ],
        ),
      );
}
