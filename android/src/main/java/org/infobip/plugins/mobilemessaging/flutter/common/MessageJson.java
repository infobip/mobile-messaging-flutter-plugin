package org.infobip.plugins.mobilemessaging.flutter.common;

import static org.infobip.plugins.mobilemessaging.flutter.infobip_mobilemessaging.InfobipMobilemessagingPlugin.TAG;

import android.os.Bundle;
import android.util.Log;

import androidx.annotation.NonNull;

import org.infobip.mobile.messaging.Message;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

public class MessageJson {

    /**
     * Creates json from a message object
     *
     * @param message message object
     * @return message json
     */
    public static JSONObject messageToJSON(Message message) {
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
    public static JSONArray messagesToJSONArray(@NonNull Message[] messages) {
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

    /**
     * Creates new json object based on message bundle
     *
     * @param bundle message bundle
     * @return message object in json format
     */
    public static JSONObject messageBundleToJSON(Bundle bundle) {
        Message message = Message.createFrom(bundle);
        if (message == null) {
            return null;
        }

        return messageToJSON(message);
    }
}
