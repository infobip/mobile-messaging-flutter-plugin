package org.infobip.plugins.mobilemessaging.flutter.common;

import android.util.Log;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;
import java.util.List;

import io.flutter.plugin.common.EventChannel;

public class StreamHandler implements EventChannel.StreamHandler {

    private EventChannel.EventSink eventSink;
    private final List<JSONObject> cached = new ArrayList<>();
    private String TAG = "StreamHandler";
    private Boolean withCache = true;

    public StreamHandler(String tag, Boolean withCache) {
        this.TAG = tag;
        this.withCache = withCache;
    }

    @Override
    public void onListen(Object arguments, EventChannel.EventSink events) {
        Log.d(TAG, "StreamHandler.onListen: " + events);
        eventSink = events;
        for (JSONObject item : cached) {
            sendCachedEvent(item);
        }
    }

    @Override
    public void onCancel(Object arguments) {
        eventSink = null;
    }

    private boolean sendCachedEvent(JSONObject eventObj) {
        Log.d(TAG, "sendEvent from cached: " + eventObj);
        eventSink.success(eventObj.toString());
        return true;
    }

    public boolean sendEvent(String event) {
        return sendEvent(event, null, this.withCache);
    }

    public boolean sendEvent(String event, Object payload) {
        return sendEvent(event, payload, this.withCache);
    }

    public boolean sendEvent(String event, Object payload, boolean withCache) {
        String payloadLabel = (payload != null) ? "(with payload)" : "(without payload)";
        Log.d(TAG, "sendEvent: " + payloadLabel + " " + event);
        if (event == null) {
            return false;
        }

        JSONObject eventData = new JSONObject();
        try {
            eventData.put("eventName", event);
            if (payload != null) {
                eventData.put("payload", payload);
            }
        } catch (JSONException e) {
            Log.e(TAG, e.getMessage(), e);
            return false;
        }

        if (eventSink != null) {
            Log.d(TAG, "Sending event to Flutter: " + event);
            eventSink.success(eventData.toString());
            return true;
        } else if (withCache) {
            Log.d(TAG, "Adding event to cached: " + event);
            cached.add(eventData);
        } else {
            Log.d(TAG, "Could not send event: " + event);
        }

        return false;
    }

}