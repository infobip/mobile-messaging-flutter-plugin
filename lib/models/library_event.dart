//
//  library_event.dart
//  YourFlutterPluginName
//
// Copyright (c) 2016-2025 Infobip Limited
// Licensed under the Apache License, Version 2.0
//
/// Mobile Messaging plugin events.
class LibraryEvent {
  /// Event's name.
  final String eventName;

  /// Event's payload.
  final dynamic payload;

  /// Occurs when an APNs device token is received. Contains device token - a
  /// hex-encoded string received from APNS. Returns device token as hex-encoded string.
  static const String tokenReceived = 'tokenReceived';

  /// Occurs when the registration is updated on backend server. Returns internalId - string for the registered user.
  static const String registrationUpdated = 'registrationUpdated';

  /// Occurs when save request to the server is successfully sent.
  static const String installationUpdated = 'installationUpdated';

  /// Occurs when save request to the server is successfully sent.
  static const String userUpdated = 'userUpdated';

  /// Occurs when request for personalization is successfully sent to the server.
  static const String personalized = 'personalized';

  /// Occurs when request for depersonalization is successfully sent to the server.
  static const String depersonalized = 'depersonalized';

  /// Occurs when notification is tapped.
  static const String notificationTapped = 'notificationTapped';

  /// Occurs when user taps on action inside notification or enters text as part of the notification response.
  static const String actionTapped = 'actionTapped';

  /// Occurs when new message arrives, see separate section for all available message fields
  static const String messageReceived = 'messageReceived';

  /// Occurs when in-app chat counter is updated.
  static const String unreadMessageCounterUpdated = 'inAppChat.unreadMessageCounterUpdated';

  /// Occurs when in-app chat view is changed.
  static const String chatViewStateChanged = 'inAppChat.viewStateChanged';

  /// Occurs when in-app chat configuration is synced.
  static const String chatConfigurationSynced = 'inAppChat.configurationSynced';

  /// Occurs when livechat registration id is updated.
  static const String chatLivechatRegistrationIdUpdated = 'inAppChat.livechatRegistrationIdUpdated';

  /// Occurs when the connection has been established successfully and chat can be presented
  static const String chatAvailabilityUpdated = 'inAppChat.availabilityUpdated';

  /// Default class constructor.
  LibraryEvent({
    required this.eventName,
    this.payload,
  });

  /// Getting library event name and payload from received json.
  factory LibraryEvent.fromJson(Map<String, dynamic> json) => LibraryEvent(
        eventName: json['eventName'] as String,
        payload: (json['payload'] != null) ? json['payload'] as dynamic : null,
      );
}
