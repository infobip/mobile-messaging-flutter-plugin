package org.infobip.plugins.mobilemessaging.flutter.infobip_mobilemessaging;

import android.content.Context;

import androidx.annotation.NonNull;

import org.infobip.plugins.mobilemessaging.flutter.common.ConfigCache;
import org.infobip.plugins.mobilemessaging.flutter.common.Configuration;
import org.infobip.plugins.mobilemessaging.flutter.common.ErrorCodes;

import java.lang.reflect.Proxy;

import io.flutter.plugin.common.MethodChannel;

public class WebRTCUI {
    @FunctionalInterface
    interface SuccessCallback {
        void success();
    }

    @FunctionalInterface
    interface ErrorCallback {
        void error(Throwable t);
    }

    private static Object infobipRtcUiInstance = null;

    private Class<?> successListenerClass = null;
    private Class<?> errorListenerClass = null;
    private final Context appContext;

    public WebRTCUI(Context appContext) {
        this.appContext = appContext;
    }

    @NonNull
    static ErrorCallback defaultWebrtcError(MethodChannel.Result result) {
        return t -> result.error(ErrorCodes.WEBRTCUI_ERROR.getErrorCode(), t.getMessage(), t);
    }

    public void enableCalls(final SuccessCallback successCallback, final ErrorCallback errorCallback) {
        try {
            final Configuration configuration = ConfigCache.getInstance().getConfiguration();
            if (configuration == null) {
                errorCallback.error(new IllegalStateException("Mobile messaging not initialized. Please call mobileMessaging.init()."));
            } else if (configuration.getWebRTCUI() != null && configuration.getWebRTCUI().getApplicationId() != null) {
                Class<?> rtcUiBuilderClass = Class.forName("com.infobip.webrtc.ui.InfobipRtcUi$Builder");
                Object rtcUiBuilder = rtcUiBuilderClass.getDeclaredConstructor(Context.class).newInstance(appContext);
                Object successListener = successListenerProxy(successCallback);
                Object errorListener = errorListenerCallback(errorCallback);
                rtcUiBuilderClass.getMethod("applicationId", String.class).invoke(rtcUiBuilder, configuration.getWebRTCUI().getApplicationId());
                rtcUiBuilderClass.getMethod("enableInAppCalls", getSuccessListenerClass(), getErrorListenerClass()).invoke(
                        rtcUiBuilder,
                        successListener,
                        errorListener
                );
                infobipRtcUiInstance = rtcUiBuilderClass.getMethod("build").invoke(rtcUiBuilder);
            } else {
                errorCallback.error(new IllegalStateException("Configuration does not contain webRTCUI data."));
            }
        } catch (ClassNotFoundException e) {
            errorCallback.error(new IllegalStateException("Android WebRtcUi not enabled. Please set flag buildscript {ext { withWebRTCUI = true } } in your build.gradle."));
        } catch (ReflectiveOperationException e) {
            errorCallback.error(new RuntimeException("Cannot enable calls. ", e));
        } catch (Throwable t) {
            errorCallback.error(new RuntimeException("Something went wrong. ", t));
        }
    }

    @NonNull
    private Class<?> getSuccessListenerClass() throws ClassNotFoundException {
        if (successListenerClass == null)
            successListenerClass = Class.forName("com.infobip.webrtc.ui.SuccessListener");
        return successListenerClass;
    }

    @NonNull
    private Class<?> getErrorListenerClass() throws ClassNotFoundException {
        if (errorListenerClass == null)
            errorListenerClass = Class.forName("com.infobip.webrtc.ui.ErrorListener");
        return errorListenerClass;
    }

    @SuppressWarnings("SuspiciousInvocationHandlerImplementation")
    @NonNull
    private Object errorListenerCallback(ErrorCallback errorCallback) throws ClassNotFoundException {
        return Proxy.newProxyInstance(
                getClass().getClassLoader(),
                new Class[]{getErrorListenerClass()},
                (proxy, method, args) -> {
                    if (method.getName().equals("onError") && args.length > 0 && args[0] instanceof Throwable) {
                        Throwable throwable = (Throwable) args[0];
                        errorCallback.error(throwable);
                    }
                    return null;
                }
        );
    }

    @SuppressWarnings("SuspiciousInvocationHandlerImplementation")
    @NonNull
    private Object successListenerProxy(SuccessCallback successCallback) throws ClassNotFoundException {
        return Proxy.newProxyInstance(
                getClass().getClassLoader(),
                new Class[]{getSuccessListenerClass()},
                (proxy, method, args) -> {
                    if (method.getName().equals("onSuccess")) {
                        successCallback.success();
                    }
                    return null;
                }
        );
    }

    public void disableCalls(final SuccessCallback successCallback, final ErrorCallback errorCallback) {
        if (infobipRtcUiInstance == null) {
            errorCallback.error(new IllegalStateException(("Calls are not enabled.")));
        } else {
            try {
                Class<?> infobipRtcUiClass = Class.forName("com.infobip.webrtc.ui.InfobipRtcUi");
                infobipRtcUiClass.getMethod("disableCalls", getSuccessListenerClass(), getErrorListenerClass())
                        .invoke(
                                infobipRtcUiInstance,
                                successListenerProxy(successCallback),
                                errorListenerCallback(errorCallback)
                        );
            } catch (ClassNotFoundException e) {
                errorCallback.error(new IllegalStateException("Android WebRtcUi not enabled. Please set flag buildscript {ext { withWebRTCUI = true } } in your build.gradle."));
            } catch (ReflectiveOperationException e) {
                errorCallback.error(new RuntimeException("Cannot disable calls.", e));
            } catch (Throwable t) {
                errorCallback.error(new RuntimeException("Something went wrong. ", t));
            }
        }
    }
}
