//
//  ChatPlatformView.java
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

package org.infobip.plugins.mobilemessaging.flutter.chat;

import android.app.Activity;
import android.content.Context;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import org.infobip.mobile.messaging.api.chat.WidgetAttachmentConfig;
import org.infobip.mobile.messaging.api.chat.WidgetInfo;
import org.infobip.mobile.messaging.chat.attachments.InAppChatAttachment;
import org.infobip.mobile.messaging.chat.core.InAppChatException;
import org.infobip.mobile.messaging.chat.core.MultithreadStrategy;
import org.infobip.mobile.messaging.chat.core.widget.LivechatWidgetLanguage;
import org.infobip.mobile.messaging.chat.core.widget.LivechatWidgetMessage;
import org.infobip.mobile.messaging.chat.core.widget.LivechatWidgetResult;
import org.infobip.mobile.messaging.chat.core.widget.LivechatWidgetThread;
import org.infobip.mobile.messaging.chat.core.widget.LivechatWidgetThreads;
import org.infobip.mobile.messaging.chat.core.widget.LivechatWidgetView;
import org.infobip.mobile.messaging.chat.models.MessagePayload;
import org.infobip.mobile.messaging.chat.view.InAppChatFragment;
import org.infobip.plugins.mobilemessaging.flutter.common.ErrorCodes;
import org.infobip.plugins.mobilemessaging.flutter.common.StreamHandler;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Map;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.fragment.app.FragmentActivity;
import androidx.fragment.app.FragmentContainerView;
import androidx.fragment.app.FragmentManager;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.platform.PlatformView;
import kotlin.Unit;

public class ChatPlatformView implements PlatformView, MethodCallHandler {

    private static final String TAG = "ChatPlatformView";
    private static final String RESULT_SUCCESS = "success";
    private MethodChannel methodChannel;
    private EventChannel eventChannel;
    private StreamHandler eventHandler = new StreamHandler(TAG, false);
    private FragmentContainerView container;
    private InAppChatFragment fragment;
    private FragmentManager fm;
    private Context context;
    private static boolean useCustomErrorHandler = false;

