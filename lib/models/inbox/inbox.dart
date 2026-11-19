//
//  inbox.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'package:collection/collection.dart';

import 'inbox_message.dart';

/// An [Inbox] class.
///
/// Has [countTotal] - total number of messages in [Inbox] for the user with `externalUserId`,
/// [countUnread] - total number of unread messages, [countTotalFiltered] - total number of
/// messages after applying filter, [countUnreadFiltered] - number of unread messages after
/// applying filter, [messages] - List of [InboxMessage] messages, and [nextCursor] - cursor
/// for fetching the next page.
class Inbox {
  /// List of [InboxMessage] messages.
  final List<InboxMessage>? messages;

  /// Total number of [Inbox] messages for the user.
  final int? countTotal;

  /// Number of unread messages.
  final int? countUnread;

  /// Number of messages after filtering.
  final int? countTotalFiltered;

  /// Number of unread messages after filtering.
  final int? countUnreadFiltered;

  /// Opaque cursor for fetching the next page, pass it as [FilterOptions.cursor].
  /// Null when no further page is available from this request: either this is the last page,
  /// or pagination isn't available (for example when filtering by a nonempty `topics` list,
  /// even with a single topic, or with a `limit` of 0).
  final String? nextCursor;

  /// Default constructor.
  Inbox({
    this.messages,
    this.countTotal,
    this.countUnread,
    this.countTotalFiltered,
    this.countUnreadFiltered,
    this.nextCursor,
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
        countTotalFiltered = json['countTotalFiltered'],
        countUnreadFiltered = json['countUnreadFiltered'],
        nextCursor = json['nextCursor'],
        messages = Inbox._resolveLists(json['messages']);

  static const DeepCollectionEquality _deepCollectionEquality = DeepCollectionEquality();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Inbox &&
          runtimeType == other.runtimeType &&
          _deepCollectionEquality.equals(messages, other.messages) &&
          countTotal == other.countTotal &&
          countUnread == other.countUnread &&
          countTotalFiltered == other.countTotalFiltered &&
          countUnreadFiltered == other.countUnreadFiltered &&
          nextCursor == other.nextCursor;

  @override
  int get hashCode =>
      _deepCollectionEquality.hash(messages) ^
      countTotal.hashCode ^
      countUnread.hashCode ^
      countTotalFiltered.hashCode ^
      countUnreadFiltered.hashCode ^
      nextCursor.hashCode;
}
