import 'dart:developer';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/configurations/configuration.dart' as mmconf;

import '../chat_customization.dart' as chat_customization;
import '../screens/screen_chat_safearea.dart';
import '../screens/screen_chat_view.dart';
import '../utils/language.dart';

class ChatExamples {

  static Future<void> handleKeyboardAppearance(bool isHandledNatively) async {
    if (Platform.isIOS) {
      Object customization = mmconf.ChatCustomization(
         shouldHandleKeyboardAppearance: isHandledNatively,
      );
      InfobipMobilemessaging.setChatCustomization(customization);
    }
  }

   static showChatExamplesDialog(BuildContext context) {
    final children = <Widget>[
      SimpleDialogOption(
        child: Text('Show chat screen'),
        onPressed: () {
          // InfobipMobilemessaging.setJwt('your JWT'); // Comment out to automatically log-in using authentication
          handleKeyboardAppearance(true);
          InfobipMobilemessaging.showChat();
        },
      ),
      SimpleDialogOption(
        child: Text('Show chat screen customized'),
        onPressed: () {
          InfobipMobilemessaging.setChatCustomization(
            chat_customization.customBranding,
          );
          InfobipMobilemessaging.setWidgetTheme('dark');
          InfobipMobilemessaging.showChat();
        },
      ),
      SimpleDialogOption(
        child: Text('Set Chat Language'),
        onPressed: () {
          ChatExamples.showChatLanguageDialog(context);
        },
      ),
      SimpleDialogOption(
        child: Text('Show Chat View Only'),
        onPressed: () {
          handleKeyboardAppearance(false);
          ChatExamples.showChatViewOnlyDialog(context, false);
        },
      ),
      SimpleDialogOption(
        child: Text('Show Chat View With SafeArea'),
        onPressed: () {
           handleKeyboardAppearance(false);
          ChatExamples.showChatViewOnlyDialog(context, true);
        },
      ),
      SimpleDialogOption(
        child: Text('Enable calls'),
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
        child: Text('Disable calls'),
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
      title: const Text('Choose Chat Example'),
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
    final children = <Widget>[];

    if (withSafeArea) {
      showDialog(
        context: context,
        builder: (BuildContext context) => const ChatViewDemoSafeArea(),
      );
    } else {
       showDialog(
        context: context,
        builder: (BuildContext context) => const ChatViewDemo(),
      );
    }
  }
}
