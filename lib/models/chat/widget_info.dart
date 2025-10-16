//
//  widget_info.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'widget_attachment_config.dart';

class WidgetInfo {
  final String? id;
  final String? title;
  final String? primaryColor;
  final String? backgroundColor;
  final String? primaryTextColor;
  final bool? multiThread;
  final bool? multiChannelConversationEnabled;
  final bool? callsEnabled;
  final List<String>? themeNames;
  final WidgetAttachmentConfig? attachmentConfig;

  WidgetInfo({
    this.id,
    this.title,
    this.primaryColor,
    this.backgroundColor,
    this.primaryTextColor,
    this.multiThread,
    this.multiChannelConversationEnabled,
    this.callsEnabled,
    this.themeNames,
    this.attachmentConfig,
  });

  WidgetInfo.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        title = json['title'],
        primaryColor = json['primaryColor'],
        backgroundColor = json['backgroundColor'],
        primaryTextColor = json['primaryTextColor'],
        multiThread = json['multiThread'],
        multiChannelConversationEnabled = json['multiChannelConversationEnabled'],
        callsEnabled = json['callsEnabled'],
        themeNames = json['themeNames'].cast<String>(),
        attachmentConfig =
            json['attachmentConfig'] != null ? WidgetAttachmentConfig.fromJson(json['attachmentConfig']) : null;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetInfo &&
          id == other.id &&
          title == other.title &&
          primaryColor == other.primaryColor &&
          backgroundColor == other.backgroundColor &&
          primaryTextColor == other.primaryTextColor &&
          multiThread == other.multiThread &&
          multiChannelConversationEnabled == other.multiChannelConversationEnabled &&
          callsEnabled == other.callsEnabled &&
          themeNames == other.themeNames &&
          attachmentConfig == other.attachmentConfig;

  @override
  int get hashCode =>
      id.hashCode ^
      title.hashCode ^
      primaryColor.hashCode ^
      backgroundColor.hashCode ^
      primaryTextColor.hashCode ^
      multiThread.hashCode ^
      multiChannelConversationEnabled.hashCode ^
      callsEnabled.hashCode ^
      themeNames.hashCode ^
      attachmentConfig.hashCode;

  @override
  String toString() => 'WidgetInfo('
      'id: $id, '
      'title: $title, '
      'primaryColor: $primaryColor, '
      'backgroundColor: $backgroundColor, '
      'primaryTextColor: $primaryTextColor, '
      'multiThread: $multiThread, '
      'multiChannelConversationEnabled: $multiChannelConversationEnabled, '
      'callsEnabled: $callsEnabled, '
      'themeNames: $themeNames, '
      'attachmentConfig: $attachmentConfig'
      ')';
}
