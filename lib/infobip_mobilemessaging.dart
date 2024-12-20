import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:infobip_mobilemessaging/models/inbox/filter_options.dart';
import 'package:infobip_mobilemessaging/models/inbox/inbox.dart';

import 'models/chat/ios_chat_settings.dart';
import 'models/configurations/configuration.dart';
import 'models/data/installation.dart';
import 'models/data/message.dart';
import 'models/data/personalize_context.dart';
import 'models/data/user_data.dart';
import 'models/library_event.dart';
import 'models/message_storage/default_message_storage.dart';
import 'models/message_storage/message_storage.dart';

enum ChatMultithreadStrategies { 
  all, allPlusNew, active;

    String get stringValue {
    switch (this) {
      case ChatMultithreadStrategies.all:
        return 'ALL';
      case ChatMultithreadStrategies.allPlusNew:
        return 'ALL_PLUS_NEW';
      case ChatMultithreadStrategies.active:
        return 'ACTIVE';
    }
  }
}

class InfobipMobilemessaging {
  static const MethodChannel _channel =
      MethodChannel('infobip_mobilemessaging');
  static const EventChannel _libraryEvent =
      EventChannel('infobip_mobilemessaging/broadcast');
  static final StreamSubscription _libraryEventSubscription =
      _libraryEvent.receiveBroadcastStream().listen((dynamic event) {
    log('Received event: $event');
    LibraryEvent libraryEvent = LibraryEvent.fromJson(jsonDecode(event));
    if (callbacks.containsKey(libraryEvent.eventName)) {
      callbacks[libraryEvent.eventName]?.forEach((callback) {
        log('Calling ${libraryEvent.eventName} with payload ${libraryEvent.payload == null ? 'NULL' : libraryEvent.payload.toString()}');
        if (libraryEvent.eventName == LibraryEvent.messageReceived ||
            libraryEvent.eventName == LibraryEvent.notificationTapped) {
          callback(Message.fromJson(libraryEvent.payload));
        } else if (libraryEvent.eventName == LibraryEvent.installationUpdated) {
          callback(Installation.fromJson(libraryEvent.payload).toString());
        } else if (libraryEvent.eventName == LibraryEvent.userUpdated) {
          callback(UserData.fromJson(libraryEvent.payload));
        } else if (libraryEvent.payload != null) {
          callback(libraryEvent.payload);
        } else {
          callback(libraryEvent.eventName);
        }
      });
    }
  }, onError: (dynamic error) {
    log('Received error: ${error.message}');
  }, cancelOnError: true);

  static Map<String, List<Function>?> callbacks = HashMap();

  static Configuration? _configuration;

  static MessageStorage? _defaultMessageStorage;

  /// Subscribes to [LibraryEvent] to perform provided callback function.
  static Future<void> on(String eventName, Function callback) async {
    if (callbacks.containsKey(eventName)) {
      var existed = callbacks[eventName];
      existed?.add(callback);
      callbacks.update(eventName, (val) => existed);
    } else {
      callbacks.putIfAbsent(eventName, () => List.of([callback]));
    }
    _libraryEventSubscription.resume();
  }

  /// Unregisters handler from [LibraryEvent].
  static Future<void> unregister(String eventName, Function? callback) async {
    if (callbacks.containsKey(eventName)) {
      var existed = callbacks[eventName];
      existed?.remove(callback);
      callbacks.remove(eventName);
      callbacks.putIfAbsent(eventName, () => existed);
    }
    _libraryEventSubscription.resume();
  }

  /// Unsubscribes all handlers from given [LibraryEvent].
  static Future<void> unregisterAllHandlers(String eventName) async {
    if (callbacks.containsKey(eventName)) {
      callbacks.removeWhere((key, value) => key == eventName);
    }
    _libraryEventSubscription.resume();
  }

  /// Initializes MobileMessaging plugin with [Configuration].
  static Future<void> init(Configuration configuration) async {
    InfobipMobilemessaging._configuration = configuration;
    String str = await _getVersion();
    configuration.pluginVersion = str;

    await _channel.invokeMethod('init', jsonEncode(configuration.toJson()));
  }

  /// Saves [UserData] to server.
  static Future<void> saveUser(UserData userData) async {
    await _channel.invokeMethod('saveUser', jsonEncode(userData.toJson()));
  }

  /// Asynchronously fetches [UserData] from server.
  static Future<UserData> fetchUser() async =>
      UserData.fromJson(jsonDecode(await _channel.invokeMethod('fetchUser')));

  /// Asynchronously gets [UserData] from local data.
  static Future<UserData> getUser() async =>
      UserData.fromJson(jsonDecode(await _channel.invokeMethod('getUser')));

  /// Asynchronously saves [Installation] data to server.
  static Future<void> saveInstallation(Installation installation) async {
    await _channel.invokeMethod(
      'saveInstallation',
      jsonEncode(installation.toJson()),
    );
  }

