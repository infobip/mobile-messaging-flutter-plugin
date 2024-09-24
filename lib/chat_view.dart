import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/gestures.dart';
import 'package:infobip_mobilemessaging/models/chat_view_attachment.dart';
import 'package:infobip_mobilemessaging/models/chat_view_event.dart';
import 'package:infobip_mobilemessaging/models/widget_info.dart';

typedef FlutterChatViewCreatedCallback = void Function(
    ChatViewController controller);

class ChatView extends StatelessWidget {
  static const StandardMessageCodec _decoder = StandardMessageCodec();
  final FlutterChatViewCreatedCallback onNativeViewCreated;
  final bool? withInput;
  final bool? withToolbar;

  const ChatView({
    Key? key,
    this.withInput,
    this.withToolbar,
    required this.onNativeViewCreated,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<String, Object?> args = {};
    if (this.withToolbar != null) args["withToolbar"] = this.withToolbar;
    if (this.withInput != null) args["withInput"] = this.withInput;

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: 'infobip_mobilemessaging/flutter_chat_view',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: args,
          creationParamsCodec: _decoder,
          gestureRecognizers: [            
              new Factory<OneSequenceGestureRecognizer>( 
                () => new EagerGestureRecognizer(), 
                ),          
              ].toSet(),         
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: 'infobip_mobilemessaging/flutter_chat_view',
          onPlatformViewCreated: _onPlatformViewCreated,
          creationParams: args,
          creationParamsCodec: _decoder,
          gestureRecognizers: [            
              new Factory<OneSequenceGestureRecognizer>( 
                () => new EagerGestureRecognizer(), 
                ),          
              ].toSet(),  
        );
      default:
        return Text(
            '$defaultTargetPlatform is not yet supported by the infobip_mobilemessaging plugin');
    }
  }

  void _onPlatformViewCreated(int id) =>
      onNativeViewCreated(ChatViewController._(id));
}

class ChatViewController {
  ChatViewController._(int id)
      : _channel = MethodChannel('infobip_mobilemessaging/flutter_chat_view_$id'),
        _chatEvent = EventChannel('infobip_mobilemessaging/flutter_chat_view_$id/events') {
    _eventsSubscription = _chatEvent.receiveBroadcastStream().listen(
      (dynamic event) {
        log('[ChatViewController] Received event: $event');
        ChatViewEvent chatViewEvent = ChatViewEvent.fromJson(jsonDecode(event));
        if (_callbacks.containsKey(chatViewEvent.eventName)) {
          _callbacks[chatViewEvent.eventName]?.forEach((callback) {
            log('[ChatViewController] Calling ${chatViewEvent.eventName} with payload ${chatViewEvent.payload == null ? 'NULL' : chatViewEvent.payload.toString()}');
            if (chatViewEvent.eventName == ChatViewEvent.chatWidgetInfoUpdated) {
              callback(WidgetInfo.fromJson(chatViewEvent.payload));
            } else if (chatViewEvent.eventName == ChatViewEvent.attachmentPreviewOpened) {
              callback(ChatViewAttachment.fromJson(chatViewEvent.payload));
            } else if (chatViewEvent.payload != null) {
              callback(chatViewEvent.payload);
            } else {
              callback(chatViewEvent.eventName);
            }
          });
        }
      },
      onError: (dynamic error) {
        log('[ChatViewController] Received error: ${error.message}');
      },
      cancelOnError: true,
    );
  }

  final MethodChannel _channel;
  final EventChannel _chatEvent;
  StreamSubscription<dynamic>? _eventsSubscription;
  Map<String, List<Function>?> _callbacks = HashMap();

  /// Navigates chat from [THREAD] back to [THREAD_LIST] destination in multithread chat.
  /// It does nothing if widget is not multithread.
  /// All multi-thread chat destinations:
  /// LOADING, THREAD_LIST, LOADING_THREAD, THREAD, CLOSED_THREAD, SINGLE_MODE_THREAD
  void showThreadsList() async {
    await _channel.invokeMethod('showThreadsList');
  }

