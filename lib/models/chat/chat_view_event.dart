/// ChatView events you can observer and react to.
/// To listen to event you need to register:
/// ```dart
/// ChatViewController.on(ChatViewEvent.chatLoaded, (bool controlsEnabled) => {});
/// ```
class ChatViewEvent {
  /// Event's name.
  final String eventName;

  /// Event's payload.
  final dynamic payload;

  /// Called when chat has been loaded and connection established. Contains bool controlsEnabled, if true there was no error.
  /// It is available only for Android platform.
  static const String chatLoaded = 'chatView.chatLoaded';

  /// Called when chat connection has been stopped.
  static const String chatDisconnected = 'chatView.chatDisconnected';

  /// Called when chat connection has been re-established.
  static const String chatReconnected = 'chatView.chatReconnected';

  /// Called by default ChatView Toolbar back navigation logic to exit chat. You are supposed to hide/remove ChatView.
  /// It is available only for Android platform.
  static const String exitChatPressed = 'chatView.exitChatPressed';

  /// Called when chat theme has changed.
  /// It is available only for Android platform.
  static const String chatWidgetThemeChanged = 'chatView.chatWidgetThemeChanged';

  /// Called when chat WidgetInfo has been updated. It provides information about chat widget.
  /// It is available only for Android platform.
  static const String chatWidgetInfoUpdated = 'chatView.chatWidgetInfoUpdated';

  /// Called when chat view has changed.
  /// Chat view can be one of the following: LOADING, THREAD_LIST, LOADING_THREAD, THREAD, CLOSED_THREAD, SINGLE_MODE_THREAD;
  static const String chatViewChanged = 'chatView.chatViewChanged';

  /// Called when attachment from chat has been interacted.
  /// It is available only for Android platform.
  static const String attachmentPreviewOpened = 'chatView.attachmentPreviewOpened';

  /// Called for every new message in the chat. It provides raw message data.
  /// It is available only for Android platform.
  static const String chatRawMessageReceived = 'chatView.chatRawMessageReceived';

  /// Default constructor with all params.
  ChatViewEvent({
    required this.eventName,
    this.payload,
  });

  /// Parsing [ChatViewEvent] from json.
  factory ChatViewEvent.fromJson(Map<String, dynamic> json) => ChatViewEvent(
        eventName: json['eventName'] as String,
        payload: (json['payload'] != null) ? json['payload'] as dynamic : null,
      );
}
