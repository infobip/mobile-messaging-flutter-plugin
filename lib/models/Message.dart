
class Message {
  final String messageId;
  final String? title;
  final String? body;
  final String? sound;
  final bool? boolean;
  final Map<String, dynamic>? customPayload;
  final String? internalData;
  final num? receivedTimestamp;
  final num? seenDate;
  final String? contentUrl;
  final bool? seen;
  final bool? geo;
  final Map<String, dynamic>? originalPayload; // iOS only
  final bool? vibrate; // Android only
  final String? icon; // Android only
  final String? category; // Android only
  final String? browserUrl;
  final String? deeplink;
  final String? webViewUrl;
  final String? inAppDismissTitle;

  Message({
    required this.messageId,
    this.title,
    this.body,
    this.sound,
    this.boolean,
    this.customPayload,
    this.internalData,
    this.receivedTimestamp,
    this.seenDate,
    this.contentUrl,
    this.seen,
    this.geo,
    this.originalPayload,
    this.vibrate,
    this.icon,
    this.category,
    this.browserUrl,
    this.deeplink,
    this.webViewUrl,
    this.inAppDismissTitle
  });

  Message.fromJson(Map<String, dynamic> json)
      : messageId = json['messageId'],
        title = json['title'],
        body = json['body'],
        sound = json['sound'],
        boolean = json['boolean'],
        customPayload = json['customPayload'],
        internalData = json['internalData'],
        receivedTimestamp = json['receivedTimestamp'],
        seenDate = json['seenDate'],
        contentUrl = json['contentUrl'],
        seen = json['seen'],
        geo = json['geo'],
        originalPayload = json['originalPayload'],
        vibrate = json['vibrate'],
        icon = json['icon'],
        category = json['category'],
        browserUrl = json['browserUrl'],
        deeplink = json['deeplink'],
        webViewUrl = json['webViewUrl'],
        inAppDismissTitle = json['inAppDismissTitle'];
}