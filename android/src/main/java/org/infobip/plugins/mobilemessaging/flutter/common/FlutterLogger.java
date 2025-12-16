//
//  FlutterLogger.java
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

package org.infobip.plugins.mobilemessaging.flutter.common;

import android.util.Log;

import org.infobip.mobile.messaging.logging.Level;

import androidx.annotation.Nullable;

/**
 * Centralized logging utility for Flutter plugin code.
 * Routes logs to Flutter console via FlutterLogWriter when enabled.
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
     * Disable Flutter console logging, revert to native Logcat.
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
            Log.v(tag, message, throwable);
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
            Log.d(tag, message, throwable);
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
            Log.i(tag, message, throwable);
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
            Log.w(tag, message, throwable);
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
            Log.e(tag, message, throwable);
        }
    }
}
