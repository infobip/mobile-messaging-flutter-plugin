import 'package:infobip_mobilemessaging/models/message.dart';

class InboxMessage extends Message {
  final String? topic;
  final bool? seen;

  InboxMessage({
    required super.messageId,
    super.title,
    super.body,
    super.sound,
    super.silent,
    super.customPayload,
    super.internalData,
    super.receivedTimestamp,
    super.seenDate,
    super.contentUrl,
    super.originalPayload,
    super.vibrate,
    super.icon,
    super.category,
    super.browserUrl,
    super.deeplink,
    super.webViewUrl,
    super.inAppOpenTitle,
    super.inAppDismissTitle,
    this.seen,
    this.topic,
  });

  InboxMessage.fromJson(Map<String, dynamic> json)
      : topic = json['inboxData'] != null
            ? json['inboxData']['inbox']['topic']
            : json['topic'],
        seen = json['inboxData'] != null
            ? json['inboxData']['inbox']['seen']
            : json['seen'],
        super.fromJson(json);
}
