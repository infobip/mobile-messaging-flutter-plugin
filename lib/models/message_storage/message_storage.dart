import '../data/message.dart';

/// Abstract message storage class.
abstract class MessageStorage {
  /// Finds a Message by its messageId.
  Future<Message?> find(String messageId);

  /// Finds all stored messages.
  Future<List<Message>?> findAll();

  /// Deletes message with given messageId.
  delete(String messageId);

  /// Deletes all messages.
  deleteAll();
}
