package org.infobip.plugins.mobilemessaging.flutter.common;

import static org.infobip.mobile.messaging.logging.MobileMessagingLogger.TAG;

import android.app.Activity;
import android.content.Context;
import android.content.res.AssetFileDescriptor;
import android.content.res.AssetManager;
import android.content.res.ColorStateList;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.graphics.drawable.Drawable;
import android.util.Log;

import androidx.annotation.NonNull;

import org.infobip.mobile.messaging.MobileMessaging;
import org.infobip.mobile.messaging.MobileMessagingCore;
import org.infobip.mobile.messaging.NotificationSettings;
import org.infobip.mobile.messaging.app.ActivityLifecycleMonitor;
import org.infobip.mobile.messaging.chat.InAppChat;
import org.infobip.mobile.messaging.chat.view.styles.InAppChatInputViewStyle;
import org.infobip.mobile.messaging.chat.view.styles.InAppChatStyle;
import org.infobip.mobile.messaging.chat.view.styles.InAppChatTheme;
import org.infobip.mobile.messaging.chat.view.styles.InAppChatToolbarStyle;
import org.infobip.mobile.messaging.interactive.NotificationAction;
import org.infobip.mobile.messaging.interactive.NotificationCategory;
import org.infobip.mobile.messaging.storage.SQLiteMessageStore;

import java.io.IOException;
import java.util.List;

import io.flutter.FlutterInjector;
import io.flutter.embedding.engine.loader.FlutterLoader;

public class InitHelper {

    private final Configuration configuration;
    private final Activity activity;

    public InitHelper(Configuration configuration, Activity activity) {
        this.configuration = configuration;
        this.activity = activity;
    }

    public MobileMessaging.Builder configurationBuilder() {
        MobileMessaging.Builder builder = new MobileMessaging
                .Builder(activity.getApplication())
                .withoutRegisteringForRemoteNotifications()
                .withApplicationCode(configuration.getApplicationCode());

        // Privacy
        if (configuration.getPrivacySettings() != null) {
            if (configuration.getPrivacySettings().isUserDataPersistingDisabled()) {
                builder.withoutStoringUserData();
            }
            if (configuration.getPrivacySettings().isCarrierInfoSendingDisabled()) {
                builder.withoutCarrierInfo();
            }
            if (configuration.getPrivacySettings().isSystemInfoSendingDisabled()) {
                builder.withoutSystemInfo();
            }
        }

        if (configuration.defaultMessageStorage) {
            builder.withMessageStore(SQLiteMessageStore.class);
        }

        // Notification
        Context context = activity.getApplicationContext();
        NotificationSettings.Builder notificationBuilder = new NotificationSettings.Builder(activity.getApplicationContext());
        Configuration.AndroidSettings androidSettings = configuration.getAndroidSettings();

        if (androidSettings != null && androidSettings.getNotificationIcon() != null) {
            int resId = getResId(context.getResources(), androidSettings.getNotificationIcon(), context.getPackageName());
            if (resId != 0) {
                notificationBuilder.withDefaultIcon(resId);
            }
        }

        if (androidSettings != null && androidSettings.isMultipleNotifications()) {
            notificationBuilder.withMultipleNotifications();
        }
        if (androidSettings != null && androidSettings.getNotificationAccentColor() != null) {
            int color = Color.parseColor(androidSettings.getNotificationAccentColor());
            notificationBuilder.withColor(color);
        }

        if (configuration.isInAppChatEnabled()) {
            InAppChat chat = InAppChat.getInstance(context);
            chat.activate();
            chat.setTheme(createTheme(configuration));
            String widgetTheme = getWidgetTheme(configuration);
            if (widgetTheme != null) {
                chat.setWidgetTheme(widgetTheme);
            }
        }

        if (configuration.isFullFeaturedInAppsEnabled()) {
            builder.withFullFeaturedInApps();
        }

        builder.withDisplayNotification(notificationBuilder.build());

        if (androidSettings != null && androidSettings.firebaseOptions != null) {
            builder.withFirebaseOptions(androidSettings.firebaseOptions);
        }

        return builder;
    }

