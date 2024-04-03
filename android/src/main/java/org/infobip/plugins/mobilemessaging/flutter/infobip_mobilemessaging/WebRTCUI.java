package org.infobip.plugins.mobilemessaging.flutter.infobip_mobilemessaging;

import android.content.Context;

import androidx.annotation.NonNull;

import org.infobip.plugins.mobilemessaging.flutter.common.ConfigCache;
import org.infobip.plugins.mobilemessaging.flutter.common.Configuration;
import org.infobip.plugins.mobilemessaging.flutter.common.ErrorCodes;

import java.lang.reflect.Proxy;

import io.flutter.plugin.common.MethodChannel;

import org.infobip.mobile.messaging.util.StringUtils;

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
    private Class<?> listenTypeClass = null;
    private final Context appContext;

    public WebRTCUI(Context appContext) {
        this.appContext = appContext;
    }

    @NonNull
    static ErrorCallback defaultWebrtcError(MethodChannel.Result result) {
        return t -> result.error(ErrorCodes.WEBRTCUI_ERROR.getErrorCode(), t.getMessage(), t);
    }

    public void enableChatCalls(final SuccessCallback successCallback, final ErrorCallback errorCallback) {
        enableCalls(true, null, successCallback, errorCallback);
    }

    public void enableCalls(String identity, final SuccessCallback successCallback, final ErrorCallback errorCallback) {
        enableCalls(false, identity, successCallback, errorCallback);
    }

    private void enableCalls(Boolean enableChatCalls, String identity, final SuccessCallback successCallback, final ErrorCallback errorCallback) {
        try {
            final Configuration configuration = ConfigCache.getInstance().getConfiguration();
            if (configuration == null) {
                errorCallback.error(new IllegalStateException("Mobile messaging not initialized. Please call InfobipMobilemessaging.init()."));
            } else {
                String configurationId = configuration.getWebRTCUI().getConfigurationId();
                if (configuration.getWebRTCUI() != null && configurationId != null) {
                    Class<?> rtcUiBuilderClass = Class.forName("com.infobip.webrtc.ui.InfobipRtcUi$Builder");
                    Class<?> rtcUiBuilderFinalStepClass = Class.forName("com.infobip.webrtc.ui.InfobipRtcUi$BuilderFinalStep");
                    Object rtcUiBuilder = rtcUiBuilderClass.getDeclaredConstructor(Context.class).newInstance(appContext);
                    Object successListener = successListenerProxy(successCallback);
                    Object errorListener = errorListenerProxy(errorCallback);
                    rtcUiBuilderClass.getMethod("withConfigurationId", String.class).invoke(rtcUiBuilder, configurationId);
                    Object rtcUiBuilderFinalStep;
                    if (enableChatCalls) {
                        rtcUiBuilderFinalStep = rtcUiBuilderClass.getMethod("withInAppChatCalls", getSuccessListenerClass(), getErrorListenerClass()).invoke(
                                rtcUiBuilder,
                                successListener,
                                errorListener
                        );
                    } else if (StringUtils.isNotBlank(identity)) {
                        rtcUiBuilderFinalStep = rtcUiBuilderClass.getMethod("withCalls", String.class, getListenTypeClass(), getSuccessListenerClass(), getErrorListenerClass()).invoke(
                                rtcUiBuilder,
                                identity,
                                pushListenType(),
                                successListener,
                                errorListener
                        );
                    } else {
                        rtcUiBuilderFinalStep = rtcUiBuilderClass.getMethod("withCalls", getSuccessListenerClass(), getErrorListenerClass()).invoke(
                                rtcUiBuilder,
                                successListener,
                                errorListener
                        );
                    }
                    infobipRtcUiInstance = rtcUiBuilderFinalStepClass.getMethod("build").invoke(rtcUiBuilderFinalStep);
                } else {
                    errorCallback.error(new IllegalStateException("Configuration does not contain webRTCUI data."));
                }
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

    @NonNull
    private Class<?> getListenTypeClass() throws ClassNotFoundException {
        if (listenTypeClass == null)
            listenTypeClass = Class.forName("com.infobip.webrtc.ui.model.ListenType");
        return listenTypeClass;
    }

    @SuppressWarnings("SuspiciousInvocationHandlerImplementation")
    @NonNull
    private Object errorListenerProxy(ErrorCallback errorCallback) throws ClassNotFoundException {
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

    /**
     * @noinspection rawtypes
     */
    @SuppressWarnings("unchecked")
    @NonNull
    private Object pushListenType() throws ClassNotFoundException {
        return Enum.valueOf((Class<? extends Enum>) Class.forName("com.infobip.webrtc.ui.model.ListenType"), "PUSH");
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
                                errorListenerProxy(errorCallback)
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
