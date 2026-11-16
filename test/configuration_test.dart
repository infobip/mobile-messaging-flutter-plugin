//
//  configuration_test.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2026 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/models/configurations/configuration.dart';

void main() {
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