    /**
     * Gets resource ID
     *
     * @param res         the resources where to look for
     * @param resPath     the name of the resource
     * @param packageName name of the package where the resource should be searched for
     * @return resource identifier or 0 if not found
     */
    private int getResId(Resources res, String resPath, String packageName) { // TODO: Move to common
        int resId = res.getIdentifier(resPath, "mipmap", packageName);
        if (resId == 0) {
            resId = res.getIdentifier(resPath, "drawable", packageName);
        }
        if (resId == 0) {
            resId = res.getIdentifier(resPath, "raw", packageName);
        }
        if (resId == 0) {
            resId = res.getIdentifier(resPath, "style", packageName);
        }

        return resId;
    }

    /**
     * Converts notification actions in configuration into library format
     *
     * @param actions notification actions from cordova
     * @return library-understandable actions
     */
    @NonNull
    private NotificationAction[] notificationActionsFromConfiguration(@NonNull List<Configuration.NotificationAction> actions) { // TODO: Move to common
        NotificationAction[] notificationActions = new NotificationAction[actions.size()];
        for (int i = 0; i < notificationActions.length; i++) {
            Configuration.NotificationAction action = actions.get(i);
            notificationActions[i] = new NotificationAction.Builder()
                    .withId(action.getIdentifier())
                    .withIcon(activity.getApplication(), action.getIcon())
                    .withTitleText(action.getTitle())
                    .withBringingAppToForeground(action.isForeground())
                    .withInput(action.getTextInputPlaceholder())
                    .withMoMessage(action.isMoRequired())
                    .build();
        }
        return notificationActions;
    }

    /**
     * Converts notification categories in configuration into library format
     *
     * @param categories notification categories from cordova
     * @return library-understandable categories
     */
    @NonNull
    public NotificationCategory[] notificationCategoriesFromConfiguration(@NonNull List<Configuration.NotificationCategory> categories) { // TODO: Move to common
        NotificationCategory[] notificationCategories = new NotificationCategory[categories.size()];
        for (int i = 0; i < notificationCategories.length; i++) {
            Configuration.NotificationCategory category = categories.get(i);
            notificationCategories[i] = new NotificationCategory(
                    category.getIdentifier(),
                    notificationActionsFromConfiguration(category.getActions())
            );
        }
        return notificationCategories;
    }

    public void setForeground() {
        ActivityLifecycleMonitor monitor = MobileMessagingCore
                .getInstance(activity.getApplicationContext())
                .getActivityLifecycleMonitor();
        if (monitor != null) {
            monitor.onActivityResumed(activity);
        }
    }

    private String getWidgetTheme(Configuration configuration) {
        Configuration.InAppChatCustomization inAppChatCustomization = configuration.getCustomization();
        if (inAppChatCustomization != null) {
            return inAppChatCustomization.getWidgetTheme();
        }
        return null;
    }