  /// Set the language of the chat.
  /// Parameter [language] in locale format e.g.: en-US
  void setLanguage(String language) async {
    await _channel.invokeMethod('setLanguage', language);
  }

  /// Set contextual data of the chat.
  /// If the function is called when the chat is loaded data will be sent immediately, otherwise they will be sent to the chat once it is loaded.
  /// Every function invocation will overwrite the previous contextual data.
  /// See [ChatViewEvent.chatLoaded] to detect if chat is loaded.
  /// Parameter [data] in JSON string format
  /// Parameter [allMultiThreadStrategy] multithread strategy flag, true -> ALL, false -> ACTIVE
  void sendContextualData(String data, bool allMultiThreadStrategy) async {
    await _channel.invokeMethod(
      'sendContextualData',
      {
        'data': data,
        'allMultiThreadStrategy': allMultiThreadStrategy,
      },
    );
  }

  /// Set the theme of the Livechat Widget.
  /// You can define widget themes in [https://portal.infobip.com/apps/livechat/widgets](Live chat widget setup page) in Infobip Portal, section `Advanced customization`.
  /// Please check widget [https://www.infobip.com/docs/live-chat/widget-customization](documentation) for more details.
  ///
  /// Function allows to change widget theme while chat is shown - in runtime.
  /// If you set widget theme before chat is initialized by [InAppChatView.init] the theme will be used once chat is loaded.
  ///
  /// Parameter [widgetTheme] unique theme name, empty or blank value is ignored.
  void setWidgetTheme(String widgetTheme) async {
    await _channel.invokeMethod('setWidgetTheme', widgetTheme);
  }

  /// Sends draft message to be show in chat to peer's chat.
  /// Parameter [draft] message to be sent
  void sendChatMessageDraft(String draft) async {
    await _channel.invokeMethod('sendChatMessageDraft', draft);
  }

  /// Sends message to the chat.
  /// Parameter [message] message to be send, max length allowed is 4096 characters
  void sendChatMessage(String message) async {
    final Map<String, dynamic> args = <String, dynamic>{};
    args['message'] = message;
    await _channel.invokeMethod('sendChatMessage', args);
  }

  /// Sends attachment to the chat.
  /// Parameter [attachment] attachment to be send
  void sendChatAttachment(ChatViewAttachmentData attachment) async {
    final Map<String, dynamic> args = attachment.toJson();
    await _channel.invokeMethod('sendChatMessage', args);
  }

  /// Returns true if chat is synchronized and multithread feature is enabled, otherwise returns false.
  Future<bool> isMultithread() async {
    return await _channel.invokeMethod('isMultithread');
  }

  /// Registers a callback for the given event name.
  /// [ChatViewEvent] class provides constants of all available events names
  Future<void> on(String eventName, Function callback) async {
    if (_callbacks.containsKey(eventName)) {
      var existed = _callbacks[eventName];
      existed?.add(callback);
      _callbacks.update(eventName, (val) => existed);
    } else {
      _callbacks.putIfAbsent(eventName, () => List.of([callback]));
    }
    _eventsSubscription?.resume();
  }

  /// Unregisters a callback for the given event name.
  Future<void> unregister(String eventName, Function? callback) async {
    if (_callbacks.containsKey(eventName)) {
      var existed = _callbacks[eventName];
      existed?.remove(callback);
      _callbacks.remove(eventName);
      _callbacks.putIfAbsent(eventName, () => existed);
    }
    _eventsSubscription?.resume();
  }

  /// Unregisters all callbacks for the given event name.
  Future<void> unregisterAllHandlers(String eventName) async {
    if (_callbacks.containsKey(eventName)) {
      _callbacks.removeWhere((key, value) => key == eventName);
    }
    _eventsSubscription?.resume();
  }

}

class ChatViewAttachmentData {
  final String dataBase64;
  final String mimeType;
  final String fileName;

  ChatViewAttachmentData({
    required this.dataBase64,
    required this.mimeType,
    required this.fileName,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['dataBase64'] = dataBase64;
    data['mimeType'] = mimeType;
    data['fileName'] = fileName;
    return data;
  }
}