    public ChatPlatformView(
            @NonNull Context context,
            int id,
            @Nullable Map<String, Object> creationParams,
            Activity activity,
            BinaryMessenger messenger
    ) {
        this.context = context;
        if (activity instanceof FragmentActivity) {
            fm = ((FragmentActivity) activity).getSupportFragmentManager();
        } else {
            throw new IllegalStateException("Activity must be instance of FragmentActivity to use ChatView.");
        }

        if (android.os.Build.VERSION.SDK_INT >= android.os.Build.VERSION_CODES.JELLY_BEAN_MR1) {
            methodChannel = new MethodChannel(messenger, "infobip_mobilemessaging/flutter_chat_view_" + id);
            methodChannel.setMethodCallHandler(this);
            eventChannel = new EventChannel(messenger, "infobip_mobilemessaging/flutter_chat_view_" + id + "/events");
            eventChannel.setStreamHandler(eventHandler);
            fragment = new InAppChatFragment();
            if (creationParams != null) {
                if (creationParams.containsKey("withInput")) {
                    fragment.setWithInput((Boolean) creationParams.get("withInput"));
                }
                if (creationParams.containsKey("withToolbar")) {
                    fragment.setWithToolbar((Boolean) creationParams.get("withToolbar"));
                }
            }
            fragment.setEventsListener(createEventsListener());
            if (useCustomErrorHandler)
                fragment.setErrorsHandler(createErrorsHandler());
            container = new FragmentContainerView(context);
            container.setLayoutParams(new ViewGroup.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT));
            container.setId(ViewGroup.generateViewId());
            container.getViewTreeObserver().addOnGlobalLayoutListener(new ViewTreeObserver.OnGlobalLayoutListener() {
                @Override
                public void onGlobalLayout() {
                    container.getViewTreeObserver().removeOnGlobalLayoutListener(this);
                    if (!fragment.isAdded()) {
                        fm.beginTransaction()
                                .replace(container.getId(), fragment, InAppChatFragment.class.getSimpleName())
                                .commitNow();
                    }
                }
            });
        } else {
            throw new UnsupportedOperationException("Android API version is too low. Minimum supported version is 21 (Lollipop).");
        }
    }

    @Override
    public View getView() {
        return container;
    }

    @Override
    public void dispose() {
        methodChannel.setMethodCallHandler(null);
        eventChannel.setStreamHandler(null);
    }

    //region MethodCallHandler
    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d(TAG, "onMethodCall: " + call.method.toString());
        switch (call.method) {
            case "setLanguage":
                setLanguage(call, result);
                break;
            case "sendContextualData":
                sendContextualData(call, result);
                break;
            case "showThreadsList":
                showThreadsList(result);
                break;
            case "setWidgetTheme":
                setWidgetTheme(call, result);
                break;
            case "sendChatMessageDraft":
                sendChatMessageDraft(call, result);
                break;
            case "sendChatMessage":
                sendChatMessage(call, result);
                break;
            case "isMultithread":
                isMultithread(result);
                break;
            case "setExceptionHandler":
                setErrorsHandler(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    private void setLanguage(MethodCall call, final MethodChannel.Result result) {
        if (fragment != null && fragment.isAdded()) {
            String language = call.arguments.toString();
            if (language == null || language.isEmpty()) {
                result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "Cannot set ChatView language. Language is null or empty.", null);
            } else {
                LivechatWidgetLanguage widgetLanguage = LivechatWidgetLanguage.findLanguageOrDefault(language);
                fragment.setLanguage(widgetLanguage);
                result.success(RESULT_SUCCESS);
            }
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void sendContextualData(MethodCall call, final MethodChannel.Result result) {
        if (fragment != null && fragment.isAdded()) {
            String data = call.argument("data");
            String chatMultiThreadStrategy = call.argument("chatMultiThreadStrategy");
            if (data == null || data.isEmpty() || chatMultiThreadStrategy == null) {
                result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "Cannot send contextual data. Data or allMultiThreadStrategy is missing.", null);
            } else {
                fragment.sendContextualData(data, MultithreadStrategy.valueOf(chatMultiThreadStrategy));
                result.success(RESULT_SUCCESS);
            }
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void showThreadsList(final MethodChannel.Result result) {
        if (fragment != null && fragment.isAdded()) {
            fragment.showThreadList();
            result.success(RESULT_SUCCESS);
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void setWidgetTheme(MethodCall call, final MethodChannel.Result result) {
        if (fragment != null && fragment.isAdded()) {
            String widgetTheme = call.arguments.toString();
            if (widgetTheme == null || widgetTheme.isEmpty()) {
                result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "Cannot set ChatView widget theme. Widget theme is null or empty.", null);
            } else {
                fragment.setWidgetTheme(widgetTheme);
                result.success(RESULT_SUCCESS);
            }
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void sendChatMessageDraft(MethodCall call, final MethodChannel.Result result) {
        if (fragment != null && fragment.isAdded()) {
            String draft = call.arguments.toString();
            if (draft == null || draft.isEmpty()) {
                result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "Cannot send ChatView draft. Draft is null or empty.", null);
            } else {
                MessagePayload payload = new MessagePayload.Draft(draft);
                fragment.send(payload);
                result.success(RESULT_SUCCESS);
            }
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void sendChatMessage(MethodCall call, final MethodChannel.Result result) {
        if (fragment != null && fragment.isAdded()) {
            String message = call.argument("message");
            String dataBase64 = call.argument("dataBase64");
            String mimeType = call.argument("mimeType");
            String fileName = call.argument("fileName");
            InAppChatAttachment attachment = null;
            if (dataBase64 != null && !dataBase64.isEmpty()
                    && mimeType != null && !mimeType.isEmpty()
                    && fileName != null && !fileName.isEmpty()) {
                attachment = new InAppChatAttachment(dataBase64, mimeType, fileName);
            }
            MessagePayload payload = new MessagePayload.Basic(message, attachment);
            fragment.send(payload);
            result.success(RESULT_SUCCESS);
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void isMultithread(final MethodChannel.Result result) {
        if (fragment != null && fragment.isAdded()) {
            result.success(fragment.isMultiThread());
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void setErrorsHandler(MethodCall call, final MethodChannel.Result result) {
        useCustomErrorHandler = (Boolean) call.arguments;
        if (fragment != null && fragment.isAdded()) {
            if (useCustomErrorHandler)
                fragment.setErrorsHandler(createErrorsHandler());
            else
                fragment.setErrorsHandler(fragment.getDefaultErrorsHandler());
        }
        result.success(RESULT_SUCCESS);
    }
    //endregion

    //region Error handler
    private InAppChatFragment.ErrorsHandler createErrorsHandler() {
        return new InAppChatFragment.ErrorsHandler() {
            @Override
            public boolean handleError(@NonNull InAppChatException exception) {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_EXCEPTION_RECEIVED, exception.toJSON());
                return true;
            }
        };
    }
    //endregion

    //region Events
    private InAppChatFragment.EventsListener createEventsListener() {
        return new InAppChatFragment.EventsListener() {

            @Override
            public void onChatRawMessageReceived(@NonNull String rawMessage) {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_RAW_MESSAGE_RECEIVED, rawMessage);
            }

            @Override
            public void onChatWidgetInfoUpdated(@NonNull WidgetInfo widgetInfo) {
                JSONObject payload = widgetInfoToJSON(widgetInfo);
                eventHandler.sendEvent(ChatViewEvent.EVENT_WIDGET_INFO_UPDATED, payload, true);
            }

            @Override
            public void onChatViewChanged(@NonNull LivechatWidgetView widgetView) {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_VIEW_CHANGED, widgetView.name());
            }

            @Override
            public void onChatControlsVisibilityChanged(boolean isVisible) {
                //Chat controls visibility changed
            }

            @Override
            public void onChatWidgetThemeChanged(@NonNull LivechatWidgetResult<String> result) {
                String widgetThemeName = result.getOrNull();
                if (widgetThemeName != null) {
                    eventHandler.sendEvent(ChatViewEvent.EVENT_WIDGET_THEME_CHANGED, widgetThemeName);
                }
            }

            @Override
            public void onChatLanguageChanged(@NonNull LivechatWidgetResult<String> result) {
                //Chat language changed
            }

            @Override
            public void onChatThreadListShown(@NonNull LivechatWidgetResult<Unit> result) {
                //Chat thread list was shown
            }

            @Override
            public void onChatThreadShown(@NonNull LivechatWidgetResult<LivechatWidgetThread> result) {
                //Chat thread was shown
            }

            @Override
            public void onChatActiveThreadReceived(@NonNull LivechatWidgetResult<LivechatWidgetThread> result) {
                //Chat active thread was received
            }

            @Override
            public void onChatThreadsReceived(@NonNull LivechatWidgetResult<LivechatWidgetThreads> result) {
                //Chat threads were received
            }

            @Override
            public void onChatThreadCreated(@NonNull LivechatWidgetResult<? extends LivechatWidgetMessage> result) {
                //Chat thread created
            }

            @Override
            public void onChatContextualDataSent(@NonNull LivechatWidgetResult<String> result) {
                //Contextual data was sent
            }

            @Override
            public void onChatSent(@NonNull LivechatWidgetResult<? extends LivechatWidgetMessage> result) {
                //Chat message was sent
            }

            @Override
            public void onChatConnectionResumed(@NonNull LivechatWidgetResult<Unit> result) {
                if (result.isSuccess()) {
                    eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_RECONNECTED);
                }
            }

            @Override
            public void onChatConnectionPaused(@NonNull LivechatWidgetResult<Unit> result) {
                if (result.isSuccess()) {
                    eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_DISCONNECTED);
                }
            }

            @Override
            public void onChatLoadingFinished(@NonNull LivechatWidgetResult<Unit> result) {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_LOADED, result.isSuccess());
            }

            @Override
            public void onExitChatPressed() {
                eventHandler.sendEvent(ChatViewEvent.EVENT_EXIT_CHAT_PRESSED);
            }

            @Override
            public boolean onChatAttachmentPreviewOpened(@Nullable String url, @Nullable String type, @Nullable String caption) {
                JSONObject payload = attachmentToJSON(url, type, caption);
                eventHandler.sendEvent(ChatViewEvent.EVENT_ATTACHMENT_PREVIEW_OPENED, payload);
                return false;
            }

        };
    }

    /**
     * Creates json from a WidgetInfo object.
     * <p>
     * It is equivalent to the Dart's model in widget_info.dart file.
     *
     * @param widgetInfo WidgetInfo object
     * @return WidgetInfo json
     */
    private static JSONObject widgetInfoToJSON(WidgetInfo widgetInfo) {
        try {
            JSONArray widgetTheme = null;
            if (widgetInfo.getThemeNames() != null) {
                widgetTheme = new JSONArray();
                for (String theme : widgetInfo.getThemeNames()) {
                    widgetTheme.put(theme);
                }
            }
            JSONObject attachmentConfig = null;
            WidgetAttachmentConfig config = widgetInfo.getAttachmentConfig();
            if (config != null) {
                JSONArray allowedExtensions = null;
                if (config.getAllowedExtensions() != null) {
                    allowedExtensions = new JSONArray();
                    for (String extension : config.getAllowedExtensions()) {
                        allowedExtensions.put(extension);
                    }
                }
                attachmentConfig = new JSONObject()
                        .putOpt("maxSize", config.getMaxSize())
                        .putOpt("isEnabled", config.isEnabled())
                        .putOpt("allowedExtensions", allowedExtensions);
            }
            return new JSONObject()
                    .putOpt("id", widgetInfo.getId())
                    .putOpt("title", widgetInfo.getTitle())
                    .putOpt("primaryColor", widgetInfo.getPrimaryColor())
                    .putOpt("backgroundColor", widgetInfo.getBackgroundColor())
                    .putOpt("primaryTextColor", widgetInfo.getPrimaryTextColor())
                    .putOpt("multiThread", widgetInfo.isMultiThread())
                    .putOpt("multiChannelConversationEnabled", widgetInfo.isMultiChannelConversationEnabled())
                    .putOpt("callsEnabled", widgetInfo.isCallsEnabled())
                    .putOpt("themeNames", widgetTheme)
                    .putOpt("attachmentConfig", attachmentConfig);
        } catch (JSONException e) {
            Log.e(TAG, "Cannot convert WidgetInfo to JSON: " + e.getMessage());
            return null;
        }
    }

    /**
     * Creates json from a chat attachment.
     * <p>
     * It is equivalent to the Dart's model in chat_view_attachment.dart file.
     *
     * @param url     chat chat attachment url
     * @param type    chat chat attachment type
     * @param caption chat chat attachment caption
     * @return chat attachment json
     */
    private static JSONObject attachmentToJSON(
            @Nullable String url, @Nullable String type, @Nullable String caption
    ) {
        try {
            return new JSONObject()
                    .putOpt("url", url)
                    .putOpt("type", type)
                    .putOpt("caption", caption);
        } catch (JSONException e) {
            Log.e(TAG, "Cannot convert chat attachment to JSON: " + e.getMessage());
            return null;
        }
    }

    //endregion

}
