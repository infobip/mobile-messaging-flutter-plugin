//
//  FlutterLogWriter.java
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

package org.infobip.plugins.mobilemessaging.flutter.common;

import android.os.Handler;
import android.os.Looper;
import android.util.Log;

import org.infobip.mobile.messaging.logging.Level;
import org.infobip.mobile.messaging.logging.LogcatWriter;
import org.infobip.mobile.messaging.logging.Writer;
import org.json.JSONObject;

import java.text.SimpleDateFormat;
import java.util.Date;
import java.util.Locale;

import androidx.annotation.Nullable;

/**
 * Custom log writer that proxies Android native SDK logs to Flutter console
 * Implements the Writer interface from MobileMessagingLogger
 */
public class FlutterLogWriter implements Writer {

    private static final String TAG = "FlutterLogWriter";
    private static final SimpleDateFormat dateFormat = new SimpleDateFormat("HH:mm:ss.SSS", Locale.US);

    private final StreamHandler streamHandler;
    private final Handler mainHandler;
    private final LogcatWriter logcatWriter;

    public FlutterLogWriter(StreamHandler streamHandler) {
        this.streamHandler = streamHandler;
        this.mainHandler = new Handler(Looper.getMainLooper());
        this.logcatWriter = new LogcatWriter();
    }

    /**
     * Called by MobileMessagingLogger for each log entry
     * Converts log level to prefix and emits event to Flutter
     *
     * @param level     Log level (VERBOSE, DEBUG, INFO, WARN, ERROR)
     * @param tag       Log tag (usually SDK component name)
     * @param message   Log message
     * @param throwable Optional exception/throwable
     */
    @Override
    public void write(
            Level level,
            String tag,
            String message,
            @Nullable Throwable throwable
    ) {
        String levelName = (level != null) ? level.name() : Level.DEBUG.name();
        write(levelName, tag, message, throwable);
    }

    /**
     * Called by FlutterLogger for each log entry
     * Converts log level to prefix and emits event to Flutter
     *
     * @param level     Log level (VERBOSE, DEBUG, INFO, WARN, ERROR)
     * @param tag       Log tag (usually class name)
     * @param message   Log message
     * @param throwable Optional exception/throwable
     */
    public void write(
            @Nullable String level,
            @Nullable String tag,
            @Nullable String message,
            @Nullable Throwable throwable
    ) {
        if (Looper.myLooper() == Looper.getMainLooper()) {
            sendToFlutter(level, tag, message, throwable);
        }
        else {
            mainHandler.post(new Runnable() {
                @Override
                public void run() {
                    sendToFlutter(level, tag, message, throwable);
                }
            });
        }
    }

    /**
     * Send log message to Flutter via EventChannel.
     * Must be called on main thread.
     */
    private void sendToFlutter(
            @Nullable final String level,
            @Nullable final String tag,
            @Nullable final String message,
            @Nullable final Throwable throwable
    ) {
        try {
            if (message == null || message.trim().isEmpty())
                return;

            String timestamp = dateFormat.format(new Date());
            String fullMessage;
            if (throwable != null) {
                fullMessage = message + "\n" + Log.getStackTraceString(throwable);
            }
            else {
                fullMessage = message;
            }
            String tagLog = (tag == null || tag.trim().isEmpty()) ? "" : " [" + tag + "]";
            final String logcatStyleMessage = timestamp + tagLog + ": " + fullMessage;

            JSONObject payload = new JSONObject();
            payload.put("message", logcatStyleMessage);
            streamHandler.sendEvent(
                    LibraryEvent.EVENT_PLATFORM_NATIVE_LOG_SENT,
                    payload,
                    true,
                    false
            );
        } catch (Exception e) {
            // Fallback to Logcat if message cannot be logged by Flutter console
            try {
                logcatWriter.write(Level.valueOf(level), tag, message, throwable);
            } catch (IllegalArgumentException ex) {
                logcatWriter.write(Level.DEBUG, tag, message, throwable);
            }
        }
    }
}
