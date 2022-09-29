package org.infobip.plugins.mobilemessaging.flutter.infobip_mobilemessaging;

import static org.infobip.plugins.mobilemessaging.flutter.common.LibraryEvent.broadcastEventMap;
import static org.infobip.plugins.mobilemessaging.flutter.common.LibraryEvent.messageBroadcastEventMap;

import android.annotation.SuppressLint;
import android.app.Activity;
import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.content.IntentFilter;
import android.os.Bundle;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.localbroadcastmanager.content.LocalBroadcastManager;

import org.infobip.mobile.messaging.BroadcastParameter;
import org.infobip.mobile.messaging.CustomAttributeValue;
import org.infobip.mobile.messaging.CustomAttributesMapper;
import org.infobip.mobile.messaging.CustomEvent;
import org.infobip.mobile.messaging.Event;
import org.infobip.mobile.messaging.Installation;
import org.infobip.mobile.messaging.Message;
import org.infobip.mobile.messaging.MobileMessaging;
import org.infobip.mobile.messaging.MobileMessagingProperty;
import org.infobip.mobile.messaging.SuccessPending;
import org.infobip.mobile.messaging.User;
import org.infobip.mobile.messaging.api.appinstance.UserCustomEventAtts;
import org.infobip.mobile.messaging.api.shaded.google.gson.Gson;
import org.infobip.mobile.messaging.api.shaded.google.gson.reflect.TypeToken;
import org.infobip.mobile.messaging.api.support.http.serialization.JsonSerializer;
import org.infobip.mobile.messaging.chat.InAppChat;
import org.infobip.mobile.messaging.interactive.InteractiveEvent;
import org.infobip.mobile.messaging.interactive.MobileInteractive;
import org.infobip.mobile.messaging.interactive.NotificationAction;
import org.infobip.mobile.messaging.interactive.NotificationCategory;
import org.infobip.mobile.messaging.mobileapi.InternalSdkError;
import org.infobip.mobile.messaging.mobileapi.MobileMessagingError;
import org.infobip.mobile.messaging.mobileapi.Result;
import org.infobip.mobile.messaging.storage.MessageStore;
import org.infobip.mobile.messaging.util.PreferenceHelper;
import org.infobip.plugins.mobilemessaging.flutter.common.Configuration;
import org.infobip.plugins.mobilemessaging.flutter.common.ErrorCodes;
import org.infobip.plugins.mobilemessaging.flutter.common.InitHelper;
import org.infobip.plugins.mobilemessaging.flutter.common.InstallationJson;
import org.infobip.plugins.mobilemessaging.flutter.common.PersonalizationCtx;
import org.infobip.plugins.mobilemessaging.flutter.common.UserJson;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import io.flutter.Log;
import io.flutter.embedding.android.FlutterActivity;
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

/**
 * InfobipMobilemessagingPlugin
 */
public class InfobipMobilemessagingPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, ServiceAware {

  private static final String TAG = "MobileMessagingFlutter";

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel methodChannel;
  private EventChannel broadcastChannel;

  private StreamHandler broadcastHandler = new StreamHandler();
  private Activity activity = null;
  private BinaryMessenger binaryMessenger = null;

