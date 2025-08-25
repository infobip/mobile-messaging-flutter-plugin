import 'package:flutter/material.dart';

import '../screens/chat/screen_chat_authentication.dart';
import '../screens/chat/screen_chat_view.dart';
import '../screens/chat/screen_chat_view_safe_area.dart';
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
    name: 'First Screen',
    route: '/screen_one',
    builder: (context) => const ScreenOneDemo(),
  ),
  Page(
    name: 'Second Screen',
    route: '/screen_two',
    builder: (context) => const ScreenTwoDemo(),
  ),
];

final appNavigationRoutes = pages + [
  Page(
    name: ChatViewScreen.title,
    route: ChatViewScreen.route,
    builder: (context) => const ChatViewScreen(),
  ),
  Page(
    name: ChatViewSafeAreaScreen.title,
    route: ChatViewSafeAreaScreen.route,
    builder: (context) => const ChatViewSafeAreaScreen(),
  ),
  Page(
    name: ChatAuthenticationScreen.title,
    route: ChatAuthenticationScreen.route,
    builder: (context) => const ChatAuthenticationScreen(),
  ),
];

