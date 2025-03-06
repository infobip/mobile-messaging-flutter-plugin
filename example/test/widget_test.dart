// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:infobip_mobilemessaging_example/main.dart';

void main() {
  testWidgets('Verify menu list', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp());

    List<String> listItems = [
      "Personalize",
      "screen_one",
      "screen_two",
      "Depersonalize",
      "Get Installation Data",
      "Save User Data",
      "Get User Data",
      "Depersonalize Installation",
      "Set Installation as Primary",
      "Show Library Events",
      "Push Demo Application",
      "Send Event",
      "Register Deeplink on Tap",
      "Unregister Deeplink on Tap",
      "Unregister All Handlers",
      "Show Chat"
    ];

    //find all text widgets
    List<Widget> asd = tester.widgetList(find.byType(Text)).toList();
    int n = 0;

    //verify
    for (var element in asd) {
      log("element.toString(): " + element.toString());
      log("listItems[n].toString(): " + listItems[n].toString());
      expect(element.toString().contains(listItems[n]), true, reason: "Not found");
      n += 1;
    }
  });
}
