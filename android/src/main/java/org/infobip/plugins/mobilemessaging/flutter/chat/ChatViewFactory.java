package org.infobip.plugins.mobilemessaging.flutter.chat;

import android.app.Activity;
import android.content.Context;

import androidx.annotation.Nullable;
import androidx.annotation.NonNull;
import io.flutter.plugin.common.StandardMessageCodec;
import io.flutter.plugin.platform.PlatformView;
import io.flutter.plugin.platform.PlatformViewFactory;
import io.flutter.plugin.common.BinaryMessenger;

import java.util.Map;

public class ChatViewFactory extends PlatformViewFactory {

    private final BinaryMessenger messenger;
    private Activity activity;

    public ChatViewFactory(BinaryMessenger messenger, Activity activity) {
        super(StandardMessageCodec.INSTANCE);
        this.messenger = messenger;
        this.activity = activity;
    }

    @NonNull
    @Override
    @SuppressWarnings("unchecked")
    public PlatformView create(@NonNull Context context, int id, @Nullable Object args) {
        Map<String, Object> creationParams = null;
        if (args instanceof Map) {
            creationParams = (Map<String, Object>) args;
        }
        return new ChatPlatformView(context, id, creationParams, activity, messenger);
    }

    public void setActivity(Activity activity) {
        this.activity = activity;
    }

}
