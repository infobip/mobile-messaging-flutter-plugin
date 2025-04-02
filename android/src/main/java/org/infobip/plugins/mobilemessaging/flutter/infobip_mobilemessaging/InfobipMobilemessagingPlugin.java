package org.infobip.plugins.mobilemessaging.flutter.infobip_mobilemessaging;

import static org.infobip.mobile.messaging.inbox.MobileInboxFilterOptionsJson.mobileInboxFilterOptionsFromJSON;
import static org.infobip.mobile.messaging.plugins.MessageJson.bundleToJSON;
import static org.infobip.mobile.messaging.plugins.MessageJson.toJSON;
import static org.infobip.mobile.messaging.plugins.MessageJson.toJSONArray;
import static org.infobip.plugins.mobilemessaging.flutter.common.LibraryEvent.broadcastEventMap;
import static org.infobip.plugins.mobilemessaging.flutter.common.LibraryEvent.messageBroadcastEventMap;
import static org.infobip.plugins.mobilemessaging.flutter.infobip_mobilemessaging.WebRTCUI.defaultWebrtcError;

import android.Manifest;
import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.core.content.ContextCompat;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import com.google.gson.Gson;

import org.infobip.mobile.messaging.BroadcastParameter;
import org.infobip.mobile.messaging.CustomEvent;
import org.infobip.mobile.messaging.Event;
import org.infobip.mobile.messaging.Installation;
import org.infobip.mobile.messaging.Message;
import org.infobip.mobile.messaging.MobileMessaging;
import org.infobip.mobile.messaging.MobileMessagingProperty;
import org.infobip.mobile.messaging.SuccessPending;
import org.infobip.mobile.messaging.User;
import org.infobip.mobile.messaging.chat.InAppChat;
import org.infobip.mobile.messaging.chat.core.widget.LivechatWidgetLanguage;
import org.infobip.mobile.messaging.chat.core.InAppChatEvent;
import org.infobip.mobile.messaging.inbox.Inbox;
import org.infobip.mobile.messaging.inbox.InboxMapper;
import org.infobip.mobile.messaging.inbox.MobileInbox;
import org.infobip.mobile.messaging.inbox.MobileInboxFilterOptions;
import org.infobip.mobile.messaging.interactive.InteractiveEvent;
import org.infobip.mobile.messaging.interactive.MobileInteractive;
import org.infobip.mobile.messaging.interactive.NotificationAction;
import org.infobip.mobile.messaging.interactive.NotificationCategory;
import org.infobip.mobile.messaging.mobileapi.InternalSdkError;
import org.infobip.mobile.messaging.mobileapi.MobileMessagingError;
import org.infobip.mobile.messaging.mobileapi.Result;
import org.infobip.mobile.messaging.plugins.CustomEventJson;
import org.infobip.mobile.messaging.plugins.InstallationJson;
import org.infobip.mobile.messaging.plugins.PersonalizationCtx;
import org.infobip.mobile.messaging.plugins.UserJson;
import org.infobip.mobile.messaging.storage.MessageStore;
import org.infobip.mobile.messaging.util.PreferenceHelper;
import org.infobip.plugins.mobilemessaging.flutter.chat.ChatCustomization;
import org.infobip.plugins.mobilemessaging.flutter.chat.ChatViewFactory;
import org.infobip.plugins.mobilemessaging.flutter.common.ConfigCache;
import org.infobip.plugins.mobilemessaging.flutter.common.Configuration;
import org.infobip.plugins.mobilemessaging.flutter.common.ErrorCodes;
import org.infobip.plugins.mobilemessaging.flutter.common.InitHelper;
import org.infobip.plugins.mobilemessaging.flutter.common.PermissionsRequestManager;
import org.infobip.plugins.mobilemessaging.flutter.common.StreamHandler;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;
import org.infobip.mobile.messaging.chat.core.MultithreadStrategy;

import java.util.ArrayList;
import java.util.Arrays;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import io.flutter.embedding.engine.plugins.FlutterPlugin;
import io.flutter.embedding.engine.plugins.activity.ActivityAware;
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding;
import io.flutter.embedding.engine.plugins.service.ServiceAware;
import io.flutter.embedding.engine.plugins.service.ServicePluginBinding;
import io.flutter.plugin.common.BinaryMessenger;
import io.flutter.plugin.common.EventChannel;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugin.common.MethodChannel.MethodCallHandler;
import io.flutter.plugin.common.PluginRegistry;

/**
 * InfobipMobilemessagingPlugin
 */
public class InfobipMobilemessagingPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, ServiceAware, PermissionsRequestManager.PermissionsRequester, PluginRegistry.RequestPermissionsResultListener {

    public static final String TAG = "MobileMessagingFlutter";

