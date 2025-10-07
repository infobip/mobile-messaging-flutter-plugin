//
//  chat_exception.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

class ChatException {
    final String? message;
    final int? code;
    final String? name;
    final String? origin;
    final String? platform;

  ChatException({
    this.message,
    this.code,
    this.name,
    this.origin,
    this.platform,
  });

  ChatException.fromJson(Map<String, dynamic> json)
      : message = json['message'],
        code = json['code'],
        name = json['name'],
        origin = json['origin'],
        platform = json['platform'];
        
  @override
  String toString() => 'ChatException(message: $message, code: $code, name: $name, origin: $origin, platform: $platform)';
}
