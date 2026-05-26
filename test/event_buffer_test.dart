//
//  event_buffer_test.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/data/message.dart';
import 'package:infobip_mobilemessaging/models/library_event.dart';

// Builds a minimal notificationTapped event JSON matching what the native
// StreamHandler emits, with an arbitrary customPayload map.
String _notificationTappedJson({Map<String, dynamic> customPayload = const {}}) =>
    jsonEncode({
      'eventName': LibraryEvent.notificationTapped,
      'payload': {
        'messageId': 'test-msg-id',
        'title': 'Test push',
        'body': 'Test body',
        'customPayload': customPayload,
      },
    });

void main() {
  // Initialize binding so EventChannel can be set up without a real platform.
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    // Stub the broadcast EventChannel with a silent stream so that
    // _libraryEventSubscription initializes cleanly. All events in these
    // tests are injected via handleEventForTesting(), bypassing the channel.
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockStreamHandler(
          const EventChannel('infobip_mobilemessaging/broadcast'),
          MockStreamHandler.inline(onListen: (args, sink) {}),
        );
  });

  setUp(InfobipMobilemessaging.clearForTesting);

  group('Cold-start event buffer — customPayload data loss fix', () {
    // -------------------------------------------------------------------------
    // Core regression test: the scenario the customer hit.
    //
    // Sequence: native fires notificationTapped (before any on() call) →
    //           event lands in Dart via EventChannel while callbacks is empty →
    //           must be buffered, NOT dropped →
    //           customer registers callback → buffered event replayed with payload
    // -------------------------------------------------------------------------
    test('event arriving before on() is buffered and replayed with full payload', () {
      final customPayload = {'screen': 'order_details', 'orderId': '12345'};

      // Simulate the native EventChannel delivering the event while no
      // callback is registered yet (the cold-start timing gap).
      InfobipMobilemessaging.handleEventForTesting(
        _notificationTappedJson(customPayload: customPayload),
      );

      Message? received;

      // Customer registers the callback only after init() completes.
      InfobipMobilemessaging.on(LibraryEvent.notificationTapped, (Message msg) {
        received = msg;
      });

      expect(received, isNotNull, reason: 'callback should have been invoked with buffered event');
      expect(received!.customPayload, equals(customPayload));
    });

    // -------------------------------------------------------------------------
    // Normal path: event arrives AFTER on() — must still work as before.
    // -------------------------------------------------------------------------
    test('event arriving after on() is delivered immediately', () {
      Message? received;

      InfobipMobilemessaging.on(LibraryEvent.notificationTapped, (Message msg) {
        received = msg;
      });

      final customPayload = {'screen': 'promo', 'promoId': 'abc'};
      InfobipMobilemessaging.handleEventForTesting(
        _notificationTappedJson(customPayload: customPayload),
      );

      expect(received, isNotNull);
      expect(received!.customPayload, equals(customPayload));
    });

    // -------------------------------------------------------------------------
    // Buffer is one-shot: after being replayed the event must not fire again
    // if a second callback registers for the same event type.
    // -------------------------------------------------------------------------
    test('buffered event is consumed on first on() and not replayed to subsequent on() calls', () {
      InfobipMobilemessaging.handleEventForTesting(_notificationTappedJson());

      int firstCallCount = 0;
      InfobipMobilemessaging.on(LibraryEvent.notificationTapped, (_) => firstCallCount++);

      int secondCallCount = 0;
      InfobipMobilemessaging.on(LibraryEvent.notificationTapped, (_) => secondCallCount++);

      expect(firstCallCount, equals(1));
      expect(secondCallCount, equals(0), reason: 'buffer must be cleared after first replay');
    });

    // -------------------------------------------------------------------------
    // Multiple buffered events: all are delivered in order.
    // -------------------------------------------------------------------------
    test('multiple buffered events are all replayed in order', () {
      InfobipMobilemessaging.handleEventForTesting(
        _notificationTappedJson(customPayload: {'order': '1'}),
      );
      InfobipMobilemessaging.handleEventForTesting(
        _notificationTappedJson(customPayload: {'order': '2'}),
      );

      final received = <Message>[];
      InfobipMobilemessaging.on(LibraryEvent.notificationTapped, (Message msg) {
        received.add(msg);
      });

      expect(received.length, equals(2));
      expect(received[0].customPayload, equals({'order': '1'}));
      expect(received[1].customPayload, equals({'order': '2'}));
    });

    // -------------------------------------------------------------------------
    // Unrelated event types don't cross-contaminate.
    // -------------------------------------------------------------------------
    test('buffered notificationTapped is not delivered to messageReceived callback', () {
      InfobipMobilemessaging.handleEventForTesting(_notificationTappedJson());

      Message? received;
      InfobipMobilemessaging.on(LibraryEvent.messageReceived, (Message msg) {
        received = msg;
      });

      expect(received, isNull);
    });

    // -------------------------------------------------------------------------
    // Buffer cap: only the most recent _maxBufferSizePerEvent (10) events are
    // kept. Oldest are evicted so memory is bounded even if no callback is
    // ever registered.
    // -------------------------------------------------------------------------
    test('buffer cap evicts oldest events and keeps most recent 10', () {
      // Push 12 events; cap is 10, so the first 2 should be dropped.
      for (int i = 1; i <= 12; i++) {
        InfobipMobilemessaging.handleEventForTesting(
          _notificationTappedJson(customPayload: {'order': '$i'}),
        );
      }

      final received = <Message>[];
      InfobipMobilemessaging.on(LibraryEvent.notificationTapped, (Message msg) {
        received.add(msg);
      });

      expect(received.length, equals(10));
      expect(received.first.customPayload, equals({'order': '3'}));
      expect(received.last.customPayload, equals({'order': '12'}));
    });

    // -------------------------------------------------------------------------
    // Error isolation: a throwing callback must not prevent remaining buffered
    // events from being replayed.
    // -------------------------------------------------------------------------
    test('replay error in one callback does not skip remaining buffered events', () {
      InfobipMobilemessaging.handleEventForTesting(
        _notificationTappedJson(customPayload: {'order': '1'}),
      );
      InfobipMobilemessaging.handleEventForTesting(
        _notificationTappedJson(customPayload: {'order': '2'}),
      );
      InfobipMobilemessaging.handleEventForTesting(
        _notificationTappedJson(customPayload: {'order': '3'}),
      );

      final received = <Map<String, dynamic>?>[];
      int callCount = 0;

      InfobipMobilemessaging.on(LibraryEvent.notificationTapped, (Message msg) {
        callCount++;
        if (callCount == 2) throw Exception('simulated callback error');
        received.add(msg.customPayload);
      });

      // All 3 events were attempted; the throwing one is logged and skipped.
      expect(callCount, equals(3));
      expect(received.length, equals(2));
      expect(received[0], equals({'order': '1'}));
      expect(received[1], equals({'order': '3'}));
    });
  });
}
