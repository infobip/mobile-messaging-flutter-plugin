//   foreground_banner_configuration_test.dart
//   MobileMessagingFlutter
//
//   Copyright (c) 2016-2026 Infobip Limited
//   Licensed under the Apache License, Version 2.0
//

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/configurations/configuration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('infobip_mobilemessaging');
  final calls = <MethodCall>[];

  setUp(() {
    calls.clear();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  for (final enabled in <bool?>[true, false, null]) {
    test('init forwards foreground banner setting $enabled to Android', () async {
      await InfobipMobilemessaging.init(
        Configuration(
          applicationCode: 'test-application-code',
          androidSettings: AndroidSettings(
            withBannerForegroundNotificationsEnabled: enabled,
          ),
        ),
      );

      expect(calls, hasLength(1));
      expect(calls.single.method, 'init');
      final configuration = jsonDecode(calls.single.arguments as String);
      expect(
        configuration['androidSettings']['withBannerForegroundNotificationsEnabled'],
        enabled,
      );
    });
  }

  test('init continues to accept omitted Android settings', () async {
    await InfobipMobilemessaging.init(
      Configuration(applicationCode: 'test-application-code'),
    );

    expect(calls, hasLength(1));
    final configuration = jsonDecode(calls.single.arguments as String);
    expect(configuration['androidSettings'], isNull);
  });
}
