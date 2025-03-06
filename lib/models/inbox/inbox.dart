import 'inbox_message.dart';

/// An [Inbox] class.
///
/// Has [countTotal] - total number of messages in [Inbox] for the user with `externalUserId`,
/// [countUnread] - total number of unread messages, and [messages] - List of [InboxMessage]
/// messages.
class Inbox {
  /// List of [InboxMessage] messages.
  final List<InboxMessage>? messages;

  /// Total number of [Inbox] messages for the user.
  final int? countTotal;

  /// Number of unread messages.
  final int? countUnread;

  /// Default constructor.
  Inbox({
    this.messages,
    this.countTotal,
    this.countUnread,
  });

  static List<InboxMessage>? _resolveLists(List<dynamic>? messages) {
    List<InboxMessage> inboxMessages = <InboxMessage>[];
    if (messages != null) {
      for (var message in messages) {
        inboxMessages.add(InboxMessage.fromJson(message));
      }
      return inboxMessages;
    }
    return null;
  }

  /// Resolving [Inbox] from json.
  Inbox.fromJson(Map<String, dynamic> json)
      : countTotal = json['countTotal'],
        countUnread = json['countUnread'],
        messages = Inbox._resolveLists(json['messages']);
}