  @Override
  public void onAttachedToEngine(@NonNull FlutterPluginBinding flutterPluginBinding) {
    Log.d(TAG, "onAttachedToEngine");
    methodChannel = new MethodChannel(flutterPluginBinding.getBinaryMessenger(), "infobip_mobilemessaging");

    binaryMessenger = flutterPluginBinding.getBinaryMessenger();
    broadcastChannel = new EventChannel(binaryMessenger, "infobip_mobilemessaging/broadcast");
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
      case "showChat":
        showChat(call, result);
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
      default:
        result.notImplemented();
        break;
    }
  }

  private void init(MethodCall call, final MethodChannel.Result result) {
    Log.d(TAG, "init");

    final Configuration configuration = new Gson().fromJson(call.arguments.toString(), Configuration.class);

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

  // ActivityAware start
  @Override
  public void onAttachedToActivity(@NonNull ActivityPluginBinding binding) {
    Log.d(TAG, "onAttachedToActivity");
    activity = binding.getActivity();
    methodChannel.setMethodCallHandler(this);
    broadcastChannel.setStreamHandler(broadcastHandler);
    registerReceiver();
  }

  @Override
  public void onDetachedFromActivityForConfigChanges() {
    Log.d(TAG, "onDetachedFromActivityForConfigChanges");
  }

  @Override
  public void onReattachedToActivityForConfigChanges(@NonNull ActivityPluginBinding binding) {
    Log.d(TAG, "onReattachedToActivityForConfigChanges");
  }

  @Override
  public void onDetachedFromActivity() {
    Log.d(TAG, "onDetachedFromActivity");
  }

  // ActivityAware end

  // ServiceAware start

  @Override
  public void onAttachedToService(@NonNull ServicePluginBinding binding) {
    Log.d(TAG, "onAttachedToService");
  }

  @Override
  public void onDetachedFromService() {
    Log.d(TAG, "onDetachedFromService");
  }

  // ServiceAware end


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
        final JSONObject payload = messageToJSON(message);
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

      final JSONObject message = messageBundleToJSON(intent.getExtras());

      broadcastHandler.sendEvent(event, message);
    }
  };


  private void registerReceiver() {

    IntentFilter intentFilter = new IntentFilter();
    for (String action : broadcastEventMap.keySet()) {
      intentFilter.addAction(action);
    }

    LocalBroadcastManager.getInstance(activity).registerReceiver(commonLibraryBroadcastReceiver, intentFilter);

    IntentFilter messageIntentFilter = new IntentFilter();
    for (String action : messageBroadcastEventMap.keySet()) {
      messageIntentFilter.addAction(action);
    }
    LocalBroadcastManager.getInstance(activity).registerReceiver(messageBroadcastReceiver, messageIntentFilter);
  }

  /**
   * Creates json from a message object
   *
   * @param message message object
   * @return message json
   */
  private static JSONObject messageToJSON(Message message) {
    try {
      return new JSONObject()
              .putOpt("messageId", message.getMessageId())
              .putOpt("title", message.getTitle())
              .putOpt("body", message.getBody())
              .putOpt("sound", message.getSound())
              .putOpt("vibrate", message.isVibrate())
              .putOpt("icon", message.getIcon())
              .putOpt("silent", message.isSilent())
              .putOpt("category", message.getCategory())
              .putOpt("from", message.getFrom())
              .putOpt("receivedTimestamp", message.getReceivedTimestamp())
              .putOpt("customPayload", message.getCustomPayload())
              .putOpt("contentUrl", message.getContentUrl())
              .putOpt("seen", message.getSeenTimestamp() != 0)
              .putOpt("seenDate", message.getSeenTimestamp())
              .putOpt("chat", message.isChatMessage())
              .putOpt("browserUrl", message.getBrowserUrl())
              .putOpt("deeplink", message.getDeeplink())
              .putOpt("inAppOpenTitle", message.getInAppOpenTitle())
              .putOpt("inAppDismissTitle", message.getInAppDismissTitle());
    } catch (JSONException e) {
      Log.w(TAG, "Cannot convert message to JSON: " + e.getMessage());
      return null;
    }
  }

  /**
   * Creates array of json objects from list of messages
   *
   * @param messages list of messages
   * @return array of jsons representing messages
   */
  private static JSONArray messagesToJSONArray(@NonNull Message messages[]) {
    JSONArray array = new JSONArray();
    for (Message message : messages) {
      JSONObject json = messageToJSON(message);
      if (json == null) {
        continue;
      }
      array.put(json);
    }
    return array;
  }

  public static class StreamHandler implements EventChannel.StreamHandler {

    private EventChannel.EventSink eventSink;
    private final List<JSONObject> cached = new ArrayList<>();

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
      Log.d(TAG, "StreamHandler.onListen: " + events);
      eventSink = events;
      for (JSONObject item : cached) {
        sendEvent(item);
      }
    }

    @Override
    public void onCancel(Object arguments) {
      eventSink = null;
    }

    private boolean sendEvent(JSONObject eventObj) {
      Log.d(TAG, "sendEvent from cached: " + eventObj);
      eventSink.success(eventObj.toString());
      return true;
    }

    private boolean sendEvent(String event, Object payload) {
      Log.d(TAG, "sendEvent: " + event);
      if (event == null || payload == null) {
        return false;
      }

      JSONObject eventData = new JSONObject();
      try {
        eventData.put("eventName", event);
        eventData.put("payload", payload);
      } catch (JSONException e) {
        Log.e(TAG, e.getMessage(), e);
        return false;
      }

      if (eventSink != null) {
        Log.d(TAG, "Send  event to flutter: " + event);
        eventSink.success(eventData.toString());
      } else {
        Log.d(TAG, "add event to cached: " + event);
        cached.add(eventData);
        return false;
      }

      return true;
    }

    private boolean sendEvent(String event) {
      Log.d(TAG, "sendEvent: (without payload) " + event);
      if (event == null) {
        return false;
      }

      JSONObject eventData = new JSONObject();
      try {
        eventData.put("eventName", event);
      } catch (JSONException e) {
        Log.e(TAG, e.getMessage(), e);
        return false;
      }

      if (eventSink != null) {
        Log.d(TAG, "Send  event to flutter: " + event);
        eventSink.success(eventData.toString());
      } else {
        Log.d(TAG, "add event to cached: " + event);
        cached.add(eventData);
        return false;
      }

      return true;
    }

  }

  private MobileMessaging mobileMessaging() {
    return MobileMessaging.getInstance(this.activity.getApplicationContext());
  }

  /*User Profile Management*/

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
      mobileMessaging().personalize(ctx.userIdentity, ctx.userAttributes, ctx.forceDepersonalize, new MobileMessaging.ResultListener<User>() {
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

  public void showChat(MethodCall call, final MethodChannel.Result result) {
    InAppChat.getInstance(activity.getApplication()).inAppChatView().show();
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
    InAppChat.getInstance(activity.getApplication()).setLanguage(language);
  }

  private void sendContextualData(MethodCall call, final MethodChannel.Result result) {
    String data = call.argument("data");
    Boolean allMultiThreadStrategy = call.argument("allMultiThreadStrategy");
    if (data == null || data.isEmpty() || allMultiThreadStrategy == null) {
      result.error(ErrorCodes.CONTEXTUAL_METADATA_ERROR.getErrorCode(), "Cannot resolve data or allMultiThreadStrategy from arguments", null);
      return;
    }
    InAppChat.getInstance(activity.getApplication()).sendContextualData(data, allMultiThreadStrategy);
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
        result.success(messageToJSON(m).toString());
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
    result.success(messagesToJSONArray(messages.toArray(new Message[messages.size()])).toString());
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
          resultCallbacks.success("Success");
        } else {
          resultCallbacks.error(result.getError().getCode(), result.getError().getMessage(), result.getError().toString());
        }
      }
    };
  }
  /*User Profile Management End */


  static void cleanupJsonMapForClient(Map<String, CustomAttributeValue> customAttributes, JSONObject jsonObject) throws JSONException {
    jsonObject.remove("map");
    if (jsonObject.has("customAttributes")) {
      if (customAttributes != null) {
        jsonObject.put("customAttributes", new JSONObject(CustomAttributesMapper.customAttsToBackend(customAttributes)));
      }
    }
  }

  /**
   * Creates new json object based on message bundle
   *
   * @param bundle message bundle
   * @return message object in json format
   */
  private static JSONObject messageBundleToJSON(Bundle bundle) {
    Message message = Message.createFrom(bundle);
    if (message == null) {
      return null;
    }

    return messageToJSON(message);
  }

  private static class CustomEventJson extends CustomEvent {

    static CustomEvent fromJSON(JSONObject json) {
      CustomEvent customEvent = new CustomEvent();

      try {
        if (json.has(UserCustomEventAtts.definitionId)) {
          customEvent.setDefinitionId(json.optString(UserCustomEventAtts.definitionId));
        }
      } catch (Exception e) {
        Log.w(TAG, "Error when serializing CustomEvent object: " + e.getMessage());
      }

      try {
        if (json.has(UserCustomEventAtts.properties)) {
          Type type = new TypeToken<Map<String, Object>>() {
          }.getType();
          Map<String, Object> properties = new JsonSerializer().deserialize(json.optString(UserCustomEventAtts.properties), type);
          customEvent.setProperties(CustomAttributesMapper.customAttsFromBackend(properties));
        }
      } catch (Exception e) {
        Log.w(TAG, "Error when serializing CustomEvent object: " + e.getMessage());
      }

      return customEvent;
    }
  }
}