    private InAppChatTheme createTheme(Configuration configuration) {
        FlutterLoader loader = FlutterInjector.instance().flutterLoader();
        Configuration.InAppChatCustomization inAppChatCustomization = configuration.getCustomization();
        if (inAppChatCustomization != null && inAppChatCustomization.getAndroid() != null) {
            try {
                InAppChatToolbarStyle toolbarStyle = new InAppChatToolbarStyle(
                        Color.parseColor(inAppChatCustomization.getToolbarBackgroundColor()),
                        Color.parseColor(inAppChatCustomization.getAndroid().getChatStatusBarBackgroundColor()),
                        inAppChatCustomization.getAndroid().getChatStatusBarColorLight(),
                        loadDrawable(inAppChatCustomization.getAndroid().getChatNavigationIcon(), loader),
                        Color.parseColor(inAppChatCustomization.getAndroid().getChatNavigationIconTint()),
                        loadDrawable(inAppChatCustomization.getAndroid().getChatMenuItemSaveAttachmentIcon(), loader),
                        Color.parseColor(inAppChatCustomization.getAndroid().getChatMenuItemsIconTint()),
                        getResId(activity.getResources(), inAppChatCustomization.getAndroid().getChatTitleTextAppearanceRes(), activity.getPackageName()),
                        Color.parseColor(inAppChatCustomization.getToolbarTitleColor()),
                        inAppChatCustomization.getToolbarTitle(),
                        null,
                        inAppChatCustomization.getAndroid().getChatTitleCentered(),
                        getResId(activity.getResources(), inAppChatCustomization.getAndroid().getChatSubtitleTextAppearanceRes(), activity.getPackageName()),
                        Color.parseColor(inAppChatCustomization.getAndroid().getChatSubtitleTextColor()),
                        inAppChatCustomization.getAndroid().getChatSubtitleText(),
                        null,
                        inAppChatCustomization.getAndroid().getChatSubtitleCentered()
                );
                return new InAppChatTheme(
                        toolbarStyle,
                        toolbarStyle,
                        new InAppChatStyle(
                                Color.parseColor(inAppChatCustomization.getChatBackgroundColor()),
                                Color.parseColor(inAppChatCustomization.getAndroid().getChatProgressBarColor()),
                                inAppChatCustomization.getAndroid().getChatNetworkConnectionErrorText(),
                                null,
                                getResId(activity.getResources(), inAppChatCustomization.getAndroid().getChatNetworkConnectionErrorTextAppearanceRes(), activity.getPackageName()),
                                Color.parseColor(inAppChatCustomization.getNoConnectionAlertTextColor()),
                                Color.parseColor(inAppChatCustomization.getNoConnectionAlertBackgroundColor())
                        ),
                        new InAppChatInputViewStyle(
                                getResId(activity.getResources(), inAppChatCustomization.getAndroid().getChatInputTextAppearance(), activity.getPackageName()),
                                Color.parseColor(inAppChatCustomization.getAndroid().getChatInputTextColor()),
                                Color.parseColor(inAppChatCustomization.getChatInputBackgroundColor()),
                                inAppChatCustomization.getAndroid().getChatInputHintText(),
                                null,
                                Color.parseColor(inAppChatCustomization.getChatInputPlaceholderColor()),
                                loadDrawable(inAppChatCustomization.getAttachmentButtonIcon(), loader),
                                ColorStateList.valueOf(Color.parseColor(inAppChatCustomization.getAndroid().getChatInputAttachmentIconTint())),
                                loadDrawable(inAppChatCustomization.getAndroid().getChatInputAttachmentBackgroundDrawable(), loader),
                                Color.parseColor(inAppChatCustomization.getAndroid().getChatInputAttachmentBackgroundColor()),
                                loadDrawable(inAppChatCustomization.getSendButtonIcon(), loader),
                                ColorStateList.valueOf(Color.parseColor(inAppChatCustomization.getAndroid().getChatInputSendIconTint())),
                                loadDrawable(inAppChatCustomization.getAndroid().getChatInputSendBackgroundDrawable(), loader),
                                Color.parseColor(inAppChatCustomization.getAndroid().getChatInputSendBackgroundColor()),
                                Color.parseColor(inAppChatCustomization.getAndroid().getChatInputSeparatorLineColor()),
                                inAppChatCustomization.getChatInputSeparatorVisible(),
                                Color.parseColor(inAppChatCustomization.getChatInputCursorColor())
                        )
                );
            } catch (IllegalArgumentException e) {
                Log.e(TAG, "Color in invalid format.", e);
                return null;
            }
        }
        return null;
    }

    private Drawable loadDrawable(String drawableSrc, FlutterLoader loader) {
        AssetManager assets = activity.getApplication().getAssets();

        try (AssetFileDescriptor fileDescriptor = assets.openFd(loader.getLookupKeyForAsset(drawableSrc))) {
            return new BitmapDrawable(activity.getResources(), fileDescriptor.createInputStream());
        } catch (IOException e) {
            Log.e(TAG, "Failed to load image " + drawableSrc, e);
            return null;
        }

    }

}
