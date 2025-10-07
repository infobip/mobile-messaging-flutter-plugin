//
//  dialog_chat_examples.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/configurations/configuration.dart';

import '../../../utils/chat_language.dart';
import '../../utils/chat_customization.dart' as chat_customization;
import 'screen_chat_authentication.dart';
import 'screen_chat_view.dart';
import 'screen_chat_view_safe_area.dart';

class ChatExamples {
  static Future<void> handleKeyboardAppearance(bool isHandledNatively) async {
    if (Platform.isIOS) {
      ChatCustomization customization = ChatCustomization(
        shouldHandleKeyboardAppearance: isHandledNatively,
      );
      InfobipMobilemessaging.setChatCustomization(customization);
    }
  }

  static showChatExamplesDialog(BuildContext context) {
    final children = <Widget>[
      SimpleDialogOption(
        child: const Text('Show chat screen'),
        onPressed: () {
          handleKeyboardAppearance(true);
          InfobipMobilemessaging.showChat();
          // Uncomment to use custom exception handler
          // InfobipMobilemessaging.setChatExceptionHandler((exception) async {
          //   log('Flutter app: New chat exception: $exception');
          // }, (error) {
          //   log('Flutter app: Chat exception handler error: $error');
          // });
        },
      ),
      SimpleDialogOption(
        child: const Text('Show chat screen customized'),
        onPressed: () {
          InfobipMobilemessaging.setChatCustomization(
            chat_customization.customBranding,
          );
          InfobipMobilemessaging.setWidgetTheme('dark');
          InfobipMobilemessaging.showChat();
        },
      ),
      SimpleDialogOption(
        child: const Text('Show ChatView'),
        onPressed: () {
          handleKeyboardAppearance(false);
          ChatExamples.showChatViewOnlyDialog(context, false);
        },
      ),
      SimpleDialogOption(
        child: const Text('Show ChatView with SafeArea'),
        onPressed: () {
          handleKeyboardAppearance(false);
          ChatExamples.showChatViewOnlyDialog(context, true);
        },
      ),
      SimpleDialogOption(
        child: const Text('Authenticated chat'),
        onPressed: () {
          Navigator.pushNamed(context, ChatAuthenticationScreen.route);
        },
      ),
      SimpleDialogOption(
        child: const Text('Set chat Language'),
        onPressed: () {
          ChatExamples.showChatLanguageDialog(context);
        },
      ),
      SimpleDialogOption(
        child: const Text('Enable calls'),
        onPressed: () {
          log('Enabling calls');
          try {
            InfobipMobilemessaging.enableChatCalls();
          } catch (e) {
            log('Failed to enable calls. $e');
          }
        },
      ),
      SimpleDialogOption(
        child: const Text('Disable calls'),
        onPressed: () {
          log('Disabling calls');
          try {
            InfobipMobilemessaging.disableCalls();
          } catch (e) {
            log('Failed to disable calls. $e');
          }
        },
      ),
    ];

    SimpleDialog dialog = SimpleDialog(
      title: const Text('Choose chat example'),
      children: children,
    );

    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  static showChatLanguageDialog(BuildContext context) {
    final children = <Widget>[];

    // Languages imported from utils/languages
    for (var language in languages) {
      children.add(
        SimpleDialogOption(
          child: Text(language.name),
          onPressed: () {
            InfobipMobilemessaging.setLanguage(language.code);
            Navigator.pop(context, true);
          },
        ),
      );
    }

    // set up the SimpleDialog
    SimpleDialog dialog = SimpleDialog(
      title: const Text('Choose Chat Language'),
      children: children,
    );

    // show chat languages dialog
    showDialog(
      context: context,
      builder: (BuildContext context) => dialog,
    );
  }

  static showChatViewOnlyDialog(BuildContext context, bool withSafeArea) {
    if (withSafeArea) {
      Navigator.pushNamed(context, ChatViewSafeAreaScreen.route);
    } else {
      Navigator.pushNamed(context, ChatViewScreen.route);
    }
  }
}
