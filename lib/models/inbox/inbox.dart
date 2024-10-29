import 'inbox_message.dart';

/// An [Inbox] class.
///
/// Has [countTotal] - total number of messages in [Inbox] for the user with `externalUserId`,
/// [countUnread] - total number of unread messages, and [messages] - List of [InboxMessage]
/// messages.
class Inbox {
  final List<InboxMessage>? messages;
  final int? countTotal;
  final int? countUnread;

  Inbox({
    this.messages,
    this.countTotal,
    this.countUnread,
  });

  static List<InboxMessage>? resolveLists(List<dynamic>? messages) {
    List<InboxMessage> inboxMessages = <InboxMessage>[];
    if (messages != null) {
      for (var message in messages) {
        inboxMessages.add(InboxMessage.fromJson(message));
      }
      return inboxMessages;
    }
    return null;
  }

  Inbox.fromJson(Map<String, dynamic> json)
      : countTotal = json['countTotal'],
        countUnread = json['countUnread'],
        messages = Inbox.resolveLists(json['messages']);
}
