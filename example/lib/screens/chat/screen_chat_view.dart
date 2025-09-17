import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/models/chat/chat_view.dart';
import 'package:infobip_mobilemessaging/models/chat/chat_view_event.dart';

class ChatViewScreen extends StatefulWidget {
  const ChatViewScreen({super.key});

  static const title = 'Flutter ChatView';
  static const route = '/screen_chat_view';

  @override
  State createState() => _ChatViewScreenState();
}

class _ChatViewScreenState extends State<ChatViewScreen> {
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text(ChatViewScreen.title),
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
        ),
        body: Column(
          children: [
            Expanded(
              child: ChatView(
                withInput: true,
                withToolbar: false,
                onNativeViewCreated: _onNativeViewCreated,
              ),
            ),
          ],
        ),
      );

  // load default
  void _onNativeViewCreated(ChatViewController controller) {
    _chatViewController = controller;
    _subscribeToEvents();
    // Uncomment to use custom exception handler
    // _setCustomErrorHandler();
  }

  void _subscribeToEvents() {
    if (!mounted) return;
    _chatViewController?.on(
      ChatViewEvent.chatViewChanged,
      (String chatView) => {
        log('Flutter app: Chat view changed: $chatView'),
        currentChatView = chatView,
      },
    );
  }

  void _setCustomErrorHandler() {
    log('Flutter app: Setting custom chat view exception handler');
    _chatViewController?.setExceptionHandler((exception) async {
      log('Flutter app: New chat view exception: $exception');
    }, (error) {
      log('Flutter app: Chat view exception handler error: $error');
    });
  }
}
