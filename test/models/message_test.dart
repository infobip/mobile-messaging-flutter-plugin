//   message_test.dart
//   MobileMessagingFlutter
//
//   Copyright (c) 2016-2025 Infobip Limited
//   Licensed under the Apache License, Version 2.0
//

import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/models/data/message.dart';

void main() {
  group('Message', () {
    group('fromJson', () {
      test('creates Message from valid JSON with all fields', () {
        final json = {
          'messageId': 'msg-123',
          'title': 'Test Title',
          'body': 'Test Body',
          'sound': 'default',
          'vibrate': true,
          'icon': 'app_icon',
          'silent': false,
          'category': 'CATEGORY_A',
          'customPayload': {'key1': 'value1', 'key2': 123},
          'internalData': '{"internal":"data"}',
          'receivedTimestamp': 1234567890,
          'seenDate': 1234567900,
          'browserUrl': 'https://example.com',
          'deeplink': 'myapp://page',
          'webViewUrl': 'https://webview.example.com',
          'chat': true,
          'inAppOpenTitle': 'Open',
          'inAppDismissTitle': 'Dismiss',
          'originalPayload': {'original':'payload'},
        };

        final message = Message.fromJson(json);

        expect(message.messageId, 'msg-123');
        expect(message.title, 'Test Title');
        expect(message.body, 'Test Body');
        expect(message.sound, 'default');
        expect(message.vibrate, true);
        expect(message.icon, 'app_icon');
        expect(message.silent, false);
        expect(message.category, 'CATEGORY_A');
        expect(message.customPayload, {'key1': 'value1', 'key2': 123});
        expect(message.internalData, '{"internal":"data"}');
        expect(message.receivedTimestamp, 1234567890);
        expect(message.seenDate, 1234567900);
        expect(message.browserUrl, 'https://example.com');
        expect(message.deeplink, 'myapp://page');
        expect(message.webViewUrl, 'https://webview.example.com');
        expect(message.chat, true);
        expect(message.inAppOpenTitle, 'Open');
        expect(message.inAppDismissTitle, 'Dismiss');
        expect(message.originalPayload, {'original':'payload'});
      });

      test('creates Message from JSON with minimal required fields', () {
        final json = {
          'messageId': 'msg-minimal',
        };

        final message = Message.fromJson(json);

        expect(message.messageId, 'msg-minimal');
        expect(message.title, isNull);
        expect(message.body, isNull);
        expect(message.sound, isNull);
        expect(message.vibrate, isNull);
        expect(message.icon, isNull);
        expect(message.silent, isNull);
        expect(message.category, isNull);
        expect(message.customPayload, isNull);
        expect(message.internalData, isNull);
        expect(message.receivedTimestamp, isNull);
        expect(message.seenDate, isNull);
        expect(message.browserUrl, isNull);
        expect(message.deeplink, isNull);
        expect(message.webViewUrl, isNull);
        expect(message.chat, isNull);
      });

      test('handles null values in JSON', () {
        final json = {
          'messageId': 'msg-nulls',
          'title': null,
          'body': null,
          'customPayload': null,
        };

        final message = Message.fromJson(json);

        expect(message.messageId, 'msg-nulls');
        expect(message.title, isNull);
        expect(message.body, isNull);
        expect(message.customPayload, isNull);
      });

      test('handles nested custom payload correctly', () {
        final json = {
          'messageId': 'msg-nested',
          'customPayload': {
            'level1': {
              'level2': {'level3': 'deep value'},
            },
            'array': [1, 2, 3],
            'bool': true,
          },
        };

        final message = Message.fromJson(json);

        expect(message.customPayload!['level1']['level2']['level3'], 'deep value');
        expect(message.customPayload!['array'], [1, 2, 3]);
        expect(message.customPayload!['bool'], true);
      });
    });

    group('equality', () {
      test('equals returns true for identical messages', () {
        final message1 = Message(
          messageId: 'msg-1',
          title: 'Title',
          body: 'Body',
          customPayload: {'key': 'value'},
        );
        final message2 = Message(
          messageId: 'msg-1',
          title: 'Title',
          body: 'Body',
          customPayload: {'key': 'value'},
        );

        expect(message1 == message2, true);
        expect(message1.hashCode, message2.hashCode);
      });

      test('equals returns false for different messageIds', () {
        final message1 = Message(messageId: 'msg-1');
        final message2 = Message(messageId: 'msg-2');

        expect(message1 == message2, false);
      });

      test('equals returns false for different bodies', () {
        final message1 = Message(
          messageId: 'msg-1',
          body: 'Body 1',
        );
        final message2 = Message(
          messageId: 'msg-1',
          body: 'Body 2',
        );

        expect(message1 == message2, false);
      });

      test('equals returns false for different custom payloads', () {
        final message1 = Message(
          messageId: 'msg-1',
          customPayload: {'key': 'value1'},
        );
        final message2 = Message(
          messageId: 'msg-1',
          customPayload: {'key': 'value2'},
        );

        expect(message1 == message2, false);
      });

      test('equals handles null custom payloads correctly', () {
        final message1 = Message(
          messageId: 'msg-1',
          customPayload: null,
        );
        final message2 = Message(
          messageId: 'msg-1',
          customPayload: null,
        );

        expect(message1 == message2, true);
      });
    });

    group('edge cases', () {
      test('handles empty string values', () {
        final json = {
          'messageId': '',
          'title': '',
          'body': '',
        };

        final message = Message.fromJson(json);

        expect(message.messageId, '');
        expect(message.title, '');
        expect(message.body, '');
      });

      test('handles special characters in strings', () {
        final json = {
          'messageId': 'msg-special',
          'title': 'Title with 😀 emoji and \n newline',
          'body': 'Body with "quotes" and \'apostrophes\'',
        };

        final message = Message.fromJson(json);

        expect(message.title, contains('😀'));
        expect(message.title, contains('\n'));
        expect(message.body, contains('"quotes"'));
        expect(message.body, contains("'apostrophes'"));
      });

      test('handles empty custom payload', () {
        final json = {
          'messageId': 'msg-empty-payload'
        };

        final message = Message.fromJson(json);

        expect(message.customPayload, null);
      });
    });

    group('platform-specific fields', () {
      test('handles Android-specific fields', () {
        final json = {
          'messageId': 'msg-android',
          'vibrate': true,
          'icon': 'notification_icon',
          'category': 'PROMO',
        };

        final message = Message.fromJson(json);

        expect(message.vibrate, true);
        expect(message.icon, 'notification_icon');
        expect(message.category, 'PROMO');
      });

      test('handles iOS-specific fields', () {
        final json = {
          'messageId': 'msg-ios',
          'originalPayload': {'aps':{'alert':'Test'}},
        };

        final message = Message.fromJson(json);

        expect(message.originalPayload, {'aps':{'alert':'Test'}});
      });
    });

    group('action URLs', () {
      test('handles all URL types', () {
        final json = {
          'messageId': 'msg-urls',
          'browserUrl': 'https://browser.example.com',
          'deeplink': 'myapp://screen/details',
          'webViewUrl': 'https://webview.example.com/page',
        };

        final message = Message.fromJson(json);

        expect(message.browserUrl, 'https://browser.example.com');
        expect(message.deeplink, 'myapp://screen/details');
        expect(message.webViewUrl, 'https://webview.example.com/page');
      });

      test('handles missing URL fields', () {
        final json = {
          'messageId': 'msg-no-urls',
        };

        final message = Message.fromJson(json);

        expect(message.browserUrl, isNull);
        expect(message.deeplink, isNull);
        expect(message.webViewUrl, isNull);
      });
    });

    group('chat messages', () {
      test('identifies chat messages correctly', () {
        final json = {
          'messageId': 'msg-chat',
          'chat': true,
          'body': 'Chat message body',
        };

        final message = Message.fromJson(json);

        expect(message.chat, true);
        expect(message.body, 'Chat message body');
      });

      test('identifies non-chat messages correctly', () {
        final json = {
          'messageId': 'msg-not-chat',
          'chat': false,
        };

        final message = Message.fromJson(json);

        expect(message.chat, false);
      });
    });

    group('in-app message fields', () {
      test('handles in-app message action titles', () {
        final json = {
          'messageId': 'msg-in-app',
          'inAppOpenTitle': 'View Details',
          'inAppDismissTitle': 'Close',
        };

        final message = Message.fromJson(json);

        expect(message.inAppOpenTitle, 'View Details');
        expect(message.inAppDismissTitle, 'Close');
      });
    });
  });
}
