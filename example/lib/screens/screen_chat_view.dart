import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/models/chat/chat_view.dart';
import 'package:infobip_mobilemessaging/models/chat/chat_view_event.dart';
import 'package:infobip_mobilemessaging/models/chat/widget_info.dart';
import 'package:infobip_mobilemessaging/models/chat/chat_view_attachment.dart';

class ChatViewDemo extends StatefulWidget {
  const ChatViewDemo({super.key});

  @override
  State createState() => _ChatViewDemoState();
}

class _ChatViewDemoState extends State<ChatViewDemo> {
  ChatViewController? _chatViewController;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String currentChatView = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter ChatView example'),
        leading: new IconButton(
          icon: new Icon(Icons.arrow_back),
          onPressed: () async {
            bool? isMultithread = await _chatViewController?.isMultithread();
            if (isMultithread == true) {
              if (currentChatView == 'LOADING_THREAD' || currentChatView == 'THREAD' || currentChatView == 'CLOSED_THREAD') {
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
            icon: Icon(Icons.call),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
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
  }

  // load default
  void _onNativeViewCreated(ChatViewController controller) {
    _chatViewController = controller;
    _subscribeToEvents();
  }

  void _subscribeToEvents() {
    if (!mounted) return;
    _chatViewController?.on(
        ChatViewEvent.chatViewChanged, (String chatView) => {
          log('[screen_chat_view] chat view changed: $chatView'),
          currentChatView = chatView
        }
    );
  }
}