  /// Asynchronously fetches [Installation] from server.
  static Future<Installation> fetchInstallation() async =>
      Installation.fromJson(
          jsonDecode(await _channel.invokeMethod('fetchInstallation')));

  /// Asynchronously gets [Installation] data from local data.
  static Future<Installation> getInstallation() async => Installation.fromJson(
      jsonDecode(await _channel.invokeMethod('getInstallation')));

  /// Asynchronously personalizes current [Installation] with a Person profile on the server.
  /// For more information and examples see: <a href=https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Users-and-installations>Users and installations</a>
  static Future<void> personalize(PersonalizeContext context) async {
    await _channel.invokeMethod('personalize', jsonEncode(context.toJson()));
  }

  /// Asynchronously erases currently stored `User` on SDK and server associated
  /// with push registration, along with messages in SDK storage (also, deletes
  /// data for chat module).
  static void depersonalize() async {
    await _channel.invokeMethod('depersonalize');
  }

  /// Asynchronously cleans up all persisted data.
  /// This method deletes SDK data related to current application code (also,
  /// deletes data for other modules: interactive, chat).
  /// There might be a situation where you'll want to switch between different
  /// Application Codes during development/testing, in this case you should
  /// manually invoke [cleanup]. After cleanup, you should call [init] with a
  /// new Application Code in order to use library again.
  static Future<void> cleanup() async {
    await _channel.invokeMethod('cleanup');
  }

  /// Asynchronously depersonalizes given `pushRegistrationId` from user.
  static void depersonalizeInstallation(String pushRegistrationId) async {
    await _channel.invokeMethod(
        'depersonalizeInstallation', pushRegistrationId);
  }

  /// Asynchronously configures provided device as primary among others devices
  /// of a single user. Will return list of installations only when list changes:
  /// if current installation is set as primary or already a primary one, will return null.
  static Future<List<Installation>?> setInstallationAsPrimary(
      InstallationPrimary installationPrimary) async {
    String str = await _channel.invokeMethod(
      'setInstallationAsPrimary',
      installationPrimary.toJson(),
    );
    if (str != 'Success') {
      Iterable l = json.decode(str);
      return List<Installation>.from(
          l.map((model) => Installation.fromJson(model)));
    }
    return null;
  }

  /// Shows chat screen.
  static Future<void> showChat(
      {bool shouldBePresentedModallyIOS = true}) async {
    await _channel.invokeMethod('showChat', shouldBePresentedModallyIOS);
  }

  /// Sets chat customization.
  static Future<void> setChatCustomization(Object settings) async {
    await _channel.invokeMethod('setChatCustomization', jsonEncode(settings));
  }

  @deprecated
  static Future<void> setupiOSChatSettings(IOSChatSettings settings) async {
    if (Platform.isIOS) {
      await _channel.invokeMethod(
          'setupiOSChatSettings', jsonEncode(settings.toJson()));
    }
  }

  /// Synchronously submits custom event and validates it on backend. Custom
  /// event should be registered by definition ID and optional properties in <a href=https://portal.infobip.com/people/events/definitions>Portal</a>.
  /// In case of validation or network issues error will be returned and you'd
  /// need to manually retry sending of the event.
  static void submitEvent(Object customEvent) {
    _channel.invokeMethod('submitEvent', jsonEncode(customEvent));
  }

  /// Asynchronously submits custom events without validation. Custom event
  /// should be registered by definition ID and optional properties in in <a href=https://portal.infobip.com/people/events/definitions>Portal</a>.
  /// Validation will not be performed. If wrong definition is provided event
  /// will be considered as invalid and won't be visible on user.
  static void submitEventImmediately(Object customEvent) {
    _channel.invokeMethod('submitEventImmediately', jsonEncode(customEvent));
  }

  /// Returns current unread chat push message counter.
  static Future<int> getMessageCounter() async =>
      await _channel.invokeMethod('getMessageCounter');

  /// Resets current unread chat push message counter to zero.
  /// MobileMessaging automatically resets the counter when chat is opened.
  static void resetMessageCounter() async {
    await _channel.invokeMethod('resetMessageCounter');
  }

  /// Sets the language of the widget, in locale format e.g.: `en-US`
  static void setLanguage(String language) async {
    await _channel.invokeMethod('setLanguage', language);
  }

  /// Sets the theme of the Livechat widget.
  static setWidgetTheme(String widgetTheme) async {
    await _channel.invokeMethod('setWidgetTheme', widgetTheme);
  }

  /// Sends contextual data of the Livechat Widget.
  @deprecated
  static void sendContextualData(
      String data, bool allMultiThreadStrategy
  ) async {
    InfobipMobilemessaging.sendContextualDataWithStrategy(
      data, 
      allMultiThreadStrategy ? ChatMultithreadStrategies.all : ChatMultithreadStrategies.active
    );
  }

