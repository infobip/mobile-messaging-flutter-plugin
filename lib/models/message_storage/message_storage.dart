//
//  message_storage.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import '../data/message.dart';

/// Abstract message storage class.
abstract class MessageStorage {
  /// Finds a Message by its messageId.
  Future<Message?> find(String messageId);

  /// Finds all stored messages.
  Future<List<Message>?> findAll();

  /// Deletes message with given messageId.
  Future<void> delete(String messageId);

  /// Deletes all messages.
  Future<void> deleteAll();
}