    /// The MethodChannel that will the communication between Flutter and native Android
    ///
    /// This local reference serves to register the plugin with the Flutter Engine and unregister it
    /// when the Flutter Engine is detached from the Activity
    private MethodChannel methodChannel;
    private EventChannel broadcastChannel;

    private StreamHandler broadcastHandler = new StreamHandler(TAG, true);
    private Activity activity = null;
    private BinaryMessenger binaryMessenger = null;
    private PermissionsRequestManager permissionsRequestManager;
    @Nullable
    private ActivityPluginBinding pluginBinding;
    private WebRTCUI webRTCUI = null;
    private ChatViewFactory chatViewFactory = null;

    public InfobipMobilemessagingPlugin() {
        permissionsRequestManager = new PermissionsRequestManager(this);
    }

    @Override
    public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
        Log.d(TAG, "onAttachedToEngine");
        methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "infobip_mobilemessaging");

        binaryMessenger = flutterPluginBinding.getBinaryMessenger();
        broadcastChannel = new EventChannel(binaryMessenger, "infobip_mobilemessaging/broadcast");
        webRTCUI = new WebRTCUI(flutterPluginBinding.getApplicationContext());
        chatViewFactory = new ChatViewFactory(flutterPluginBinding.getBinaryMessenger(), activity);
        flutterPluginBinding.getPlatformViewRegistry().registerViewFactory("infobip_mobilemessaging/flutter_chat_view", chatViewFactory);
    }

    @Override
    public void onDetachedFromEngine(@NonNull FlutterPluginBinding binding) {
        Log.d(TAG, "onDetachedFromEngine");
        methodChannel.setMethodCallHandler(null);
        broadcastChannel.setStreamHandler(null);
    }

    @Override
    public void onMethodCall(@NonNull MethodCall call, @NonNull MethodChannel.Result result) {
        Log.d(TAG, "onMethodCall: " + call.method.toString());
        Log.i(TAG, "activity: " + activity.toString());
        switch (call.method) {
            case "init":
                init(call, result);
                break;
            case "saveUser":
                saveUser(call, result);
                break;
            case "fetchUser":
                fetchUser(result);
                break;
            case "getUser":
                getUser(result);
                break;
            case "saveInstallation":
                saveInstallation(call, result);
                break;
            case "fetchInstallation":
                fetchInstallation(result);
                break;
            case "getInstallation":
                getInstallation(result);
                break;
            case "personalize":
                personalize(call, result);
                break;
            case "depersonalize":
                depersonalize(result);
                break;
            case "depersonalizeInstallation":
                depersonalizeInstallation(call, result);
                break;
            case "setInstallationAsPrimary":
                setInstallationAsPrimary(call, result);
                break;
            case "markMessagesSeen":
                markMessagesSeen(call, result);
                break;
            case "showChat":
                showChat(call, result);
                break;
            case "cleanup":
                cleanup();
                break;
            case "submitEvent":
                submitEvent(call, result);
                break;
            case "submitEventImmediately":
                submitEventImmediately(call, result);
                break;
            case "getMessageCounter":
                getMessageCounter(result);
                break;
            case "resetMessageCounter":
                resetMessageCounter();
                break;
            case "defaultMessageStorage_find":
                defaultMessageStorage_find(call, result);
                break;
            case "defaultMessageStorage_findAll":
                defaultMessageStorage_findAll(result);
                break;
            case "defaultMessageStorage_delete":
                defaultMessageStorage_delete(call, result);
                break;
            case "defaultMessageStorage_deleteAll":
                defaultMessageStorage_deleteAll(result);
                break;
            case "setLanguage":
                setLanguage(call, result);
                break;
            case "sendContextualData":
                sendContextualData(call, result);
                break;
            case "registerForAndroidRemoteNotifications":
                registerForAndroidRemoteNotifications();
                break;
            case "setJwt":
                setJwt(call);
                break;
            case "enableCalls":
                enableCalls(call, result);
                break;
            case "enableChatCalls":
                enableChatCalls(result);
                break;
            case "disableCalls":
                disableCalls(result);
                break;
            case "fetchInboxMessages":
                fetchInboxMessages(call, result);
                break;
            case "fetchInboxMessagesWithoutToken":
                fetchInboxMessagesWithoutToken(call, result);
                break;
            case "setInboxMessagesSeen":
                setInboxMessagesSeen(call, result);
                break;
            case "setChatPushTitle":
                setChatPushTitle(call, result);
                break;
            case "setChatPushBody":
                setChatPushBody(call, result);
                break;
            case "setChatCustomization":
                setChatCustomization(call, result);
                break;
            case "setWidgetTheme":
                setWidgetTheme(call, result);
                break;
            default:
                result.notImplemented();
                break;
        }
    }

    //region ActivityAware
    @Override
    public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
        Log.d(TAG, "onAttachedToActivity");
        activity = binding.getActivity();
        notifyActivityObservers(activity);
        methodChannel.setMethodCallHandler(this);
        broadcastChannel.setStreamHandler(broadcastHandler);
        registerReceiver();
        binding.addRequestPermissionsResultListener(this);
        pluginBinding = binding;
    }

    @Override
    public void onDetachedFromActivityForConfigChanges() {
        Log.d(TAG, "onDetachedFromActivityForConfigChanges");
        activity = null;
        notifyActivityObservers(null);
        if (pluginBinding != null) {
            pluginBinding.removeRequestPermissionsResultListener(this);
        }
    }

    @Override
    public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
        Log.d(TAG, "onReattachedToActivityForConfigChanges");
        activity = binding.getActivity();
        notifyActivityObservers(activity);
        binding.addRequestPermissionsResultListener(this);
        pluginBinding = binding;
    }

    @Override
    public void onDetachedFromActivity() {
        Log.d(TAG, "onDetachedFromActivity");
        activity = null;
        notifyActivityObservers(null);
        if (pluginBinding != null) {
            pluginBinding.removeRequestPermissionsResultListener(this);
        }
    }

    private void notifyActivityObservers(Activity activity) {
        String name = (activity != null) ? String.valueOf(activity.hashCode()) : "null";
        Log.d(TAG, "notifyActivityObservers(Activity=" + name + ")");
        if (chatViewFactory != null) {
            chatViewFactory.setActivity(activity);
        }
    }
    //endregion

    //region ServiceAware
    @Override
    public void onAttachedToService(@NonNull ServicePluginBinding binding) {
        Log.d(TAG, "onAttachedToService");
    }

    @Override
    public void onDetachedFromService() {
        Log.d(TAG, "onDetachedFromService");
    }
    //endregion

    //region Broadcast events
    private final BroadcastReceiver commonLibraryBroadcastReceiver = new BroadcastReceiver() {
        @Override
        public void onReceive(Context context, Intent intent) {
            final String event = broadcastEventMap.get(intent.getAction());
            if (event == null || "".equals(event)) {
                return;
            }

            if (intent.getAction() != null
                    && intent.getAction().equals(InteractiveEvent.NOTIFICATION_ACTION_TAPPED.getKey())
                    && intent.getExtras() != null
            ) {
                final Message message = Message.createFrom(intent.getExtras());
                final NotificationAction notificationAction = NotificationAction.createFrom(intent.getExtras());
                final JSONObject payload = toJSON(message);
                try {
                    payload.put("id", notificationAction.getId());
                    payload.put("inputText", notificationAction.getInputText());
                    broadcastHandler.sendEvent(event, payload);
                } catch (JSONException e) {
                    Log.e(TAG, e.getMessage(), e);
                }
                return;
            }

            if (intent.getAction() != null && intent.getAction().equals(Event.INSTALLATION_UPDATED.getKey())) {
                final JSONObject updatedInstallation = InstallationJson.toJSON(Installation.createFrom(intent.getExtras()));
                broadcastHandler.sendEvent(event, updatedInstallation);
                return;
            }

            if (Event.USER_UPDATED.getKey().equals(intent.getAction()) || Event.PERSONALIZED.getKey().equals(intent.getAction())) {
                JSONObject updatedUser = UserJson.toJSON(User.createFrom(intent.getExtras()));
                broadcastHandler.sendEvent(event, updatedUser);
                return;
            }

            if (Event.DEPERSONALIZED.getKey().equals(intent.getAction())) {
                broadcastHandler.sendEvent(event);
                return;
            }

            final String data;
            if (Event.TOKEN_RECEIVED.getKey().equals(intent.getAction())) {
                data = intent.getStringExtra(BroadcastParameter.EXTRA_CLOUD_TOKEN);
                broadcastHandler.sendEvent(event, data);
            } else if (Event.REGISTRATION_CREATED.getKey().equals(intent.getAction())) {
                data = intent.getStringExtra(BroadcastParameter.EXTRA_INFOBIP_ID);
                broadcastHandler.sendEvent(event, data);
            } else if (InAppChatEvent.CHAT_VIEW_CHANGED.getKey().equals(intent.getAction())) {
                data = intent.getStringExtra(BroadcastParameter.EXTRA_CHAT_VIEW);
                broadcastHandler.sendEvent(event, data);
            } else if (InAppChatEvent.LIVECHAT_REGISTRATION_ID_UPDATED.getKey().equals(intent.getAction())) {
                data = intent.getStringExtra(BroadcastParameter.EXTRA_LIVECHAT_REGISTRATION_ID);
                broadcastHandler.sendEvent(event, data);
            } else if (InAppChatEvent.UNREAD_MESSAGES_COUNTER_UPDATED.getKey().equals(intent.getAction())) {
                int unreadMessagesCount = intent.getIntExtra(BroadcastParameter.EXTRA_UNREAD_CHAT_MESSAGES_COUNT, 0);
                data = String.valueOf(unreadMessagesCount);
                broadcastHandler.sendEvent(event, data);
            } else if (InAppChatEvent.IN_APP_CHAT_AVAILABILITY_UPDATED.getKey().equals(intent.getAction())) {
                boolean isChatAvailable = intent.getBooleanExtra(BroadcastParameter.EXTRA_IS_CHAT_AVAILABLE, false);
                data = String.valueOf(isChatAvailable);
                broadcastHandler.sendEvent(event, data);
            } else {
                broadcastHandler.sendEvent(event);
            }
        }
    };


    private final BroadcastReceiver messageBroadcastReceiver = new BroadcastReceiver() {

        @Override
        public void onReceive(Context context, Intent intent) {
            if (intent.getAction() == null) {
                return;
            }
            final String event = messageBroadcastEventMap.get(intent.getAction());
            if (event == null) {
                Log.w(TAG, "Cannot process event for broadcast: " + intent.getAction());
                return;
            }

            final JSONObject message = bundleToJSON(intent.getExtras());

            broadcastHandler.sendEvent(event, message);
        }
    };


    private void registerReceiver() {

        IntentFilter intentFilter = new IntentFilter();
        for (String action : broadcastEventMap.keySet()) {
            intentFilter.addAction(action);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.registerReceiver(activity.getApplicationContext(), commonLibraryBroadcastReceiver, intentFilter, ContextCompat.RECEIVER_NOT_EXPORTED);
        } else {
            LocalBroadcastManager.getInstance(activity).registerReceiver(commonLibraryBroadcastReceiver, intentFilter);
        }

        IntentFilter messageIntentFilter = new IntentFilter();
        for (String action : messageBroadcastEventMap.keySet()) {
            messageIntentFilter.addAction(action);
        }

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            ContextCompat.registerReceiver(activity.getApplicationContext(), messageBroadcastReceiver, messageIntentFilter, ContextCompat.RECEIVER_NOT_EXPORTED);
        } else {
            LocalBroadcastManager.getInstance(activity).registerReceiver(messageBroadcastReceiver, messageIntentFilter);
        }
    }
    //endregion

    //region Mobile Messaging
    private MobileMessaging mobileMessaging() {
        return MobileMessaging.getInstance(this.activity.getApplicationContext());
    }

    private void init(MethodCall call, final MethodChannel.Result result) {
        Log.d(TAG, "init");

        final Configuration configuration = new Gson().fromJson(call.arguments.toString(), Configuration.class);
        ConfigCache.getInstance().setConfiguration(configuration);

        final InitHelper initHelper = new InitHelper(configuration, activity);
        MobileMessaging.Builder builder = initHelper.configurationBuilder();

        PreferenceHelper.saveString(activity.getApplicationContext(),
                MobileMessagingProperty.SYSTEM_DATA_VERSION_POSTFIX,
                "flutter " + configuration.getPluginVersion());

        builder.build(new MobileMessaging.InitListener() {
            @SuppressLint("MissingPermission")
            @Override
            public void onSuccess() {

                if (configuration.getNotificationCategories() != null) {
                    NotificationCategory categories[] = initHelper.notificationCategoriesFromConfiguration(configuration.getNotificationCategories());
                    if (categories.length > 0) {
                        MobileInteractive.getInstance(activity.getApplication()).setNotificationCategories(categories);
                    }
                }

                // init method is called from WebView when activity is running
                // so we can safely claim that we are in foreground
                initHelper.setForeground();

                result.success("OK");
            }

            @Override
            public void onError(InternalSdkError e, @Nullable Integer googleErrorCode) {
                Log.e(TAG, "Cannot start SDK: " + e.get() + " errorCode: " + googleErrorCode);
                result.error(googleErrorCode.toString(), e.get(), e);
            }
        });
    }

    //region User Profile Management
    public void saveUser(MethodCall call, final MethodChannel.Result result) {
        try {
            JSONObject jsonObject = new JSONObject(call.arguments.toString());
            final User user = UserJson.resolveUser(jsonObject);
            mobileMessaging().saveUser(user, userResultListener(result));
        } catch (IllegalArgumentException | JSONException e) {
            result.error(ErrorCodes.SAVE_USER.getErrorCode(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    public void fetchUser(final MethodChannel.Result result) {
        mobileMessaging().fetchUser(userResultListener(result));
    }

    @NonNull
    private MobileMessaging.ResultListener<User> userResultListener(final MethodChannel.Result resultCallbacks) {
        return new MobileMessaging.ResultListener<User>() {
            @Override
            public void onResult(org.infobip.mobile.messaging.mobileapi.Result<User, MobileMessagingError> result) {
                if (result.isSuccess()) {
                    resultCallbacks.success(UserJson.toJSON(result.getData()).toString());
                } else {
                    resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
                }
            }
        };
    }

    public void getUser(final MethodChannel.Result result) {
        User user = mobileMessaging().getUser();
        result.success(UserJson.toJSON(user).toString());
    }

    public void saveInstallation(MethodCall call, final MethodChannel.Result result) {
        try {
            JSONObject jsonObject = new JSONObject(call.arguments.toString());
            final Installation installation = InstallationJson.resolveInstallation(jsonObject);
            mobileMessaging().saveInstallation(installation, installationResultListener(result));
        } catch (JSONException e) {
            Log.w(TAG, e.getMessage(), e);
            result.error(ErrorCodes.SAVE_INSTALLATION.getErrorCode(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    public void fetchInstallation(final MethodChannel.Result result) {
        mobileMessaging().fetchInstallation(installationResultListener(result));
    }

    @NonNull
    private MobileMessaging.ResultListener<Installation> installationResultListener(final MethodChannel.Result resultCallbacks) {
        return new MobileMessaging.ResultListener<Installation>() {
            @Override
            public void onResult(org.infobip.mobile.messaging.mobileapi.Result<Installation, MobileMessagingError> result) {
                if (result.isSuccess()) {
                    resultCallbacks.success(InstallationJson.toJSON(result.getData()).toString());
                } else {
                    resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
                }
            }
        };
    }

    public void getInstallation(final MethodChannel.Result result) {
        Installation installation = mobileMessaging().getInstallation();
        result.success(InstallationJson.toJSON(installation).toString());
    }

    public void personalize(MethodCall call, final MethodChannel.Result resultCallbacks) {
        try {
            final PersonalizationCtx ctx = PersonalizationCtx.resolvePersonalizationCtx(new JSONObject(call.arguments.toString()));
            mobileMessaging().personalize(ctx.userIdentity, ctx.userAttributes, ctx.forceDepersonalize, ctx.keepAsLead, new MobileMessaging.ResultListener<User>() {
                @Override
                public void onResult(org.infobip.mobile.messaging.mobileapi.Result<User, MobileMessagingError> result) {
                    if (result.isSuccess()) {
                        resultCallbacks.success(UserJson.toJSON(result.getData()).toString());
                    } else {
                        resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
                    }
                }
            });
        } catch (IllegalArgumentException e) {
            resultCallbacks.error(ErrorCodes.PERSONALIZE.getErrorCode(), e.getMessage(), e.getLocalizedMessage());
        } catch (JSONException e) {
            resultCallbacks.error(ErrorCodes.PERSONALIZE.getErrorCode(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    private static final Map<SuccessPending, String> depersonalizeStates = new HashMap<SuccessPending, String>() {{
        put(SuccessPending.Pending, "pending");
        put(SuccessPending.Success, "success");
    }};

    public void depersonalize(final MethodChannel.Result resultCallbacks) {
        mobileMessaging().depersonalize(new MobileMessaging.ResultListener<SuccessPending>() {
            @Override
            public void onResult(Result<SuccessPending, MobileMessagingError> result) {
                if (result.isSuccess()) {
                    resultCallbacks.success(depersonalizeStates.get(result.getData()));
                } else {
                    resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
                }
            }
        });
    }

    public void depersonalizeInstallation(MethodCall call, final MethodChannel.Result result) {
        String pushRegistrationId = call.arguments.toString();
        if (pushRegistrationId.isEmpty()) {
            result.error(ErrorCodes.DEPERSONALIZE_INSTALLATION.getErrorCode(), "Cannot resolve pushRegistrationId from arguments", null);
            return;
        }
        mobileMessaging().depersonalizeInstallation(pushRegistrationId, installationsResultListener(result));
    }

    public void cleanup() {
        mobileMessaging().cleanup();
    }

    public void setInstallationAsPrimary(MethodCall call, final MethodChannel.Result result) {
        String pushRegistrationId = call.argument("pushRegistrationId");
        Boolean primary = call.argument("primary");
        if (pushRegistrationId == null || pushRegistrationId.isEmpty()) {
            result.error(ErrorCodes.DEPERSONALIZE_INSTALLATION.getErrorCode(), "Cannot resolve pushRegistrationId from arguments", null);
            return;
        }
        if (primary == null) {
            result.error(ErrorCodes.DEPERSONALIZE_INSTALLATION.getErrorCode(), "Cannot resolve primary from arguments", null);
            return;
        }
        mobileMessaging().setInstallationAsPrimary(pushRegistrationId, primary, installationsResultListener(result));
    }

    public void submitEvent(MethodCall call, final MethodChannel.Result result) {
        try {
            JSONObject jsonObject = new JSONObject(call.arguments.toString());
            final CustomEvent customEvent = CustomEventJson.fromJSON(jsonObject);
            mobileMessaging().submitEvent(customEvent);
            result.success("Success");
        } catch (JSONException e) {
            Log.w(TAG, e.getMessage(), e);
            result.error(ErrorCodes.CUSTOM_EVENT.getErrorCode(), "Cannot send custom event", null);
        }
    }

    public void submitEventImmediately(MethodCall call, final MethodChannel.Result result) {
        try {
            JSONObject jsonObject = new JSONObject(call.arguments.toString());
            final CustomEvent customEvent = CustomEventJson.fromJSON(jsonObject);
            mobileMessaging().submitEvent(customEvent, customEventResultListener(result));
        } catch (JSONException e) {
            Log.w(TAG, e.getMessage(), e);
            result.error(ErrorCodes.CUSTOM_EVENT.getErrorCode(), "Cannot send custom event", null);
        }
    }

    private synchronized void defaultMessageStorage_find(MethodCall call, final MethodChannel.Result result) {
        String messageId = call.arguments.toString();
        MessageStore messageStore = MobileMessaging.getInstance(activity.getApplicationContext()).getMessageStore();
        if (messageStore == null) {
            result.error(ErrorCodes.MESSAGE_STORAGE_ERROR.getErrorCode(), "Message storage does not exist", null);
            return;
        }

        for (Message m : messageStore.findAll(activity.getApplicationContext())) {
            if (messageId.equals(m.getMessageId())) {
                result.success(toJSON(m).toString());
                return;
            }
        }
        result.success(null);
    }

    private synchronized void defaultMessageStorage_findAll(final MethodChannel.Result result) {
        MessageStore messageStore = MobileMessaging.getInstance(activity.getApplicationContext()).getMessageStore();
        if (messageStore == null) {
            result.error(ErrorCodes.MESSAGE_STORAGE_ERROR.getErrorCode(), "Message storage does not exist", null);
            return;
        }
        List<Message> messages = messageStore.findAll(activity.getApplicationContext());
        result.success(toJSONArray(messages.toArray(new Message[messages.size()])).toString());
    }

    private synchronized void defaultMessageStorage_delete(MethodCall call, final MethodChannel.Result result) {
        String messageId = call.arguments.toString();
        MessageStore messageStore = MobileMessaging.getInstance(activity.getApplicationContext()).getMessageStore();
        if (messageStore == null) {
            result.error(ErrorCodes.MESSAGE_STORAGE_ERROR.getErrorCode(), "Message storage does not exist", null);
            return;
        }

        List<Message> messagesToKeep = new ArrayList<Message>();
        for (Message m : messageStore.findAll(activity.getApplicationContext())) {
            if (messageId.equals(m.getMessageId())) {
                continue;
            }
            messagesToKeep.add(m);
        }
        messageStore.deleteAll(activity.getApplicationContext());
        messageStore.save(activity.getApplicationContext(), messagesToKeep.toArray(new Message[messagesToKeep.size()]));
        result.success(null);
    }

    private synchronized void defaultMessageStorage_deleteAll(final MethodChannel.Result result) {
        MessageStore messageStore = MobileMessaging.getInstance(activity.getApplicationContext()).getMessageStore();
        if (messageStore == null) {
            result.error(ErrorCodes.MESSAGE_STORAGE_ERROR.getErrorCode(), "Message storage does not exist", null);
            return;
        }
        messageStore.deleteAll(activity.getApplicationContext());
        result.success(null);
    }

    @NonNull
    private MobileMessaging.ResultListener<CustomEvent> customEventResultListener(final MethodChannel.Result resultCallbacks) {
        return new MobileMessaging.ResultListener<CustomEvent>() {
            @Override
            public void onResult(org.infobip.mobile.messaging.mobileapi.Result<CustomEvent, MobileMessagingError> result) {
                if (result.isSuccess()) {
                    resultCallbacks.success("Success");
                } else {
                    resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
                }
            }
        };
    }

    @NonNull
    private MobileMessaging.ResultListener<List<Installation>> installationsResultListener(final MethodChannel.Result resultCallbacks) {
        return new MobileMessaging.ResultListener<List<Installation>>() {
            @Override
            public void onResult(org.infobip.mobile.messaging.mobileapi.Result<List<Installation>, MobileMessagingError> result) {
                if (result.isSuccess()) {
                    if (result.getData() == null) {
                        resultCallbacks.success("Success");
                        return;
                    }
                    List<Installation> installations = result.getData();
                    resultCallbacks.success(InstallationJson.toJSON(installations).toString());
                } else {
                    resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
                }
            }
        };
    }

    //endregion

    //region PermissionsRequester for Post Notifications Permission
    public void registerForAndroidRemoteNotifications() {
        Log.w(TAG, "calling register");
        if (activity != null) {
            permissionsRequestManager.isRequiredPermissionsGranted(activity, this);
        } else {
            Log.e(TAG, "Cannot register for remote notifications, activity does not exist");
        }
    }

    @Override
    public boolean onRequestPermissionsResult(int requestCode, String[] permissions, int[] grantResults) {
        if (requestCode == PermissionsRequestManager.REQ_CODE_POST_NOTIFICATIONS_PERMISSIONS) {
            permissionsRequestManager.onRequestPermissionsResult(permissions, grantResults);
        }
        return true;
    }

    @Override
    public void onPermissionGranted() {
        Log.i(TAG, "Post Notification permission granted");
    }

    @NonNull
    @Override
    public String[] requiredPermissions() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            return new String[]{Manifest.permission.POST_NOTIFICATIONS};
        }
        return new String[0];
    }

    @Override
    public boolean shouldShowPermissionsNotGrantedDialogIfShownOnce() {
        return true;
    }

    @Override
    public int permissionsNotGrantedDialogTitle() {
        return org.infobip.mobile.messaging.resources.R.string.mm_post_notifications_settings_title;
    }

    @Override
    public int permissionsNotGrantedDialogMessage() {
        return org.infobip.mobile.messaging.resources.R.string.mm_post_notifications_settings_message;
    }
    //endregion

    //region Inbox
    private void fetchInboxMessages(MethodCall call, MethodChannel.Result result) {
        try {
            String token = call.argument("token");
            String externalUserId = call.argument("externalUserId");
            String json = call.argument("filterOptions");
            JSONObject jsonObj = new JSONObject(json);
            MobileInboxFilterOptions filterOptions = mobileInboxFilterOptionsFromJSON(jsonObj);
            MobileInbox.getInstance(activity.getApplication()).fetchInbox(token, externalUserId, filterOptions, inboxResultListener(result));
        } catch (Exception e) {
            Log.d(TAG, "Failed fetching inbox messages, invalid number of arguments");
            result.error(ErrorCodes.INBOX_ERROR.getErrorCode(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    private void fetchInboxMessagesWithoutToken(MethodCall call, MethodChannel.Result result) {
        try {
            String externalUserId = call.argument("externalUserId");
            String json = call.argument("filterOptions");
            JSONObject jsonObj = new JSONObject(json);
            MobileInboxFilterOptions filterOptions = mobileInboxFilterOptionsFromJSON(jsonObj);
            MobileInbox.getInstance(activity.getApplication()).fetchInbox(externalUserId, filterOptions, inboxResultListener(result));
        } catch (Exception e) {
            Log.d(TAG, "Failed fetching inbox messages, invalid arguments");
            result.error(ErrorCodes.INBOX_ERROR.getErrorCode(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    @NonNull
    private MobileMessaging.ResultListener<Inbox> inboxResultListener(final MethodChannel.Result resultCallbacks) {
        return new MobileMessaging.ResultListener<Inbox>() {
            @Override
            public void onResult(org.infobip.mobile.messaging.mobileapi.Result<Inbox, MobileMessagingError> result) {
                if (result.isSuccess()) {
                    resultCallbacks.success(InboxMapper.toJSON(result.getData()).toString());
                } else {
                    resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
                }
            }
        };
    }

    private void setInboxMessagesSeen(MethodCall call, MethodChannel.Result result) {
        try {
            String externalUserId = call.argument("externalUserId");
            JSONArray json = new JSONArray(Objects.requireNonNull(call.argument("messageIds")).toString());
            String[] messageIds = resolveStringArray(json);
            MobileInbox.getInstance(activity.getApplication()).setSeen(externalUserId, messageIds, setSeenResultListener(result));
        } catch (Exception e) {
            Log.d(TAG, "Failed setting inbox as seen: ");
            result.error(ErrorCodes.INBOX_ERROR.getErrorCode(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    @NonNull
    private MobileMessaging.ResultListener<String[]> setSeenResultListener(final MethodChannel.Result resultCallbacks) {
        return new MobileMessaging.ResultListener<String[]>() {
            @Override
            public void onResult(org.infobip.mobile.messaging.mobileapi.Result<String[], MobileMessagingError> result) {
                if (result.isSuccess()) {
                    resultCallbacks.success(Arrays.toString(result.getData()));
                } else {
                    resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
                }
            }
        };
    }

    private void markMessagesSeen(MethodCall call, MethodChannel.Result result) {
        try {
            JSONArray json = new JSONArray(Objects.requireNonNull(call.argument("messageIds")).toString());
            final String[] messageIds = resolveStringArray(json);
            mobileMessaging().setMessagesSeen(messageIds);
            result.success(call.arguments.toString());
        } catch (Exception e) {
            Log.d(TAG, "Failed marking messages as seen");
            result.error(e.getMessage(), e.getMessage(), e.getLocalizedMessage());
        }

    }

    @NonNull
    private static String[] resolveStringArray(JSONArray args) throws JSONException {
        if (args.length() < 1 || args.getString(0) == null) {
            throw new IllegalArgumentException("Cannot resolve string parameters from arguments");
        }

        String[] array = new String[args.length()];
        for (int i = 0; i < args.length(); i++) {
            array[i] = args.getString(i);
        }

        return array;
    }
    //endregion
    //endregion

    //region InAppChat
    public void showChat(MethodCall call, final MethodChannel.Result result) {
        InAppChat.getInstance(activity.getApplication()).inAppChatScreen().show();
    }

    private void getMessageCounter(final MethodChannel.Result result) {
        result.success(InAppChat.getInstance(activity.getApplication()).getMessageCounter());
    }

    private void resetMessageCounter() {
        InAppChat.getInstance(activity.getApplication()).resetMessageCounter();
    }

    private void setLanguage(MethodCall call, final MethodChannel.Result result) {
        String language = call.arguments.toString();
        if (language == null || language.isEmpty()) {
            result.error(ErrorCodes.SET_LANGUAGE_ERROR.getErrorCode(), "Cannot set in app chat language.", null);
            return;
        }
        LivechatWidgetLanguage widgetLanguage = LivechatWidgetLanguage.findLanguageOrDefault(language);
        InAppChat.getInstance(activity.getApplication()).setLanguage(widgetLanguage);
    }

    private void sendContextualData(MethodCall call, final MethodChannel.Result result) {
        String data = call.argument("data");
        String chatMultiThreadStrategy = call.argument("chatMultiThreadStrategy");
        if (data == null || data.isEmpty() || chatMultiThreadStrategy == null) {
            result.error(ErrorCodes.CONTEXTUAL_METADATA_ERROR.getErrorCode(), "Cannot resolve data or allMultiThreadStrategy from arguments", null);
            return;
        }
        InAppChat.getInstance(activity.getApplication()).sendContextualData(data, MultithreadStrategy.valueOf(chatMultiThreadStrategy));
    }

    private void setJwt(MethodCall call) {
        String jwt = call.arguments.toString();
        InAppChat.getInstance(activity.getApplication()).setWidgetJwtProvider(() -> jwt);
    }

    private void setChatPushTitle(MethodCall call, MethodChannel.Result result) {
        try {
            @Nullable String title = call.arguments();
            InAppChat.getInstance(activity.getApplication()).setChatPushTitle(title);
        } catch (Exception e) {
            Log.d(TAG, "Failed setting chat push title");
            result.error(e.getMessage(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    private void setChatPushBody(MethodCall call, MethodChannel.Result result) {
        try {
            @Nullable String body = call.arguments();
            InAppChat.getInstance(activity.getApplication()).setChatPushBody(body);
        } catch (Exception e) {
            Log.d(TAG, "Failed setting chat push body");
            result.error(e.getMessage(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    private void setChatCustomization(MethodCall call, MethodChannel.Result result) {
        try {
            ChatCustomization customization = new Gson().fromJson(call.arguments.toString(), ChatCustomization.class);
            InAppChat.getInstance(activity.getApplication()).setTheme(customization.createTheme(activity));
        } catch (Exception e) {
            Log.d(TAG, "Failed to set customization", e);
            result.error(e.getMessage(), e.getMessage(), e.getLocalizedMessage());
        }
    }

    private void setWidgetTheme(MethodCall call, final MethodChannel.Result result) {
        String widgetTheme = call.arguments.toString();
        if (widgetTheme == null || widgetTheme.isEmpty()) {
            result.error(ErrorCodes.SET_WIDGET_THEME_ERROR.getErrorCode(), "Cannot set in app chat widget theme. Widget theme is null or empty.", null);
            return;
        }
        InAppChat.getInstance(activity.getApplication()).setWidgetTheme(widgetTheme);
    }
    //endregion

    //region WebRtcUi
    private void disableCalls(MethodChannel.Result result) {
        webRTCUI.disableCalls(() -> result.success(null), defaultWebrtcError(result));
    }

    private void enableCalls(MethodCall call, MethodChannel.Result result) {
        Object args = call.arguments;
        String identity = null;
        if (args != null) {
            identity = args.toString();
        }
        webRTCUI.enableCalls(identity, () -> result.success(null), defaultWebrtcError(result));
    }

    private void enableChatCalls(MethodChannel.Result result) {
        webRTCUI.enableChatCalls(() -> result.success(null), defaultWebrtcError(result));
    }
    //endregion

}
