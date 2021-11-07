class Message {
  final String messageId;
  final String? title;
  final String? body;
  final String? sound;
  final bool? vibrate; // Android only
  final String? icon; // Android only
  final bool? silent;
  final String? category; // Android only
  final Map<String, dynamic>? customPayload;
  final String? internalData;
  final num? receivedTimestamp;
  final num? seenDate;
  final String? contentUrl;
  final bool? seen;
  final bool? geo;
  final Map<String, dynamic>? originalPayload; // iOS only
  final String? browserUrl;
  final String? deeplink;
  final String? webViewUrl;
  final String? inAppOpenTitle;
  final String? inAppDismissTitle;
  final bool? chat;

  Message(
      {required this.messageId,
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
      this.geo,
      this.originalPayload,
      this.vibrate,
      this.icon,
      this.category,
      this.browserUrl,
      this.deeplink,
      this.webViewUrl,
      this.inAppOpenTitle,
      this.inAppDismissTitle,
      this.chat});

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
        geo = json['geo'],
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
}
