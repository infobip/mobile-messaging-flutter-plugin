//
//  default_message_storage.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/message.dart';
import 'message_storage.dart';

/// Default message storage implementation.
class DefaultMessageStorage extends MessageStorage {
  final MethodChannel _channel;

  /// Default constructor.
  DefaultMessageStorage(this._channel);

  @override
  delete(String messageId) async {
    await _channel.invokeMethod('defaultMessageStorage_delete', messageId);
  }

  @override
  deleteAll() async {
    await _channel.invokeMethod('defaultMessageStorage_deleteAll');
  }

  @override
  Future<Message?> find(String messageId) async => Message.fromJson(
        jsonDecode(
          await _channel.invokeMethod('defaultMessageStorage_find', messageId),
        ),
      );

  @override
  Future<List<Message>?> findAll() async {
    String result = await _channel.invokeMethod('defaultMessageStorage_findAll');
    Iterable l = json.decode(result);
    return List<Message>.from(l.map((model) => Message.fromJson(model)));
  }
}
