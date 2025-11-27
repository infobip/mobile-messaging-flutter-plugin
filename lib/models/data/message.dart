//
//  message.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'package:collection/collection.dart';

/// MobileMessaging [Message] class.
class Message {
  /// Id of the [Message].
  final String messageId;

  /// Optional message title.
  final String? title;

  /// Optional message body.
  final String? body;

  /// Optional message sound.
  final String? sound;

  /// Android only: vibrate for the message.
  final bool? vibrate;

  /// Android only: icon for the message.
  final String? icon;

  /// Optional: silent message flag.
  final bool? silent;

  /// Android only: category of the message.
  final String? category;

  /// Optional custom payload of the message.
  final Map<String, dynamic>? customPayload;

  /// Internal data.
  final String? internalData;

  /// Optional message received timestamp in millis from Epoch.
  final num? receivedTimestamp;

  /// Optional message seen timestamp in millis from Epoch.
  final num? seenDate;

  /// Link to the message content.
  final String? contentUrl;

  /// Optional flag if message was marked as seen.
  final bool? seen;

  /// iOS only: original APNS payload.
  final Map<String, dynamic>? originalPayload;

  /// Optional url to open in browser.
  final String? browserUrl;

  /// Optional deeplink.
  final String? deeplink;

  /// Optional url to open in webView.
  final String? webViewUrl;

  /// Optional in-app message: title for open action.
  final String? inAppOpenTitle;

  /// Optional in-app message: title for cancel/dismiss action.
  final String? inAppDismissTitle;

  /// Optional flag is message for LiveChat.
  final bool? chat;

  /// Default constructor with all params.
  Message({
    required this.messageId,
    this.title,
    this.body,
    this.sound,
    this.silent,
    this.customPayload,
    this.internalData,
    this.receivedTimestamp,
    this.seenDate,
    this.contentUrl,
    this.seen,
    this.originalPayload,
    this.vibrate,
    this.icon,
    this.category,
    this.browserUrl,
    this.deeplink,
    this.webViewUrl,
    this.inAppOpenTitle,
    this.inAppDismissTitle,
    this.chat,
  });

  /// Parsing Message from json.
  Message.fromJson(Map<String, dynamic> json)
      : messageId = json['messageId'],
        title = json['title'],
        body = json['body'],
        sound = json['sound'],
        silent = json['silent'],
        customPayload = json['customPayload'],
        internalData = json['internalData'],
        receivedTimestamp = json['receivedTimestamp'],
        seenDate = json['seenDate'],
        contentUrl = json['contentUrl'],
        seen = json['seen'],
        originalPayload = json['originalPayload'],
        vibrate = json['vibrate'],
        icon = json['icon'],
        category = json['category'],
        browserUrl = json['browserUrl'],
        deeplink = json['deeplink'],
        webViewUrl = json['webViewUrl'],
        inAppOpenTitle = json['inAppOpenTitle'],
        inAppDismissTitle = json['inAppDismissTitle'],
        chat = json['chat'];

  static const MapEquality<String, dynamic> _mapEquality = MapEquality<String, dynamic>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Message &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId &&
          title == other.title &&
          body == other.body &&
          sound == other.sound &&
          vibrate == other.vibrate &&
          icon == other.icon &&
          silent == other.silent &&
          category == other.category &&
          _mapEquality.equals(customPayload, other.customPayload) &&
          internalData == other.internalData &&
          receivedTimestamp == other.receivedTimestamp &&
          seenDate == other.seenDate &&
          contentUrl == other.contentUrl &&
          seen == other.seen &&
          _mapEquality.equals(originalPayload, other.originalPayload) &&
          browserUrl == other.browserUrl &&
          deeplink == other.deeplink &&
          webViewUrl == other.webViewUrl &&
          inAppOpenTitle == other.inAppOpenTitle &&
          inAppDismissTitle == other.inAppDismissTitle &&
          chat == other.chat;

  @override
  int get hashCode =>
      messageId.hashCode ^
      title.hashCode ^
      body.hashCode ^
      sound.hashCode ^
      vibrate.hashCode ^
      icon.hashCode ^
      silent.hashCode ^
      category.hashCode ^
      _mapEquality.hash(customPayload) ^
      internalData.hashCode ^
      receivedTimestamp.hashCode ^
      seenDate.hashCode ^
      contentUrl.hashCode ^
      seen.hashCode ^
      _mapEquality.hash(originalPayload) ^
      browserUrl.hashCode ^
      deeplink.hashCode ^
      webViewUrl.hashCode ^
      inAppOpenTitle.hashCode ^
      inAppDismissTitle.hashCode ^
      chat.hashCode;
}
