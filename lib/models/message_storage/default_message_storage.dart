import 'dart:convert';

import 'package:flutter/services.dart';

import '../data/message.dart';
import 'message_storage.dart';

class DefaultMessageStorage extends MessageStorage {
  final MethodChannel _channel;

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
    String result =
        await _channel.invokeMethod('defaultMessageStorage_findAll');
    Iterable l = json.decode(result);
    return List<Message>.from(l.map((model) => Message.fromJson(model)));
  }
}
