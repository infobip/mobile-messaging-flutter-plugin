import 'package:flutter/material.dart';

import '../screens/cloud_inbox.dart';
import '../screens/screen_one.dart';
import '../screens/screen_two.dart';
import '../screens/sign_in_http.dart';

class Page {
  String name;
  String route;
  WidgetBuilder builder;

  Page({required this.name, required this.route, required this.builder});
}

final pages = [
  Page(
    name: 'Cloud Inbox Demo',
    route: '/cloud_inbox',
    builder: (context) => const CloudInboxScreen(),
  ),
  Page(
    name: 'Personalize',
    route: '/signin_http',
    builder: (context) => const SignInHttpDemo(),
  ),
  Page(
    name: 'screen_one',
    route: '/screen_one',
    builder: (context) => const ScreenOneDemo(),
  ),
  Page(
    name: 'screen_two',
    route: '/screen_two',
    builder: (context) => const ScreenTwoDemo(),
  ),
];
