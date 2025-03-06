import 'package:flutter/foundation.dart';

/// A message stored in the inbox.
///
/// [InboxMessage] always has a special [topic], has [sentTimestamp] - milliseconds
/// from epoch in UTC, and [seen] status. To mark message as seen, use special
/// markMessagesSeen.
class InboxMessage {
  /// Id of the [InboxMessage].
  final String messageId;

  /// Topic of the message.
  final String topic;

  /// Boolean value if message is marked as seen.
  final bool seen;

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

  /// Link to the message content.
  final String? contentUrl;

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

  /// Optional message sent timestamp.
  final num? sentTimestamp;

  /// Default constructor with all params.
  InboxMessage({
    required this.messageId,
    required this.seen,
    required this.topic,
    this.title,
    this.body,
    this.sound,
    this.vibrate,
    this.icon,
    this.silent,
    this.category,
    this.customPayload,
    this.internalData,
    this.contentUrl,
    this.originalPayload,
    this.browserUrl,
    this.deeplink,
    this.webViewUrl,
    this.inAppOpenTitle,
    this.inAppDismissTitle,
    this.sentTimestamp,
  });

  /// Parsing InboxMessage from json.
  InboxMessage.fromJson(Map<String, dynamic> json)
      : messageId = json['messageId'],
        topic = json['inboxData'] != null ? json['inboxData']['inbox']['topic'] : json['topic'],
        seen = json['inboxData'] != null ? json['inboxData']['inbox']['seen'] : json['seen'],
        title = json['title'],
        body = json['body'],
        sound = json['sound'],
        vibrate = json['vibrate'],
        icon = json['icon'],
        silent = json['silent'],
        category = json['category'],
        customPayload = json['customPayload'],
        internalData = json['internalData'],
        contentUrl = json['contentUrl'],
        originalPayload = json['originalPayload'],
        browserUrl = json['browserUrl'],
        deeplink = json['deeplink'],
        webViewUrl = json['webViewUrl'],
        inAppOpenTitle = json['inAppOpenTitle'],
        inAppDismissTitle = json['inAppDismissTitle'],
        sentTimestamp = json['sentTimestamp'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InboxMessage &&
          runtimeType == other.runtimeType &&
          messageId == other.messageId &&
          seen == other.seen &&
          topic == other.topic &&
          title == other.title &&
          body == other.body &&
          sound == other.sound &&
          vibrate == other.vibrate &&
          icon == other.icon &&
          silent == other.silent &&
          category == other.category &&
          mapEquals(customPayload, other.customPayload) &&
          internalData == other.internalData &&
          contentUrl == other.contentUrl &&
          mapEquals(originalPayload, other.originalPayload) &&
          browserUrl == other.browserUrl &&
          deeplink == other.deeplink &&
          webViewUrl == other.webViewUrl &&
          inAppOpenTitle == other.inAppOpenTitle &&
          inAppDismissTitle == other.inAppDismissTitle &&
          sentTimestamp == other.sentTimestamp;

  @override
  int get hashCode =>
      messageId.hashCode ^
      seen.hashCode ^
      topic.hashCode ^
      title.hashCode ^
      body.hashCode ^
      sound.hashCode ^
      vibrate.hashCode ^
      icon.hashCode ^
      silent.hashCode ^
      category.hashCode ^
      customPayload.hashCode ^
      internalData.hashCode ^
      contentUrl.hashCode ^
      originalPayload.hashCode ^
      browserUrl.hashCode ^
      deeplink.hashCode ^
      webViewUrl.hashCode ^
      inAppOpenTitle.hashCode ^
      inAppDismissTitle.hashCode ^
      sentTimestamp.hashCode;
}
