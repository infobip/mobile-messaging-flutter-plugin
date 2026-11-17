//
//  FlutterLogger.java
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

package org.infobip.plugins.mobilemessaging.flutter.common;

import org.infobip.mobile.messaging.logging.Level;
import org.infobip.mobile.messaging.logging.MobileMessagingLogger;

import androidx.annotation.Nullable;

/**
 * Centralized logging utility for Flutter plugin code.
 * <p>
 * When logging is enabled in the plugin configuration, logs are routed to the Flutter console via {@link FlutterLogWriter}.
 * Otherwise logs are delegated to {@link MobileMessagingLogger}, which writes verbose/debug/info/warn logs
 * only for debuggable builds (or when logging is enforced) and always writes errors.
 * Never pass sensitive data (JWTs, tokens, payloads, personal data) to this logger.
 */
public class FlutterLogger {

    @Nullable
    private static volatile FlutterLogWriter writer = null;

    private FlutterLogger() {
    }

    /**
     * Enable Flutter console logging with the provided writer.
     * Call this after SDK initialization with logging enabled.
     */
    public static void useFlutterConsole(FlutterLogWriter writer) {
        FlutterLogger.writer = writer;
    }

    /**
     * Route logs through {@link MobileMessagingLogger}.
     */
    public static void useNativeLogcat() {
        FlutterLogger.writer = null;
    }

    /**
     * Log a VERBOSE message.
     */
    public static void v(String tag, String message) {
        v(tag, message, null);
    }

    /**
     * Log a VERBOSE message with throwable.
     */
    public static void v(String tag, String message, @Nullable Throwable throwable) {
        if (writer != null) {
            writer.write(Level.VERBOSE.name(), tag, message, throwable);
        } else {
            MobileMessagingLogger.v(tag, message, throwable);
        }
    }

    /**
     * Log a DEBUG message.
     */
    public static void d(String tag, String message) {
        d(tag, message, null);
    }

    /**
     * Log a DEBUG message with throwable.
     */
    public static void d(String tag, String message, @Nullable Throwable throwable) {
        if (writer != null) {
            writer.write(Level.DEBUG.name(), tag, message, throwable);
        } else {
            MobileMessagingLogger.d(tag, message, throwable);
        }
    }

    /**
     * Log an INFO message.
     */
    public static void i(String tag, String message) {
        i(tag, message, null);
    }

    /**
     * Log an INFO message with throwable.
     */
    public static void i(String tag, String message, @Nullable Throwable throwable) {
        if (writer != null) {
            writer.write(Level.INFO.name(), tag, message, throwable);
        } else {
            MobileMessagingLogger.i(tag, message, throwable);
        }
    }

    /**
     * Log a WARN message.
     */
    public static void w(String tag, String message) {
        w(tag, message, null);
    }

    /**
     * Log a WARN message with throwable.
     */
    public static void w(String tag, String message, @Nullable Throwable throwable) {
        if (writer != null) {
            writer.write(Level.WARN.name(), tag, message, throwable);
        } else {
            MobileMessagingLogger.w(tag, message, throwable);
        }
    }

    /**
     * Log an ERROR message.
     */
    public static void e(String tag, String message) {
        e(tag, message, null);
    }

    /**
     * Log an ERROR message with throwable.
     */
    public static void e(String tag, String message, @Nullable Throwable throwable) {
        if (writer != null) {
            writer.write(Level.ERROR.name(), tag, message, throwable);
        } else {
            MobileMessagingLogger.e(tag, message, throwable);
        }
    }
}
