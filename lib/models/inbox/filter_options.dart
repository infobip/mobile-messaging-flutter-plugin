//
//  filter_options.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

/// [FilterOptions] for [Inbox].
/// Has [topic] - name of [Inbox] topic, will show all messages from all topics
/// if not provided. [limit] - number of messages to show, [fromDateTime] and [toDateTime].
class FilterOptions {
  /// Optional: DateTime from which Inbox messages to show.
  final DateTime? fromDateTime;

  /// Optional: DateTime to which Inbox messages to show, default is now.
  final DateTime? toDateTime;

  /// Topic of messages to show. Will show all if null.
  final String? topic;

  /// Limit of messages to show. Maximum stored amount is 100, default is 20.
  final int? limit;

  /// Creates a new class.
  FilterOptions({
    this.fromDateTime,
    this.toDateTime,
    this.topic,
    this.limit,
  });

  /// Mapping [FilterOptions] to json. Formats [fromDateTime] and [toDateTime] for native to process.
  Map<String, dynamic> toJson() => {
        'fromDateTime': fromDateTime != null ? '${fromDateTime?.toIso8601String().substring(0, 19)}Z' : null,
        'toDateTime': toDateTime != null ? '${toDateTime?.toIso8601String().substring(0, 19)}Z' : null,
        'topic': topic,
        'limit': limit,
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FilterOptions &&
          runtimeType == other.runtimeType &&
          fromDateTime == other.fromDateTime &&
          toDateTime == other.toDateTime &&
          topic == other.topic &&
          limit == other.limit;

  @override
  int get hashCode => fromDateTime.hashCode ^ toDateTime.hashCode ^ topic.hashCode ^ limit.hashCode;
}
