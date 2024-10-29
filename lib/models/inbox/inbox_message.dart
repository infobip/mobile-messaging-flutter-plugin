import 'package:flutter/foundation.dart';

/// A message stored in the inbox.
///
/// [InboxMessage] always has a special [topic], has [sentTimestamp] - milliseconds
/// from epoch in UTC, and [seen] status. To mark message as seen, use special
/// markMessagesSeen.
class InboxMessage {
  final String messageId;
  final String topic;
  final bool seen;
  final String? title;
  final String? body;
  final String? sound;
  final bool? vibrate; // Android only
  final String? icon; // Android only
  final bool? silent;
  final String? category; // Android only
  final Map<String, dynamic>? customPayload;
  final String? internalData;
  final String? contentUrl;
  final Map<String, dynamic>? originalPayload; // iOS only
  final String? browserUrl;
  final String? deeplink;
  final String? webViewUrl;
  final String? inAppOpenTitle;
  final String? inAppDismissTitle;
  final num? sentTimestamp;

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

  InboxMessage.fromJson(Map<String, dynamic> json)
      : messageId = json['messageId'],
        topic = json['inboxData'] != null
            ? json['inboxData']['inbox']['topic']
            : json['topic'],
        seen = json['inboxData'] != null
            ? json['inboxData']['inbox']['seen']
            : json['seen'],
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
