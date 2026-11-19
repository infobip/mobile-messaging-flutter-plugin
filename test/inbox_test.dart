//
//  inbox_test.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/inbox/filter_options.dart';
import 'package:infobip_mobilemessaging/models/inbox/inbox.dart';

const MethodChannel _channel = MethodChannel('infobip_mobilemessaging');

Map<String, dynamic> _inboxJson({String? nextCursor}) => {
      'countTotal': 3,
      'countUnread': 1,
      'messages': [
        {'messageId': 'id-1', 'topic': 'promo', 'seen': false, 'body': 'Hello'},
      ],
      if (nextCursor != null) 'nextCursor': nextCursor,
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final List<MethodCall> calls = [];

  void mockChannel(Future<Object?>? Function(MethodCall call) handler) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      _channel,
      (call) {
        calls.add(call);
        return handler(call);
      },
    );
  }

  setUpAll(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockStreamHandler(
      const EventChannel('infobip_mobilemessaging/broadcast'),
      MockStreamHandler.inline(onListen: (args, sink) {}),
    );
  });

  setUp(calls.clear);

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(_channel, null);
  });

  group('FilterOptions cursor', () {
    test('cursor is serialized when set', () {
      expect(FilterOptions(limit: 10, cursor: 'abc').toJson(), {'limit': 10, 'cursor': 'abc'});
    });

    test('cursor is omitted when null, existing JSON is unchanged', () {
      expect(FilterOptions(topic: 'promo', limit: 10).toJson(), {'topic': 'promo', 'limit': 10});
    });

    test('cursor takes part in equality', () {
      expect(FilterOptions(cursor: 'a'), FilterOptions(cursor: 'a'));
      expect(FilterOptions(cursor: 'a') == FilterOptions(cursor: 'b'), isFalse);
      expect(FilterOptions(cursor: 'a') == FilterOptions(), isFalse);
    });
  });

  group('Inbox nextCursor', () {
    test('is parsed when present', () {
      expect(Inbox.fromJson(_inboxJson(nextCursor: 'next')).nextCursor, 'next');
    });

    test('is null when absent (last page)', () {
      final inbox = Inbox.fromJson(_inboxJson());
      expect(inbox.nextCursor, isNull);
      expect(inbox.countTotal, 3);
      expect(inbox.messages!.single.messageId, 'id-1');
    });
  });

  group('fetchInboxMessages', () {
    test('sends cursor to native and returns nextCursor', () async {
      mockChannel((call) async => jsonEncode(_inboxJson(nextCursor: 'page-3')));

      final inbox = await InfobipMobilemessaging.fetchInboxMessages(
        'jwt',
        'user',
        FilterOptions(topic: 'promo', limit: 1, cursor: 'page-2'),
      );

      expect(calls.single.method, 'fetchInboxMessages');
      final args = calls.single.arguments as Map;
      expect(args['token'], 'jwt');
      expect(args['externalUserId'], 'user');
      expect(jsonDecode(args['filterOptions']), {'topic': 'promo', 'limit': 1, 'cursor': 'page-2'});
      expect(inbox.nextCursor, 'page-3');
    });

    test('without cursor works as before', () async {
      mockChannel((call) async => jsonEncode(_inboxJson()));

      final inbox = await InfobipMobilemessaging.fetchInboxMessagesWithoutToken('user', FilterOptions());

      expect(calls.single.method, 'fetchInboxMessagesWithoutToken');
      expect(jsonDecode((calls.single.arguments as Map)['filterOptions']), isEmpty);
      expect(inbox.nextCursor, isNull);
    });
  });

  group('deleteInboxMessages', () {
    test('sends token, externalUserId and messageIds', () async {
      mockChannel((call) async => null);

      await InfobipMobilemessaging.deleteInboxMessages('jwt', 'user', ['id-1', 'id-2']);

      expect(calls.single.method, 'deleteInboxMessages');
      expect(calls.single.arguments, {
        'token': 'jwt',
        'externalUserId': 'user',
        'messageIds': ['id-1', 'id-2'],
      });
    });

    test('without token sends externalUserId and messageIds', () async {
      mockChannel((call) async => null);

      await InfobipMobilemessaging.deleteInboxMessagesWithoutToken('user', ['id-1']);

      expect(calls.single.method, 'deleteInboxMessagesWithoutToken');
      expect(calls.single.arguments, {
        'externalUserId': 'user',
        'messageIds': ['id-1'],
      });
    });

    test('native error is thrown as PlatformException with its code', () async {
      mockChannel(
        (call) async => throw PlatformException(code: '20013', message: 'At least one message ID is required'),
      );

      await expectLater(
        InfobipMobilemessaging.deleteInboxMessages('jwt', 'user', []),
        throwsA(isA<PlatformException>().having((e) => e.code, 'code', '20013')),
      );
    });

    test('missing native implementation is thrown as MissingPluginException', () async {
      mockChannel((call) async => throw MissingPluginException());

      await expectLater(
        InfobipMobilemessaging.deleteInboxMessagesWithoutToken('user', ['id-1']),
        throwsA(isA<MissingPluginException>()),
      );
    });
  });
}
