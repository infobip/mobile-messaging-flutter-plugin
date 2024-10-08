package org.infobip.plugins.mobilemessaging.flutter.chat;

import android.app.Activity;
import android.content.Context;
import android.src.main.java.org.infobip.plugins.mobilemessaging.flutter.chat.ChatViewEvent;
import android.src.main.java.org.infobip.plugins.mobilemessaging.flutter.common.StreamHandler;
import android.util.Log;
import android.view.View;
import android.view.ViewGroup;
import android.view.ViewTreeObserver;

import org.infobip.mobile.messaging.chat.attachments.InAppChatMobileAttachment;
import org.infobip.mobile.messaging.chat.utils.LocalizationUtils;
import org.infobip.mobile.messaging.chat.view.InAppChatFragment;
import org.infobip.mobile.messaging.api.chat.WidgetInfo;
import org.infobip.mobile.messaging.chat.core.InAppChatWidgetView;
import org.infobip.plugins.mobilemessaging.flutter.common.ErrorCodes;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.Locale;
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
        }
        else {
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
                showMultiThread(result);
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
                LocalizationUtils localizationUtils = LocalizationUtils.getInstance(context);
                Locale locale = localizationUtils.localeFromString(language);
                fragment.setLanguage(locale);
                result.success(RESULT_SUCCESS);
            }
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void sendContextualData(MethodCall call, final MethodChannel.Result result) {
        if (fragment != null && fragment.isAdded()) {
            String data = call.argument("data");
            Boolean allMultiThreadStrategy = call.argument("allMultiThreadStrategy");
            if (data == null || data.isEmpty() || allMultiThreadStrategy == null) {
                result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "Cannot send contextual data. Data or allMultiThreadStrategy is missing.", null);
            } else {
                fragment.sendContextualData(data, allMultiThreadStrategy);
                result.success(RESULT_SUCCESS);
            }
        } else {
            result.error(ErrorCodes.CHAT_VIEW_ERROR.getErrorCode(), "ChatView is not attached.", null);
        }
    }

    private void showMultiThread(final MethodChannel.Result result) {
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
                fragment.sendChatMessageDraft(draft);
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
            InAppChatMobileAttachment attachment = null;
            if (dataBase64 != null && !dataBase64.isEmpty()
                    && mimeType != null && !mimeType.isEmpty()
                    && fileName != null && !fileName.isEmpty()) {
                attachment = new InAppChatMobileAttachment(dataBase64, mimeType, fileName);
            }
            fragment.sendChatMessage(message, attachment);
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
    //endregion

    //region Events
    private InAppChatFragment.EventsListener createEventsListener() {
        return new InAppChatFragment.EventsListener() {

            @Override
            public void onChatRawMessageReceived(@NonNull String rawMessage) {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_RAW_MESSAGE_RECEIVED, rawMessage);
            }

            @Override
            public void onChatWidgetThemeChanged(@NonNull String widgetThemeName) {
                eventHandler.sendEvent(ChatViewEvent.EVENT_WIDGET_THEME_CHANGED, widgetThemeName);
            }

            @Override
            public void onChatWidgetInfoUpdated(@NonNull WidgetInfo widgetInfo) {
                JSONObject payload = widgetInfoToJSON(widgetInfo);
                eventHandler.sendEvent(ChatViewEvent.EVENT_WIDGET_INFO_UPDATED, payload);
            }

            @Override
            public void onChatViewChanged(@NonNull InAppChatWidgetView widgetView) {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_VIEW_CHANGED, widgetView.name());
            }

            @Override
            public boolean onAttachmentPreviewOpened(@Nullable String url, @Nullable String type, @Nullable String caption) {
                JSONObject payload = attachmentToJSON(url, type, caption);
                eventHandler.sendEvent(ChatViewEvent.EVENT_ATTACHMENT_PREVIEW_OPENED, payload);
                return false;
            }

            @Override
            public void onChatControlsVisibilityChanged(boolean isVisible) {
            }

            @Override
            public void onChatLoaded(boolean controlsEnabled) {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_LOADED, controlsEnabled);
            }

            @Override
            public void onChatDisconnected() {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_DISCONNECTED);
            }

            @Override
            public void onChatReconnected() {
                eventHandler.sendEvent(ChatViewEvent.EVENT_CHAT_RECONNECTED);
            }

            @Override
            public void onExitChatPressed() {
                eventHandler.sendEvent(ChatViewEvent.EVENT_EXIT_CHAT_PRESSED);
            }
        };
    }

    /**
     * Creates json from a WidgetInfo object.
     *
     * It is equivalent to the Dart's model in widget_info.dart file.
     *
     * @param widgetInfo WidgetInfo object
     * @return WidgetInfo json
     */
    private static JSONObject widgetInfoToJSON(WidgetInfo widgetInfo) {
        try {
            JSONArray array = null;
            if (widgetInfo.getThemeNames() != null) {
                array = new JSONArray();
                for (String theme : widgetInfo.getThemeNames()) {
                    array.put(theme);
                }
            }
            return new JSONObject()
                    .putOpt("id", widgetInfo.getId())
                    .putOpt("title", widgetInfo.getTitle())
                    .putOpt("primaryColor", widgetInfo.getPrimaryColor())
                    .putOpt("backgroundColor", widgetInfo.getBackgroundColor())
                    .putOpt("maxUploadContentSize", widgetInfo.getMaxUploadContentSize())
                    .putOpt("multiThread", widgetInfo.isMultiThread())
                    .putOpt("multiChannelConversationEnabled", widgetInfo.isMultiChannelConversationEnabled())
                    .putOpt("callsEnabled", widgetInfo.isCallsEnabled())
                    .putOpt("themeNames", array);
        } catch (JSONException e) {
            Log.w(TAG, "Cannot convert WidgetInfo to JSON: " + e.getMessage());
            return null;
        }
    }

    /**
     * Creates json from a chat attachment.
     *
     * It is equivalent to the Dart's model in chat_view_attchment.dart file.
     *
     * @param url chat chat attachment url
     * @param type chat chat attachment type
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
            Log.w(TAG, "Cannot convert chat attachment to JSON: " + e.getMessage());
            return null;
        }
    }

    //endregion

}
