//
//  personalize_context_test.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/models/data/personalize_context.dart';
import 'package:infobip_mobilemessaging/models/data/user_data.dart';

void main() {
  group('PersonalizeContext', () {
    group('toJson', () {
      test('serializes complete PersonalizeContext', () {
        final context = PersonalizeContext(
          userIdentity: UserIdentity(
            externalUserId: 'user-123',
            phones: ['+1234567890'],
            emails: ['test@example.com'],
          ),
          userAttributes: UserAttributes(
            firstName: 'John',
            lastName: 'Doe',
            gender: Gender.Male,
            birthday: '1990-01-15',
            tags: ['premium'],
            customAttributes: {'level': 5},
          ),
          forceDepersonalize: true,
          keepAsLead: false,
        );

        final json = context.toJson();

        expect(json['userIdentity']['externalUserId'], 'user-123');
        expect(json['userIdentity']['phones'], ['+1234567890']);
        expect(json['userIdentity']['emails'], ['test@example.com']);
        expect(json['userAttributes']['firstName'], 'John');
        expect(json['userAttributes']['lastName'], 'Doe');
        expect(json['userAttributes']['gender'], 'Male');
        expect(json['userAttributes']['birthday'], '1990-01-15');
        expect(json['userAttributes']['tags'], ['premium']);
        expect(json['userAttributes']['customAttributes'], {'level': 5});
        expect(json['forceDepersonalize'], true);
        expect(json['keepAsLead'], false);
      });

      test('serializes with minimal fields', () {
        final context = PersonalizeContext(
          userIdentity: UserIdentity(externalUserId: 'user-min'),
        );

        final json = context.toJson();

        expect(json['userIdentity']['externalUserId'], 'user-min');
        expect(json['userAttributes'], isNull);
        expect(json['forceDepersonalize'], isNull);
        expect(json['keepAsLead'], isNull);
      });

      test('handles null optional fields', () {
        final context = PersonalizeContext(
          userIdentity: UserIdentity(externalUserId: 'user-123'),
          userAttributes: null,
          forceDepersonalize: null,
        );

        final json = context.toJson();

        expect(json['userAttributes'], isNull);
        expect(json['forceDepersonalize'], isNull);
      });
    });

    group('equality', () {
      test('UserIdentity equals', () {
        final userIdentity1 = UserIdentity(
          phones: ['38516419710'],
          externalUserId: 'some-user-id',
          emails: [],
        );
        final userIdentity2 = UserIdentity(
          phones: ['38516419710'],
          externalUserId: 'some-user-id',
          emails: [],
        );
        expect(userIdentity1 == userIdentity2, true);
        expect(userIdentity1.hashCode, userIdentity2.hashCode);
      });

      test('UserAttributes equals', () {
        final userAttributes1 = UserAttributes(
          firstName: 'Jon',
          middleName: 'Average',
          lastName: 'Doe',
          gender: Gender.Male,
          birthday: '1989-01-13',
          tags: ['tag1', 'tag2'],
          customAttributes: {
            'alDate': '2021-10-11',
            'alWhole': 2,
            'alString': 'someAnotherString',
            'alBoolean': true,
            'alDecimal': 0.66,
          },
        );

        final userAttributes2 = UserAttributes(
          firstName: 'Jon',
          middleName: 'Average',
          lastName: 'Doe',
          gender: Gender.Male,
          birthday: '1989-01-13',
          tags: ['tag1', 'tag2'],
          customAttributes: {
            'alDate': '2021-10-11',
            'alWhole': 2,
            'alString': 'someAnotherString',
            'alBoolean': true,
            'alDecimal': 0.66,
          },
        );

        expect(userAttributes1 == userAttributes2, true);
        expect(userAttributes1.hashCode, userAttributes2.hashCode);
      });

      test('PersonalizeContext equals', () {
        final personalizeContext1 = PersonalizeContext(
          userIdentity: UserIdentity(
            emails: [],
            phones: [],
            externalUserId: 'some-id',
          ),
          userAttributes: UserAttributes(firstName: 'Jon'),
          forceDepersonalize: false,
          keepAsLead: false,
        );
        final personalizeContext2 = PersonalizeContext(
          userIdentity: UserIdentity(
            emails: [],
            phones: [],
            externalUserId: 'some-id',
          ),
          userAttributes: UserAttributes(firstName: 'Jon'),
          forceDepersonalize: false,
          keepAsLead: false,
        );

        expect(personalizeContext1 == personalizeContext2, true);
        expect(personalizeContext1.hashCode, personalizeContext2.hashCode);
      });
    });

    group('UserIdentity', () {
      test('toJson with all fields', () {
        final identity = UserIdentity(
          externalUserId: 'user-123',
          phones: ['+1234567890', '+0987654321'],
          emails: ['email1@example.com', 'email2@example.com'],
        );

        final json = identity.toJson();

        expect(json['externalUserId'], 'user-123');
        expect(json['phones'], ['+1234567890', '+0987654321']);
        expect(json['emails'], ['email1@example.com', 'email2@example.com']);
      });

      test('toJson with only externalUserId', () {
        final identity = UserIdentity(externalUserId: 'user-only-id');

        final json = identity.toJson();

        expect(json['externalUserId'], 'user-only-id');
        expect(json.containsKey('phones'), false);
        expect(json.containsKey('emails'), false);
      });

      test('toJson with only phones', () {
        final identity = UserIdentity(phones: ['+1234567890']);

        final json = identity.toJson();

        expect(json['phones'], ['+1234567890']);
        expect(json.containsKey('externalUserId'), false);
        expect(json.containsKey('emails'), false);
      });

      test('toJson with only emails', () {
        final identity = UserIdentity(emails: ['test@example.com']);

        final json = identity.toJson();

        expect(json['emails'], ['test@example.com']);
        expect(json.containsKey('externalUserId'), false);
        expect(json.containsKey('phones'), false);
      });

      test('handles empty lists', () {
        final identity = UserIdentity(
          externalUserId: 'user-123',
          phones: [],
          emails: [],
        );

        final json = identity.toJson();

        expect(json['phones'], isEmpty);
        expect(json['emails'], isEmpty);
      });

      test('handles multiple contact points', () {
        final phones = List.generate(5, (i) => '+123456789$i');
        final emails = List.generate(3, (i) => 'email$i@example.com');

        final identity = UserIdentity(
          externalUserId: 'user-multi',
          phones: phones,
          emails: emails,
        );

        final json = identity.toJson();

        expect(json['phones'], hasLength(5));
        expect(json['emails'], hasLength(3));
      });
    });

    group('UserAttributes', () {
      test('toJson with all fields', () {
        final attributes = UserAttributes(
          firstName: 'John',
          lastName: 'Doe',
          middleName: 'Michael',
          gender: Gender.Male,
          birthday: '1990-01-15',
          tags: ['tag1', 'tag2'],
          customAttributes: {
            'string': 'value',
            'int': 42,
            'bool': true,
          },
        );

        final json = attributes.toJson();

        expect(json['firstName'], 'John');
        expect(json['lastName'], 'Doe');
        expect(json['middleName'], 'Michael');
        expect(json['gender'], 'Male');
        expect(json['birthday'], '1990-01-15');
        expect(json['tags'], ['tag1', 'tag2']);
        expect(json['customAttributes'], {
          'string': 'value',
          'int': 42,
          'bool': true,
        });
      });

      test('toJson with minimal fields', () {
        var attributes = UserAttributes(firstName: 'John');
        attributes.lastName = null;

        var json = attributes.toJson();

        expect(json['firstName'], 'John');
        expect(json.containsKey('lastName'), false);
        expect(json.containsKey('gender'), false);
      });

      test('serializes Gender enum correctly', () {
        final male = UserAttributes(gender: Gender.Male);
        final female = UserAttributes(gender: Gender.Female);

        expect(male.toJson()['gender'], 'Male');
        expect(female.toJson()['gender'], 'Female');
      });

      test('handles null fields', () {
        final attributes = UserAttributes(
          firstName: 'John',
          lastName: null,
          gender: null,
        );

        final json = attributes.toJson();

        expect(json.containsKey('lastName'), false);
        expect(json.containsKey('gender'), false);
      });

      test('handles empty collections', () {
        final attributes = UserAttributes(
          tags: [],
          customAttributes: {},
        );

        final json = attributes.toJson();

        expect(json['tags'], isEmpty);
        expect(json['customAttributes'], isEmpty);
      });

      test('handles complex custom attributes', () {
        final attributes = UserAttributes(
          customAttributes: {
            'nested': {'deep': 'value'},
            'list': [1, 2, 3],
            'mixed': {
              'array': [true, false]
            },
          },
        );

        final json = attributes.toJson();

        expect(json['customAttributes']['nested'], {'deep': 'value'});
        expect(json['customAttributes']['list'], [1, 2, 3]);
        expect(json['customAttributes']['mixed'], {
          'array': [true, false]
        });
      });
    });

    group('personalization flags', () {
      test('forceDepersonalize flag serialization', () {
        final withForce = PersonalizeContext(
          userIdentity: UserIdentity(externalUserId: 'user-1'),
          forceDepersonalize: true,
        );
        final withoutForce = PersonalizeContext(
          userIdentity: UserIdentity(externalUserId: 'user-2'),
          forceDepersonalize: false,
        );

        expect(withForce.toJson()['forceDepersonalize'], true);
        expect(withoutForce.toJson()['forceDepersonalize'], false);
      });

      test('keepAsLead flag serialization', () {
        final keepLead = PersonalizeContext(
          userIdentity: UserIdentity(externalUserId: 'user-1'),
          keepAsLead: true,
        );
        final promoteToCustomer = PersonalizeContext(
          userIdentity: UserIdentity(externalUserId: 'user-2'),
          keepAsLead: false,
        );

        expect(keepLead.toJson()['keepAsLead'], true);
        expect(promoteToCustomer.toJson()['keepAsLead'], false);
      });

      test('default behavior when flags are null', () {
        final context = PersonalizeContext(
          userIdentity: UserIdentity(externalUserId: 'user-1'),
        );

        final json = context.toJson();

        expect(json['forceDepersonalize'], isNull);
        expect(json['keepAsLead'], isNull);
      });
    });
  });
}
