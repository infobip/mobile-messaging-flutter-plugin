package org.infobip.plugins.mobilemessaging.flutter.infobip_mobilemessaging;

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
import org.infobip.mobile.messaging.Event;
import org.infobip.mobile.messaging.Installation;
import org.infobip.mobile.messaging.InstallationMapper;
import org.infobip.mobile.messaging.Message;
import org.infobip.mobile.messaging.MobileMessaging;
import org.infobip.mobile.messaging.MobileMessagingProperty;
import org.infobip.mobile.messaging.api.shaded.google.gson.Gson;
import org.infobip.mobile.messaging.api.shaded.google.gson.reflect.TypeToken;
import org.infobip.mobile.messaging.api.support.http.serialization.JsonSerializer;
import org.infobip.mobile.messaging.interactive.InteractiveEvent;
import org.infobip.mobile.messaging.interactive.MobileInteractive;
import org.infobip.mobile.messaging.interactive.NotificationAction;
import org.infobip.mobile.messaging.interactive.NotificationCategory;
import org.infobip.mobile.messaging.mobileapi.InternalSdkError;
import org.infobip.mobile.messaging.util.PreferenceHelper;
import org.infobip.plugins.mobilemessaging.flutter.common.Configuration;
import org.infobip.plugins.mobilemessaging.flutter.common.InitHelper;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.lang.reflect.Type;
import java.util.ArrayList;
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
import io.flutter.plugin.common.MethodChannel.Result;

import static org.infobip.plugins.mobilemessaging.flutter.common.LibraryEvent.broadcastEventMap;
import static org.infobip.plugins.mobilemessaging.flutter.common.LibraryEvent.messageBroadcastEventMap;

/** InfobipMobilemessagingPlugin */
public class InfobipMobilemessagingPlugin implements FlutterPlugin, MethodCallHandler, ActivityAware, ServiceAware {

  private static final String TAG = "MobileMessagingFlutter";

  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private MethodChannel methodChannel;
  private EventChannel broadcastChannel;

  private StreamHandler broadcastHandler = new StreamHandler();

  private FlutterActivity flutterActivity = null;
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
  public void onMethodCall(@NonNull MethodCall call, @NonNull Result result)  {
    Log.d(TAG, "onMethodCall");
    Log.i(TAG, "activity: " + activity.toString());
    if (call.method.equals("init")) {
      init(call, result);
    } else {
      result.notImplemented();
    }
  }

  private void init(MethodCall call,final Result result) {
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
        broadcastHandler.sendEvent(event, messageToJSON(message), notificationAction.getId(), notificationAction.getInputText());
        return;
      }

      if (intent.getAction() != null && intent.getAction().equals(Event.INSTALLATION_UPDATED.getKey()) {
        final JSONObject updatedInstallation = InstallationJson.toJSON(Installation.createFrom(intent.getExtras()));
        broadcastHandler.sendEvent(event, updatedInstallation);
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

  public static class StreamHandler implements EventChannel.StreamHandler {

      private EventChannel.EventSink eventSink;
      private List<JSONObject> cached = new ArrayList<>();

      @Override
      public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.d(TAG, "StreamHandler.onListen: " + events);
        eventSink = events;
        for (JSONObject item: cached) {
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

      private boolean sendEvent(String event, Object object1, Object... objects) {
        Log.d(TAG, "sendEvent: " + event);
        if (event == null || object1 == null) {
          return false;
        }

        JSONObject eventData = new JSONObject();
        JSONArray parameters = new JSONArray();
        // parameters.put(event);
        parameters.put(object1);
        for (Object o : objects) {
          parameters.put(o);
        }
        try {
          eventData.put("eventName", event);
          eventData.put("payload", parameters);
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
          return  false;
        }

        return true;
      }

    private boolean sendEvent(String event) {
      Log.d(TAG, "sendEvent: " + event);
      if (event == null) {
        return false;
      }

      JSONArray parameters = new JSONArray();
      parameters.put(event);
      eventSink.success(parameters);
      return true;
    }

  }


  private static class InstallationJson extends Installation {

    static JSONArray toJSON(final List<Installation> installations) {
      JSONArray installationsJson = new JSONArray();
      for (Installation installation : installations) {
        installationsJson.put(toJSON(installation));
      }
      return installationsJson;
    }

    static JSONObject toJSON(final Installation installation) {
      try {
        String json = InstallationMapper.toJson(installation);
        JSONObject jsonObject = new JSONObject(json);
        cleanupJsonMapForClient(installation.getCustomAttributes(), jsonObject);
        return jsonObject;
      } catch (JSONException e) {
        e.printStackTrace();
        return new JSONObject();
      }
    }

    static Installation fromJSON(JSONObject json) {
      Installation installation = new Installation();

      try {
        if (json.has("isPushRegistrationEnabled")) {
          installation.setPushRegistrationEnabled(json.optBoolean("isPushRegistrationEnabled"));
        }
        if (json.has("isPrimaryDevice")) {
          installation.setPrimaryDevice(json.optBoolean("isPrimaryDevice"));
        }
        if (json.has("customAttributes")) {
          Type type = new TypeToken<Map<String, Object>>() {
          }.getType();
          Map<String, Object> customAttributes = new JsonSerializer().deserialize(json.optString("customAttributes"), type);
          installation.setCustomAttributes(CustomAttributesMapper.customAttsFromBackend(customAttributes));
        }
      } catch (Exception e) {
        //error parsing
      }

      return installation;
    }
  }

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
}
