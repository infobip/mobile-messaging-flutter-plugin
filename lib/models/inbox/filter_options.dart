/// [FilterOptions] for [Inbox].
/// Has [topic] - name of [Inbox] topic, will show all messages from all topics
/// if not provided. [limit] - number of messages to show, [fromDateTime] and [toDateTime].
class FilterOptions {
  final DateTime? fromDateTime;
  final DateTime? toDateTime;
  final String? topic;
  final int? limit;

  FilterOptions({
    this.fromDateTime,
    this.toDateTime,
    this.topic,
    this.limit,
  });

  Map<String, dynamic> toJson() => {
        'fromDateTime': fromDateTime != null
            ? '${fromDateTime?.toIso8601String().substring(0, 19)}Z'
            : null,
        'toDateTime': toDateTime != null
            ? '${toDateTime?.toIso8601String().substring(0, 19)}Z'
            : null,
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
  int get hashCode =>
      fromDateTime.hashCode ^
      toDateTime.hashCode ^
      topic.hashCode ^
      limit.hashCode;
}
