//
//  ios_chat_settings.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

@Deprecated('Use setChatCustomization instead')
class IOSChatSettings {
  final String? title;
  final String? sendButtonColor;
  final String? navigationBarItemsColor;
  final String? navigationBarColor;
  final String? navigationBarTitleColor;

  IOSChatSettings({
    this.title,
    this.sendButtonColor,
    this.navigationBarItemsColor,
    this.navigationBarColor,
    this.navigationBarTitleColor,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'sendButtonColor': sendButtonColor,
        'navigationBarItemsColor': navigationBarItemsColor,
        'navigationBarColor': navigationBarColor,
        'navigationBarTitleColor': navigationBarTitleColor,
      };
}
