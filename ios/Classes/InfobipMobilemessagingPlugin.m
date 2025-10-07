//
//  InfobipMobilemessagingPlugin.m
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

#import "InfobipMobilemessagingPlugin.h"
#if __has_include(<infobip_mobilemessaging/infobip_mobilemessaging-Swift.h>)
#import <infobip_mobilemessaging/infobip_mobilemessaging-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "infobip_mobilemessaging-Swift.h"
#endif

@implementation InfobipMobilemessagingPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftInfobipMobilemessagingPlugin registerWithRegistrar:registrar];
}
@end
