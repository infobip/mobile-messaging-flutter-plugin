//
//  widget_attachment_config.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

class WidgetAttachmentConfig {
  final int? maxSize;
  final bool? isEnabled;
  final Set<String>? allowedExtensions;

  WidgetAttachmentConfig({
    this.maxSize,
    this.isEnabled,
    this.allowedExtensions,
  });

  factory WidgetAttachmentConfig.fromJson(Map<String, dynamic> json) => WidgetAttachmentConfig(
        maxSize: json['maxSize'],
        isEnabled: json['isEnabled'],
        allowedExtensions: (json['allowedExtensions'] as List<dynamic>?)?.map((e) => e as String).toSet(),
      );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WidgetAttachmentConfig &&
          maxSize == other.maxSize &&
          isEnabled == other.isEnabled &&
          allowedExtensions == other.allowedExtensions;

  @override
  int get hashCode => maxSize.hashCode ^ isEnabled.hashCode ^ allowedExtensions.hashCode;

  @override
  String toString() => 'WidgetAttachmentConfig('
      'maxSize: $maxSize, '
      'isEnabled: $isEnabled, '
      'allowedExtensions: $allowedExtensions'
      ')';
}
