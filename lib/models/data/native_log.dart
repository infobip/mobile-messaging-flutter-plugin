//
//  native_log.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

/// MobileMessaging [NativeLog] class.
class NativeLog {
  /// The content of the log message.
  final String message;

  /// Default constructor with all params.
  NativeLog({
    required this.message,
  });

  /// Parsing Message from json.
  NativeLog.fromJson(Map<String, dynamic> json)
      : message = json['message'];
}
