package org.infobip.plugins.mobilemessaging.flutter.chat;

/**
 * ChatViewEvent class contains event names that are used to communicate between Flutter and Android.
 * Event name must match definition on Flutter side in chat_view_event.dart file.
 */
public class ChatViewEvent {

    public static final String EVENT_WIDGET_THEME_CHANGED = "chatView.chatWidgetThemeChanged";
    public static final String EVENT_WIDGET_INFO_UPDATED = "chatView.chatWidgetInfoUpdated";
    public static final String EVENT_CHAT_VIEW_CHANGED = "chatView.chatViewChanged";
    public static final String EVENT_ATTACHMENT_PREVIEW_OPENED = "chatView.attachmentPreviewOpened";
    public static final String EVENT_CHAT_LOADED = "chatView.chatLoaded";
    public static final String EVENT_CHAT_DISCONNECTED = "chatView.chatDisconnected";
    public static final String EVENT_CHAT_RECONNECTED = "chatView.chatReconnected";
    public static final String EVENT_EXIT_CHAT_PRESSED = "chatView.exitChatPressed";
    public static final String EVENT_CHAT_RAW_MESSAGE_RECEIVED = "chatView.chatRawMessageReceived";

}
