//
//  chat_view_attachment.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

class ChatViewAttachment {
  final String? url;
  final String? type;
  final String? caption;

  ChatViewAttachment({
    this.url,
    this.type,
    this.caption,
  });

  ChatViewAttachment.fromJson(Map<String, dynamic> json)
      : url = json['url'],
        type = json['type'],
        caption = json['caption'];

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatViewAttachment && url == other.url && type == other.type && caption == other.caption;

  @override
  int get hashCode => url.hashCode ^ type.hashCode ^ caption.hashCode;
}
