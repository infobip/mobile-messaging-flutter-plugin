import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/models/chat/chat_view.dart';
import 'package:infobip_mobilemessaging/models/chat/chat_view_event.dart';

import '../../main.dart';

class ChatViewSafeAreaScreen extends StatefulWidget {
  const ChatViewSafeAreaScreen({super.key});

  static const title = 'Flutter ChatView with SafeArea';
  static const route = '/screen_chat_view_safe_area';

  @override
  State createState() => _ChatViewSafeAreaScreenState();
}

class _ChatViewSafeAreaScreenState extends State<ChatViewSafeAreaScreen> {
  ChatViewController? _chatViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String currentChatView = '';

  @override
  bool? resizeToAvoidBottomInset() => true;

  @override
  Color? scaffoldBackgroundColor() => Colors.white;

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).primaryColor,
          title: const Text(ChatViewSafeAreaScreen.title),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              bool? isMultithread = await _chatViewController?.isMultithread();
              if (isMultithread == true) {
                if (currentChatView == 'LOADING_THREAD' ||
                    currentChatView == 'THREAD' ||
                    currentChatView == 'CLOSED_THREAD') {
                  _chatViewController?.showThreadsList();
                } else {
                  Navigator.pop(context);
                }
              } else {
                Navigator.pop(context);
              }
            },
          ),
          actions: [
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.call),
            ),
            IconButton(
              onPressed: () {},
              icon: const Icon(Icons.more_vert),
            ),
          ],
          automaticallyImplyLeading: false,
        ),
        body: Column(
          children: [
            Expanded(
              child: 
              SafeArea(
                child: ChatView(
                  withInput: true,
                  withToolbar: false,
                  onNativeViewCreated: _onNativeViewCreated,
                ),
              ),
            ),
          ],
        ),
      );

  // load default
  void _onNativeViewCreated(ChatViewController controller) {
    _chatViewController = controller;
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    if (!mounted) return;
    _chatViewController?.on(
      ChatViewEvent.chatViewChanged,
      (String chatView) => {
        log('[screen_chat_view] chat view changed: $chatView'),
        currentChatView = chatView,
      },
    );
  }
}
