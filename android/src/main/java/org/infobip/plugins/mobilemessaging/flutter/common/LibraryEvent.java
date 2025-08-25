package org.infobip.plugins.mobilemessaging.flutter.common;

import org.infobip.mobile.messaging.Event;
import org.infobip.mobile.messaging.chat.core.InAppChatEvent;
import org.infobip.mobile.messaging.interactive.InteractiveEvent;

import java.util.HashMap;
import java.util.Map;

public class LibraryEvent {

    public static final String EVENT_TOKEN_RECEIVED = "tokenReceived";
    public static final String EVENT_REGISTRATION_UPDATED = "registrationUpdated";
    public static final String EVENT_INSTALLATION_UPDATED = "installationUpdated";
    public static final String EVENT_USER_UPDATED = "userUpdated";
    public static final String EVENT_PERSONALIZED = "personalized";
    public static final String EVENT_DEPERSONALIZED = "depersonalized";

    public static final String EVENT_NOTIFICATION_TAPPED = "notificationTapped";
    public static final String EVENT_NOTIFICATION_ACTION_TAPPED = "actionTapped";
    public static final String EVENT_MESSAGE_RECEIVED = "messageReceived";
    public static final String EVENT_INAPPCHAT_UNREAD_MESSAGE_COUNTER_UPDATED = "inAppChat.unreadMessageCounterUpdated";
    public static final String EVENT_INAPPCHAT_VIEW_STATE_CHANGED = "inAppChat.viewStateChanged";
    public static final String EVENT_INAPPCHAT_CONFIGURATION_SYNCED = "inAppChat.configurationSynced";
    public static final String EVENT_INAPPCHAT_LIVECHAT_REGISTRATION_ID_UPDATED = "inAppChat.livechatRegistrationIdUpdated";
    public static final String EVENT_INAPPCHAT_AVAILABILITY_UPDATED = "inAppChat.availabilityUpdated";
    public static final String EVENT_INAPPCHAT_JWT_REQUESTED = "inAppChat.internal.jwtRequested";

    public static final Map<String, String> broadcastEventMap = new HashMap<String, String>() {{
        put(Event.TOKEN_RECEIVED.getKey(), EVENT_TOKEN_RECEIVED);
        put(Event.REGISTRATION_CREATED.getKey(), EVENT_REGISTRATION_UPDATED);
        put(Event.INSTALLATION_UPDATED.getKey(), EVENT_INSTALLATION_UPDATED);
        put(Event.USER_UPDATED.getKey(), EVENT_USER_UPDATED);
        put(Event.PERSONALIZED.getKey(), EVENT_PERSONALIZED);
        put(Event.DEPERSONALIZED.getKey(), EVENT_DEPERSONALIZED);
        put(InteractiveEvent.NOTIFICATION_ACTION_TAPPED.getKey(), EVENT_NOTIFICATION_ACTION_TAPPED);
        put(InAppChatEvent.UNREAD_MESSAGES_COUNTER_UPDATED.getKey(), EVENT_INAPPCHAT_UNREAD_MESSAGE_COUNTER_UPDATED);
        put(InAppChatEvent.CHAT_VIEW_CHANGED.getKey(), EVENT_INAPPCHAT_VIEW_STATE_CHANGED);
        put(InAppChatEvent.CHAT_CONFIGURATION_SYNCED.getKey(), EVENT_INAPPCHAT_CONFIGURATION_SYNCED);
        put(InAppChatEvent.LIVECHAT_REGISTRATION_ID_UPDATED.getKey(), EVENT_INAPPCHAT_LIVECHAT_REGISTRATION_ID_UPDATED);
        put(InAppChatEvent.IN_APP_CHAT_AVAILABILITY_UPDATED.getKey(), EVENT_INAPPCHAT_AVAILABILITY_UPDATED);
    }};

    public static final Map<String, String> messageBroadcastEventMap = new HashMap<String, String>() {{
        put(Event.MESSAGE_RECEIVED.getKey(), EVENT_MESSAGE_RECEIVED);
        put(Event.NOTIFICATION_TAPPED.getKey(), EVENT_NOTIFICATION_TAPPED);
    }};

}
