// Copyright (c) 2016-2026 Infobip Limited
// Licensed under the Apache License, Version 2.0

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
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, (call) async {
      calls.add(call);
      return null;
    });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(channel, null);
  });

  // Checking the init payload covers AndroidSettings and Configuration
  // serialization as well as forwarding to the native channel.
  final cases = [
    ('true', AndroidSettings(appManagedFcmTokenLifecycle: true), true),
    ('false', AndroidSettings(appManagedFcmTokenLifecycle: false), false),
    ('omitted', AndroidSettings(), null),
  ];

  group('init forwards appManagedFcmTokenLifecycle', () {
    for (final (description, settings, expected) in cases) {
      test(description, () async {
        await InfobipMobilemessaging.init(
          Configuration(applicationCode: 'test-code', androidSettings: settings),
        );

        expect(calls, hasLength(1));
        expect(calls.single.method, 'init');
        final json = jsonDecode(calls.single.arguments as String) as Map<String, dynamic>;
        expect(json['androidSettings'], containsPair('appManagedFcmTokenLifecycle', expected));
      });
    }

    test('allows missing Android settings', () async {
      await InfobipMobilemessaging.init(Configuration(applicationCode: 'test-code'));

      expect(calls, hasLength(1));
      expect(calls.single.method, 'init');
      final json = jsonDecode(calls.single.arguments as String) as Map<String, dynamic>;
      expect(json, containsPair('androidSettings', null));
    });
  });

  group('Configuration.trustedDomains', () {
    test('serializes provided trusted domains', () {
      final json = Configuration(
        applicationCode: 'app-code',
        trustedDomains: ['example.com', 'trusted.org'],
      ).toJson();

      expect(json['trustedDomains'], ['example.com', 'trusted.org']);
    });

    test('round-trips trusted domains through JSON sent to native', () {
      final encoded = jsonEncode(Configuration(
        applicationCode: 'app-code',
        trustedDomains: ['example.com'],
      ).toJson());

      expect((jsonDecode(encoded) as Map<String, dynamic>)['trustedDomains'], ['example.com']);
    });

    test('serializes as null when omitted, keeping all URLs allowed', () {
      final json = Configuration(applicationCode: 'app-code').toJson();

      expect(json.containsKey('trustedDomains'), isTrue);
      expect(json['trustedDomains'], isNull);
    });

    test('serializes empty list as empty, meaning no restriction', () {
      final json = Configuration(
        applicationCode: 'app-code',
        trustedDomains: [],
      ).toJson();

      expect(json['trustedDomains'], isEmpty);
    });
  });
}
