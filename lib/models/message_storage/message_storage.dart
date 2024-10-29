import '../data/message.dart';

abstract class MessageStorage {
  Future<Message?> find(String messageId);

  Future<List<Message>?> findAll();

  delete(String messageId);

  deleteAll();
}
