import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:infobip_mobilemessaging/models/Installation.dart';
import 'package:infobip_mobilemessaging/models/PersonalizeContext.dart';
import 'package:infobip_mobilemessaging/models/UserData.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'models/Configuration.dart';
import 'models/IOSChatSettings.dart';
import 'models/LibraryEvent.dart';
import 'models/Message.dart';
import 'models/MessageStorage.dart';

class InfobipMobilemessaging {
  static const MethodChannel _channel =
      const MethodChannel('infobip_mobilemessaging');
  static const EventChannel _libraryEvent =
      const EventChannel('infobip_mobilemessaging/broadcast');
  static StreamSubscription _libraryEventSubscription =
      _libraryEvent.receiveBroadcastStream().listen((dynamic event) {
    print('Received event: $event');
    LibraryEvent libraryEvent = LibraryEvent.fromJson(jsonDecode(event));
    print("callbacks:");
    print(callbacks.toString());
    print("libraryEvent.eventName:");
    print(libraryEvent.eventName);
    if (callbacks.containsKey(libraryEvent.eventName)) {
      print("libraryEvent.eventName: " + libraryEvent.eventName);
      callbacks[libraryEvent.eventName]?.forEach((callback) {
        print("Try to call callback " + libraryEvent.eventName);
        if (libraryEvent.payload != null) {
          print(libraryEvent.payload);
        } else {
          print("Try to call with payload NULL");
        }
        if (libraryEvent.eventName == LibraryEvent.MESSAGE_RECEIVED ||
            libraryEvent.eventName == LibraryEvent.NOTIFICATION_TAPPED) {
          callback(Message.fromJson(libraryEvent.payload));
        } else if (libraryEvent.eventName ==
            LibraryEvent.INSTALLATION_UPDATED) {
          callback(Installation.fromJson(libraryEvent.payload).toString());
        } else if (libraryEvent.payload != null) {
          callback(libraryEvent.payload);
        } else {
          callback(libraryEvent.eventName);
        }
      });
    }
  }, onError: (dynamic error) {
    print('Received error: ${error.message}');
  }, cancelOnError: true);

  static Map<String, List<Function>?> callbacks = new HashMap();

  static Configuration? _configuration;

  static MessageStorage? _defaultMessageStorage;

  static Future<void> on(String eventName, Function callack) async {
    if (callbacks.containsKey(eventName)) {
      var existed = callbacks[eventName];
      existed?.add(callack);
      callbacks.update(eventName, (val) => existed);
    } else {
      callbacks.putIfAbsent(eventName, () => List.of([callack]));
    }
    _libraryEventSubscription.resume();
  }

  static Future<void> unregister(String eventName, Function? callack) async {
    if (callbacks.containsKey(eventName)){
      var existed = callbacks[eventName];
      existed?.remove(callack);
      callbacks.remove(eventName);
      callbacks.putIfAbsent(eventName, () => existed);
    }
    _libraryEventSubscription.resume();
  }

  static Future<void> unregisterAllHandlers(String eventName) async {
    if (callbacks.containsKey(eventName)){
      callbacks.removeWhere((key, value) => key == eventName);
    }
    _libraryEventSubscription.resume();
  }

  static Future<void> init(Configuration configuration) async {
    InfobipMobilemessaging._configuration = configuration;

    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    configuration.pluginVersion = packageInfo.version;
    await _channel.invokeMethod('init', jsonEncode(configuration.toJson()));
  }

  static Future<void> saveUser(UserData userData) async {
    await _channel.invokeMethod('saveUser', jsonEncode(userData.toJson()));
  }

  static Future<UserData> fetchUser() async {
    return UserData.fromJson(await _channel.invokeMethod('fetchUser'));
  }

  static Future<UserData> getUser() async {
    return UserData.fromJson(
        jsonDecode(await _channel.invokeMethod('getUser')));
  }

  static Future<void> saveInstallation(Installation installation) async {
    await _channel.invokeMethod(
        'saveInstallation', jsonEncode(installation.toJson()));
  }

  static Future<Installation> fetchInstallation() async {
    return Installation.fromJson(
        jsonDecode(await _channel.invokeMethod('fetchInstallation')));
  }

  static Future<Installation> getInstallation() async {
    return Installation.fromJson(
        jsonDecode(await _channel.invokeMethod('getInstallation')));
  }

  static Future<void> personalize(PersonalizeContext context) async {
    await _channel.invokeMethod('personalize', jsonEncode(context.toJson()));
  }

  static void depersonalize() async {
    await _channel.invokeMethod('depersonalize');
  }

  static void depersonalizeInstallation(String pushRegistrationId) async {
    await _channel.invokeMethod(
        'depersonalizeInstallation', pushRegistrationId);
  }

  static void setInstallationAsPrimary(
      InstallationPrimary installationPrimary) async {
    await _channel.invokeMethod(
        'setInstallationAsPrimary', installationPrimary.toJson());
  }

  static Future<void> showChat(
      {bool shouldBePresentedModallyIOS = false}) async {
    await _channel.invokeMethod('showChat', shouldBePresentedModallyIOS);
  }

  static Future<void> setupiOSChatSettings(IOSChatSettings settings) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod(
          'setupiOSChatSettings', jsonEncode(settings.toJson()));
    }
  }

  static void submitEvent(Object customEvent) {
    _channel.invokeMethod('submitEvent', jsonEncode(customEvent));
  }

  static void submitEventImmediately(Object customEvent) {
    _channel.invokeMethod('submitEventImmediately', jsonEncode(customEvent));
  }

  static Future<int> getMessageCounter() async {
    return await _channel.invokeMethod('getMessageCounter');
  }

  static void resetMessageCounter() async {
    await _channel.invokeMethod('resetMessageCounter');
  }

  static MessageStorage? defaultMessageStorage() {

    if (_configuration == null) {
      return null;
    }
    if (_configuration?.defaultMessageStorage == null) {
      return null;
    }
    if (_configuration?.defaultMessageStorage == false) {
      return null;
    }

    if (_defaultMessageStorage == null) {
      _defaultMessageStorage = new _DefaultMessageStorage();
    }

    return _defaultMessageStorage;
  }

}

class _DefaultMessageStorage extends MessageStorage {

  late MethodChannel _channel;

  constructor(MethodChannel channel ) {
    _channel = channel;
  }

  @override
  delete(String messageId) async {
    await _channel.invokeMethod('defaultMessageStorage_delete', messageId);
  }

  @override
  deleteAll() async {
    await _channel.invokeMethod('defaultMessageStorage_deleteAll');
  }

  @override
  Future<Message?> find(String messageId) async {
    return Message.fromJson(jsonDecode(await _channel.invokeMethod('defaultMessageStorage_find', messageId)));
  }

  @override
  Future<List<Message>?> findAll() async {
    String result = await _channel.invokeMethod('defaultMessageStorage_findAll');
    Iterable l = json.decode(result);
    return List<Message>.from(l.map((model)=> Message.fromJson(model)));
  }

}



