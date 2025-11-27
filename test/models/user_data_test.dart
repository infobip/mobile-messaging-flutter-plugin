//   user_data_test.dart
//   MobileMessagingFlutter
//
//   Copyright (c) 2016-2025 Infobip Limited
//   Licensed under the Apache License, Version 2.0
//

import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/models/data/installation.dart';
import 'package:infobip_mobilemessaging/models/data/user_data.dart';

void main() {
  group('UserData', () {
    group('fromJson', () {
      test('creates UserData from complete JSON', () {
        final json = {
          'externalUserId': 'user-123',
          'firstName': 'John',
          'lastName': 'Doe',
          'middleName': 'Michael',
          'gender': 'Male',
          'birthday': '1990-01-15',
          'phones': ['+1234567890', '+0987654321'],
          'emails': ['john@example.com', 'john.doe@work.com'],
          'tags': ['premium', 'verified'],
          'customAttributes': {
            'preference': 'dark_mode',
            'level': 5,
            'subscribed': true,
          },
          'installations': [
            {
              'pushRegistrationId': 'reg-123',
              'isPrimaryDevice': true,
              'isPushRegistrationEnabled': true,
              'notificationsEnabled': true,
              'pushServiceType': 'Firebase',
              'sdkVersion': '9.1.2',
              'os': 'Android',
            }
          ],
        };

        final userData = UserData.fromJson(json);

        expect(userData.externalUserId, 'user-123');
        expect(userData.firstName, 'John');
        expect(userData.lastName, 'Doe');
        expect(userData.middleName, 'Michael');
        expect(userData.gender, Gender.Male);
        expect(userData.birthday, '1990-01-15');
        expect(userData.phones, ['+1234567890', '+0987654321']);
        expect(userData.emails, ['john@example.com', 'john.doe@work.com']);
        expect(userData.tags, ['premium', 'verified']);
        expect(userData.customAttributes!['preference'], 'dark_mode');
        expect(userData.customAttributes!['level'], 5);
        expect(userData.customAttributes!['subscribed'], true);
        expect(userData.installations, hasLength(1));
        expect(userData.installations![0].pushRegistrationId, 'reg-123');
      });

      test('creates UserData with minimal fields', () {
        final json = {
          'externalUserId': 'user-min',
        };

        final userData = UserData.fromJson(json);

        expect(userData.externalUserId, 'user-min');
        expect(userData.firstName, isNull);
        expect(userData.lastName, isNull);
        expect(userData.gender, isNull);
        expect(userData.phones, isNull);
        expect(userData.emails, isNull);
        expect(userData.tags, isNull);
        expect(userData.customAttributes, isNull);
        expect(userData.installations, isNull);
      });

      test('resolves Gender enum correctly', () {
        final maleJson = {'gender': 'Male'};
        final femaleJson = {'gender': 'Female'};

        expect(UserData.fromJson(maleJson).gender, Gender.Male);
        expect(UserData.fromJson(femaleJson).gender, Gender.Female);
      });

      test('handles empty lists', () {
        final json = {
          'externalUserId': 'user-empty',
          'phones': [],
          'emails': [],
          'tags': [],
          'installations': [],
        };

        final userData = UserData.fromJson(json);

        expect(userData.phones, isEmpty);
        expect(userData.emails, isEmpty);
        expect(userData.tags, isEmpty);
        expect(userData.installations, isEmpty);
      });

      test('handles null values in optional fields', () {
        final json = {
          'externalUserId': 'user-nulls',
          'firstName': null,
          'phones': null,
          'customAttributes': null,
        };

        final userData = UserData.fromJson(json);

        expect(userData.firstName, isNull);
        expect(userData.phones, isNull);
        expect(userData.customAttributes, isNull);
      });
    });

    group('toJson', () {
      test('serializes UserData to JSON with all fields', () {
        final userData = UserData(
          externalUserId: 'user-123',
          firstName: 'John',
          lastName: 'Doe',
          gender: Gender.Male,
          birthday: '1990-01-15',
          phones: ['+1234567890'],
          emails: ['john@example.com'],
          tags: ['premium'],
          customAttributes: {'level': 5},
        );

        final json = userData.toJson();

        expect(json['externalUserId'], 'user-123');
        expect(json['firstName'], 'John');
        expect(json['lastName'], 'Doe');
        expect(json['gender'], 'Male');
        expect(json['birthday'], '1990-01-15');
        expect(json['phones'], ['+1234567890']);
        expect(json['emails'], ['john@example.com']);
        expect(json['tags'], ['premium']);
        expect(json['customAttributes'], {'level': 5});
      });

      test('serializes UserData with minimal fields', () {
        final userData = UserData(externalUserId: 'user-min');

        final json = userData.toJson();

        expect(json['externalUserId'], 'user-min');
        expect(json.containsKey('firstName'), false);
        expect(json.containsKey('lastName'), false);
      });

      test('handles null optional fields in serialization', () {
        final userData = UserData(
          externalUserId: 'user-nulls',
          firstName: null,
          phones: null,
        );

        final json = userData.toJson();

        expect(json.containsKey('firstName'), false);
        expect(json.containsKey('phones'), false);
      });
    });

    group('equality', () {
      test('equals returns true for identical UserData', () {
        final user1 = UserData(
          externalUserId: 'user-1',
          firstName: 'John',
          emails: ['john@example.com'],
          customAttributes: {'key': 'value'},
        );
        final user2 = UserData(
          externalUserId: 'user-1',
          firstName: 'John',
          emails: ['john@example.com'],
          customAttributes: {'key': 'value'},
        );

        expect(user1 == user2, true);
        expect(user1.hashCode, user2.hashCode);
      });

      test('equals returns false for different externalUserId', () {
        final user1 = UserData(externalUserId: 'user-1');
        final user2 = UserData(externalUserId: 'user-2');

        expect(user1 == user2, false);
      });

      test('equals returns false for different custom attributes', () {
        final user1 = UserData(
          externalUserId: 'user-1',
          customAttributes: {'key': 'value1'},
        );
        final user2 = UserData(
          externalUserId: 'user-1',
          customAttributes: {'key': 'value2'},
        );

        expect(user1 == user2, false);
      });

      test('equals handles null fields correctly', () {
        final user1 = UserData(externalUserId: 'user-1');
        final user2 = UserData(externalUserId: 'user-1');

        expect(user1 == user2, true);
        expect(user1.hashCode, user2.hashCode);
      });

      test('equals returns false for different lists', () {
        final user1 = UserData(
          externalUserId: 'user-1',
          tags: ['tag1', 'tag2'],
        );
        final user2 = UserData(
          externalUserId: 'user-1',
          tags: ['tag1', 'tag3'],
        );

        expect(user1 == user2, false);
      });
    });

    group('gender enum', () {
      test('Gender enum has correct values', () {
        expect(Gender.values, hasLength(2));
        expect(Gender.values, contains(Gender.Male));
        expect(Gender.values, contains(Gender.Female));
      });

      test('resolveGender returns correct enum for valid strings', () {
        expect(UserData.resolveGender('Male'), Gender.Male);
        expect(UserData.resolveGender('Female'), Gender.Female);
      });
    });

    group('nested installations', () {
      test('deserializes nested installations correctly', () {
        final json = {
          'externalUserId': 'user-123',
          'installations': [
            {
              'pushRegistrationId': 'reg-1',
              'isPrimaryDevice': true,
              'os': 'Android',
            },
            {
              'pushRegistrationId': 'reg-2',
              'isPrimaryDevice': false,
              'os': 'iOS',
            },
          ],
        };

        final userData = UserData.fromJson(json);

        expect(userData.installations, hasLength(2));
        expect(userData.installations![0].pushRegistrationId, 'reg-1');
        expect(userData.installations![0].isPrimaryDevice, true);
        expect(userData.installations![0].os, OS.Android);
        expect(userData.installations![1].pushRegistrationId, 'reg-2');
        expect(userData.installations![1].isPrimaryDevice, false);
        expect(userData.installations![1].os, OS.iOS);
      });
    });

    group('phone and email lists', () {
      test('handles multiple phones', () {
        final json = {
          'externalUserId': 'user-123',
          'phones': ['+1234567890', '+0987654321', '+1111111111'],
        };

        final userData = UserData.fromJson(json);
        expect(userData.phones, hasLength(3));
        expect(userData.phones, contains('+1234567890'));
      });

      test('handles multiple emails', () {
        final json = {
          'externalUserId': 'user-123',
          'emails': ['primary@example.com', 'work@company.com', 'personal@mail.com'],
        };

        final userData = UserData.fromJson(json);
        expect(userData.emails, hasLength(3));
        expect(userData.emails, contains('work@company.com'));
      });
    });

    group('custom attributes', () {
      test('handles various data types in custom attributes', () {
        final json = {
          'externalUserId': 'user-123',
          'customAttributes': {
            'string': 'value',
            'int': 42,
            'double': 3.14,
            'bool': true,
            'list': [1, 2, 3],
            'nested': {'key': 'value'},
          },
        };

        final userData = UserData.fromJson(json);

        expect(userData.customAttributes!['string'], 'value');
        expect(userData.customAttributes!['int'], 42);
        expect(userData.customAttributes!['double'], 3.14);
        expect(userData.customAttributes!['bool'], true);
        expect(userData.customAttributes!['list'], [1, 2, 3]);
        expect(userData.customAttributes!['nested'], {'key': 'value'});
      });

      test('handles missing custom attributes', () {
        final json = {
          'externalUserId': 'user-123',
        };

        final userData = UserData.fromJson(json);
        expect(userData.customAttributes, isNull);
      });
    });
  });
}