  /// Sends contextual data of the Livechat Widget.
  static void sendContextualDataWithStrategy(
    String data, [ChatMultithreadStrategies chatMultithreadStrategy = ChatMultithreadStrategies.active]
  ) async {
    await _channel.invokeMethod('sendContextualData', 
      {'data': data, 'chatMultiThreadStrategy': chatMultithreadStrategy.stringValue }
    );
  }

  /// Sets JWT for Livechat.
  static void setJwt(String jwt) async {
    await _channel.invokeMethod('setJwt', jwt);
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

    _defaultMessageStorage ??= DefaultMessageStorage(_channel);

    return _defaultMessageStorage;
  }

  /// Shows dialog to user to receive push notifications on Android devices.
  static Future<void> registerForAndroidRemoteNotifications() async {
    if (Platform.isIOS) {
      log("It's not supported on the iOS platform");
      return;
    }

    await _channel.invokeMethod('registerForAndroidRemoteNotifications');
  }

  /// Shows dialog to user to receive push notifications on iOS devices.
  static Future<void> registerForRemoteNotifications() async {
    if (!Platform.isIOS) {
      log("It's supported only on the iOS platform");
      return;
    }

    await _channel.invokeMethod('registerForRemoteNotifications');
  }

  static Future<void> enableCalls(String identity) async {
    await _channel.invokeMethod('enableCalls', identity);
  }

  static Future<void> enableChatCalls() async {
    await _channel.invokeMethod('enableChatCalls');
  }

  static Future<void> disableCalls() async {
    await _channel.invokeMethod('disableCalls');
  }

  static Future<void> restartConnection() async {
    if (!Platform.isIOS) {
      log("It's supported only on the iOS platform");
      return;
    }
    await _channel.invokeMethod('restartConnection');
  }

  static Future<void> stopConnection() async {
    if (!Platform.isIOS) {
      log("It's supported only on the iOS platform");
      return;
    }
    await _channel.invokeMethod('stopConnection');
  }

  /// Fetches messages from Inbox.
  /// Requires `token`, `externalUserId`, and [FilterOptions].
  ///
  /// Example:
  /// ```dart
  /// var inbox = await fetchInboxMessages('jwtToken', 'yourId', FilterOptions());
  static Future<Inbox> fetchInboxMessages(
      String token, String externalUserId, FilterOptions filterOptions) async {
    return Inbox.fromJson(jsonDecode(await _channel.invokeMethod(
      'fetchInboxMessages',
      {
        'token': token,
        'externalUserId': externalUserId,
        'filterOptions': jsonEncode(filterOptions.toJson()),
      },
    )));
  }

  /// Fetches messages from [Inbox] without token - recommended only for sandbox
  /// applications. For production apps use [fetchInboxMessages] with token.
  /// Requires `externalUserId`, and [FilterOptions].
  ///
  /// Example:
  /// ```dart
  /// var inbox = await fetchInboxMessagesWithoutToken('yourId', FilterOptions());
  static Future<Inbox> fetchInboxMessagesWithoutToken(
      String externalUserId, FilterOptions filterOptions) async {
    return Inbox.fromJson(jsonDecode(await _channel.invokeMethod(
      'fetchInboxMessagesWithoutToken',
      {
        'externalUserId': externalUserId,
        'filterOptions': jsonEncode(filterOptions.toJson()),
      },
    )));
  }

  /// Sets [Inbox] messages as seen.
  /// Requires externalUserId and List of IDs of messages to be marked as seen.
  static Future<void> setInboxMessagesSeen(
      String externalUserId, List<String> messageIds) async {
    await _channel.invokeMethod(
      'setInboxMessagesSeen',
      {
        'externalUserId': externalUserId,
        'messageIds': messageIds,
      },
    );
  }

  static Future<void> markMessagesSeen(List<String> messageIds) async {
    await _channel.invokeMethod('markMessagesSeen', messageIds);
  }

  /// Sets title for in-app chat notifications and overrides default values.
  /// Supported only on Android.
  static void setChatPushTitle(String? title) async {
    if (!Platform.isAndroid) {
      log("It's supported only on the Android platform");
      return;
    }
    await _channel.invokeMethod('setChatPushTitle', title);
  }

  /// Sets body for in-app chat notifications and overrides default values.
  /// Supported only on Android.
  static void setChatPushBody(String? body) async {
    if (!Platform.isAndroid) {
      log("It's supported only on the Android platform");
      return;
    }
    await _channel.invokeMethod('setChatPushBody', body);
  }

  /// Used by MobileMessaging plugin to get plugin's version.
  static Future<String> _getVersion() async {
    final fileContent = await rootBundle.loadString(
      'packages/infobip_mobilemessaging/pubspec.yaml',
    );

    if (fileContent.isNotEmpty) {
      String versionStr = fileContent.substring(
          fileContent.indexOf('version:'), fileContent.indexOf('\nhomepage:'));
      versionStr = versionStr.substring(9, versionStr.length);
      return versionStr.trim();
    }
    return '';
  }
}
