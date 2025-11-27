//   installation_test.dart
//   MobileMessagingFlutter
//
//   Copyright (c) 2016-2025 Infobip Limited
//   Licensed under the Apache License, Version 2.0
//

import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/models/data/installation.dart';

void main() {
  group('Installation', () {
    group('fromJson', () {
      test('creates Installation from complete JSON', () {
        final json = {
          'pushRegistrationId': 'reg-123',
          'isPrimaryDevice': true,
          'isPushRegistrationEnabled': true,
          'notificationsEnabled': true,
          'pushServiceToken': 'token-abc',
          'pushServiceType': 'Firebase',
          'sdkVersion': '9.1.2',
          'appVersion': '1.0.0',
          'os': 'Android',
          'osVersion': '13',
          'deviceManufacturer': 'Google',
          'deviceModel': 'Pixel 7',
          'deviceSecure': true,
          'deviceName': 'Test Device',
          'language': 'en',
          'deviceTimezoneOffset': '-08:00',
          'customAttributes': {'customKey': 'customValue'},
        };

        final installation = Installation.fromJson(json);

        expect(installation.pushRegistrationId, 'reg-123');
        expect(installation.isPrimaryDevice, true);
        expect(installation.isPushRegistrationEnabled, true);
        expect(installation.notificationsEnabled, true);
        expect(installation.pushServiceToken, 'token-abc');
        expect(installation.pushServiceType, PushServiceType.Firebase);
        expect(installation.sdkVersion, '9.1.2');
        expect(installation.appVersion, '1.0.0');
        expect(installation.os, OS.Android);
        expect(installation.osVersion, '13');
        expect(installation.deviceManufacturer, 'Google');
        expect(installation.deviceModel, 'Pixel 7');
        expect(installation.deviceSecure, true);
        expect(installation.deviceName, 'Test Device');
        expect(installation.language, 'en');
        expect(installation.deviceTimezoneOffset, '-08:00');
        expect(installation.customAttributes, {'customKey': 'customValue'});
      });

      test('creates Installation with minimal fields', () {
        final json = {
          'pushRegistrationId': 'reg-minimal',
        };

        final installation = Installation.fromJson(json);

        expect(installation.pushRegistrationId, 'reg-minimal');
        expect(installation.isPrimaryDevice, isNull);
        expect(installation.sdkVersion, isNull);
      });

      test('resolves PushServiceType enum correctly', () {
        final gcm = Installation.fromJson({'pushServiceType': 'GCM'});
        final firebase = Installation.fromJson({'pushServiceType': 'Firebase'});
        final apns = Installation.fromJson({'pushServiceType': 'APNS'});

        expect(gcm.pushServiceType, PushServiceType.GCM);
        expect(firebase.pushServiceType, PushServiceType.Firebase);
        expect(apns.pushServiceType, PushServiceType.APNS);
      });

      test('resolves OS enum correctly', () {
        final android = Installation.fromJson({'os': 'Android'});
        final ios = Installation.fromJson({'os': 'iOS'});

        expect(android.os, OS.Android);
        expect(ios.os, OS.iOS);
      });

      test('handles boolean flags correctly', () {
        final json = {
          'pushRegistrationId': 'reg-bool',
          'isPrimaryDevice': true,
          'isPushRegistrationEnabled': false,
          'notificationsEnabled': true,
          'deviceSecure': false,
        };

        final installation = Installation.fromJson(json);

        expect(installation.isPrimaryDevice, true);
        expect(installation.isPushRegistrationEnabled, false);
        expect(installation.notificationsEnabled, true);
        expect(installation.deviceSecure, false);
      });
    });

    group('toJson', () {
      test('serializes Installation to JSON with all fields', () {
        final installation = Installation(
          pushRegistrationId: 'reg-123',
          isPrimaryDevice: true,
          isPushRegistrationEnabled: true,
          notificationsEnabled: true,
          pushServiceToken: 'token-abc',
          pushServiceType: PushServiceType.Firebase,
          sdkVersion: '9.1.2',
          appVersion: '1.0.0',
          os: OS.Android,
          osVersion: '13',
          deviceManufacturer: 'Google',
          deviceModel: 'Pixel 7',
          deviceSecure: true,
          language: 'en',
          customAttributes: {'key': 'value'},
        );

        final json = installation.toJson();

        expect(json['pushRegistrationId'], 'reg-123');
        expect(json['isPrimaryDevice'], true);
        expect(json['isPushRegistrationEnabled'], true);
        expect(json['notificationsEnabled'], true);
        expect(json['pushServiceToken'], 'token-abc');
        expect(json['pushServiceType'], 'Firebase');
        expect(json['sdkVersion'], '9.1.2');
        expect(json['appVersion'], '1.0.0');
        expect(json['os'], 'Android');
        expect(json['osVersion'], '13');
        expect(json['deviceManufacturer'], 'Google');
        expect(json['deviceModel'], 'Pixel 7');
        expect(json['deviceSecure'], true);
        expect(json['language'], 'en');
        expect(json['customAttributes'], {'key': 'value'});
      });

      test('includes null fields from JSON', () {
        final installation = Installation(
          pushRegistrationId: 'reg-min',
          isPrimaryDevice: null,
          sdkVersion: null,
        );

        final json = installation.toJson();

        expect(json['pushRegistrationId'], 'reg-min');
        expect(json.containsKey('isPrimaryDevice'), true);
        expect(json.containsKey('sdkVersion'), true);
      });

      test('serializes enums correctly', () {
        final installation = Installation(
          pushServiceType: PushServiceType.APNS,
          os: OS.iOS,
        );

        final json = installation.toJson();

        expect(json['pushServiceType'], 'APNS');
        expect(json['os'], 'iOS');
      });
    });

    group('equality', () {
      test('equals returns true for identical installations', () {
        final inst1 = Installation(
          pushRegistrationId: 'reg-1',
          isPrimaryDevice: true,
          deviceModel: 'Pixel 7',
        );
        final inst2 = Installation(
          pushRegistrationId: 'reg-1',
          isPrimaryDevice: true,
          deviceModel: 'Pixel 7',
        );

        expect(inst1 == inst2, true);
        expect(inst1.hashCode, inst2.hashCode);
      });

      test('equals returns false for different pushRegistrationId', () {
        final inst1 = Installation(pushRegistrationId: 'reg-1');
        final inst2 = Installation(pushRegistrationId: 'reg-2');

        expect(inst1 == inst2, false);
      });

      test('equals returns false for different device info', () {
        final inst1 = Installation(
          pushRegistrationId: 'reg-1',
          deviceModel: 'Pixel 7',
        );
        final inst2 = Installation(
          pushRegistrationId: 'reg-1',
          deviceModel: 'iPhone 14',
        );

        expect(inst1 == inst2, false);
      });

      test('equals handles null custom attributes', () {
        final inst1 = Installation(customAttributes: null);
        final inst2 = Installation(customAttributes: null);

        expect(inst1 == inst2, true);
      });
    });

    group('enums', () {
      test('PushServiceType enum has correct values', () {
        expect(PushServiceType.values, hasLength(3));
        expect(PushServiceType.values, contains(PushServiceType.GCM));
        expect(PushServiceType.values, contains(PushServiceType.Firebase));
        expect(PushServiceType.values, contains(PushServiceType.APNS));
      });

      test('OS enum has correct values', () {
        expect(OS.values, hasLength(2));
        expect(OS.values, contains(OS.Android));
        expect(OS.values, contains(OS.iOS));
      });

      test('enum values are available', () {
        expect(PushServiceType.values, hasLength(3));
        expect(PushServiceType.values, contains(PushServiceType.GCM));
        expect(PushServiceType.values, contains(PushServiceType.Firebase));
        expect(PushServiceType.values, contains(PushServiceType.APNS));
      });
    });

    group('custom attributes', () {
      test('handles various data types in custom attributes', () {
        final json = {
          'pushRegistrationId': 'reg-123',
          'customAttributes': {
            'string': 'value',
            'int': 42,
            'bool': true,
            'list': [1, 2, 3],
            'nested': {'inner': 'value'},
          },
        };

        final installation = Installation.fromJson(json);

        expect(installation.customAttributes!['string'], 'value');
        expect(installation.customAttributes!['int'], 42);
        expect(installation.customAttributes!['bool'], true);
        expect(installation.customAttributes!['list'], [1, 2, 3]);
        expect(installation.customAttributes!['nested'], {'inner': 'value'});
      });
    });

    group('primary device scenarios', () {
      test('handles primary device flag', () {
        final primary = Installation.fromJson({
          'pushRegistrationId': 'reg-primary',
          'isPrimaryDevice': true,
        });
        final secondary = Installation.fromJson({
          'pushRegistrationId': 'reg-secondary',
          'isPrimaryDevice': false,
        });

        expect(primary.isPrimaryDevice, true);
        expect(secondary.isPrimaryDevice, false);
      });
    });

    group('edge cases', () {
      test('handles empty strings', () {
        final json = {
          'pushRegistrationId': '',
          'deviceName': '',
          'language': '',
        };

        final installation = Installation.fromJson(json);

        expect(installation.pushRegistrationId, '');
        expect(installation.deviceName, '');
        expect(installation.language, '');
      });

      test('handles special characters in device names', () {
        final json = {
          'pushRegistrationId': 'reg-123',
          'deviceName': "John's iPhone 📱",
        };

        final installation = Installation.fromJson(json);
        expect(installation.deviceName, "John's iPhone 📱");
      });
    });
  });
}
