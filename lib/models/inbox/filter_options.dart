//
//  filter_options.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'package:collection/collection.dart';

/// [FilterOptions] for [Inbox].
/// Has [topic] - name of [Inbox] topic, [topics] - list of topic names,
/// will show all messages from all topics if not provided.
/// [topic] and [topics] are mutually exclusive — [topic] takes precedence
/// if both are set. [limit] - number of messages to show, [fromDateTime]
/// and [toDateTime]. [cursor] - [Inbox.nextCursor] of the previous page, to fetch the next page.
class FilterOptions {
  /// Optional: DateTime from which Inbox messages to show.
  final DateTime? fromDateTime;

  /// Optional: DateTime to which Inbox messages to show, default is now.
  final DateTime? toDateTime;

  /// Topic of messages to show. Will show all if null.
  /// Mutually exclusive with [topics] — has precedence if both are set.
  final String? topic;

  /// Topics of messages to show. Will show all if null.
  /// Mutually exclusive with [topic].
  final List<String>? topics;

  /// Limit of messages to show. Maximum stored amount is 100, default is 20.
  final int? limit;

  /// Optional: opaque pagination cursor, [Inbox.nextCursor] returned by the previous fetch.
  /// Null fetches the first page. Keep [topic], [fromDateTime] and [toDateTime] the same as
  /// for the previous page; [limit] may change. Not supported together with [topics].
  final String? cursor;

  /// Creates a new class.
  FilterOptions({
    this.fromDateTime,
    this.toDateTime,
    this.topic,
    this.topics,
    this.limit,
    this.cursor,
  });

  /// Mapping [FilterOptions] to json. Formats [fromDateTime] and [toDateTime] for native to process.
  /// [topic] and [topics] are mutually exclusive — if both are set, only [topic] is serialized.
  Map<String, dynamic> toJson() => {
        'fromDateTime': fromDateTime != null ? timeFormatter(fromDateTime!) : null,
        'toDateTime': toDateTime != null ? timeFormatter(toDateTime!) : null,
        if (topic != null) 'topic': topic,
        if (topic == null && topics != null && topics!.isNotEmpty) 'topics': topics,
        'limit': limit,
        'cursor': cursor,
      }..removeWhere((dynamic key, dynamic value) => value == null);

  String timeFormatter(DateTime datetime) => '${datetime.toIso8601String().substring(0, 19)}Z';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOptions &&
          runtimeType == other.runtimeType &&
          fromDateTime == other.fromDateTime &&
          toDateTime == other.toDateTime &&
          topic == other.topic &&
          const DeepCollectionEquality().equals(topics, other.topics) &&
          limit == other.limit &&
          cursor == other.cursor;

  @override
  int get hashCode =>
      fromDateTime.hashCode ^
      toDateTime.hashCode ^
      topic.hashCode ^
      const DeepCollectionEquality().hash(topics) ^
      limit.hashCode ^
      cursor.hashCode;
}
