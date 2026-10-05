//
//  widget_test.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

///
/// This is a basic Flutter widget test.
///
/// To perform an interaction with a widget in your test, use the WidgetTester
/// utility that Flutter provides. For example, you can send tap and scroll
/// gestures. You can also use WidgetTester to find child widgets in the widget
/// tree, read text, and verify that the values of widget properties are correct.
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:infobip_mobilemessaging_example/main.dart';

void main() {
  testWidgets('Verify menu list', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Tiles of the home page, in the order they are declared in homepage.dart.
    const listItems = [
      'Cloud Inbox Demo',
      'Personalize',
      'First Screen',
      'Second Screen',
      'Chat Examples',
      'Depersonalize',
      'Get Installation Data',
      'Fetch Installation Data',
      'Save User Data',
      'Fetch User Data',
      'Get User Data',
      // 'Register For Android 13 Notifications' / 'Register For iOS Notifications' depend on the host platform
      'Depersonalize Installation',
      'Set Installation as Primary',
      'Show Library Events',
      'Send Event',
      'Unregister All Handlers',
      'MessageStorage: findAll',
      'MessageStorage: Find First Message',
      'MessageStorage: Delete First Message',
      'MessageStorage: deleteAll',
    ];

    // Deeplinks are handled out of the box for both tap events, the manual register/unregister tiles are gone.
    const removedItems = [
      'Register Deeplink on Tap',
      'Unregister Deeplink on Tap',
    ];

    // Collect all tile titles by scrolling through the list until no new ones appear.
    final list = find.byType(ListView).first;
    final seenTitles = <String>{};
    while (true) {
      final before = seenTitles.length;
      seenTitles.addAll(tester.widgetList<Text>(find.byType(Text)).map((text) => text.data).whereType<String>());
      if (seenTitles.length == before) break;
      await tester.drag(list, const Offset(0, -300));
      await tester.pumpAndSettle();
    }

    for (final item in listItems) {
      expect(seenTitles, contains(item), reason: "'$item' not found");
    }
    for (final item in removedItems) {
      expect(seenTitles, isNot(contains(item)), reason: "'$item' should no longer be shown");
    }
  });
}
