class WidgetInfo {
  final String? id;
  final String? title;
  final String? primaryColor;
  final String? backgroundColor;
  final num? maxUploadContentSize;
  final bool? multiThread;
  final bool? multiChannelConversationEnabled;
  final bool? callsEnabled;
  final List<String>? themeNames;

  WidgetInfo({
    this.id,
    this.title,
    this.primaryColor,
    this.backgroundColor,
    this.maxUploadContentSize,
    this.multiThread,
    this.multiChannelConversationEnabled,
    this.callsEnabled,
    this.themeNames,
  });

  WidgetInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        primaryColor = json['primaryColor'],
        backgroundColor = json['backgroundColor'],
        maxUploadContentSize = json['maxUploadContentSize'],
        multiThread = json['multiThread'],
        multiChannelConversationEnabled = json['multiChannelConversationEnabled'],
        callsEnabled = json['callsEnabled'],
        themeNames = json['themeNames'].cast<String>();

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetInfo &&
          id == other.id &&
          title == other.title &&
          primaryColor == other.primaryColor &&
          backgroundColor == other.backgroundColor &&
          maxUploadContentSize == other.maxUploadContentSize &&
          multiThread == other.multiThread &&
          multiChannelConversationEnabled == other.multiChannelConversationEnabled &&
          callsEnabled == other.callsEnabled &&
          themeNames == other.themeNames;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      primaryColor.hashCode ^
      backgroundColor.hashCode ^
      maxUploadContentSize.hashCode ^
      multiThread.hashCode ^
      multiChannelConversationEnabled.hashCode ^
      callsEnabled.hashCode ^
      themeNames.hashCode;
}
