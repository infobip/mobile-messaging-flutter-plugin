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
}
