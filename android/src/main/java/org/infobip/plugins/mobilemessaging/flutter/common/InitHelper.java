//   InitHelper.java
//   MobileMessagingFlutter
//
//   Copyright (c) 2016-2026 Infobip Limited
//   Licensed under the Apache License, Version 2.0
//

package org.infobip.plugins.mobilemessaging.flutter.common;

import android.app.Activity;
import android.content.Context;
import android.content.res.Resources;
import android.graphics.Color;

import androidx.annotation.NonNull;


import org.infobip.mobile.messaging.MobileMessaging;
import org.infobip.mobile.messaging.MobileMessagingCore;
import org.infobip.mobile.messaging.NotificationSettings;
import org.infobip.mobile.messaging.app.ActivityLifecycleMonitor;
import org.infobip.mobile.messaging.chat.InAppChat;
import org.infobip.mobile.messaging.interactive.NotificationAction;
import org.infobip.mobile.messaging.interactive.NotificationCategory;
import org.infobip.mobile.messaging.storage.SQLiteMessageStore;

import java.util.List;

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

        if (androidSettings != null && androidSettings.getNotificationChannelId() != null && !androidSettings.getNotificationChannelId().isEmpty()
                && androidSettings.getNotificationChannelName() != null && !androidSettings.getNotificationChannelName().isEmpty()
                && androidSettings.getNotificationSound() != null && !androidSettings.getNotificationSound().isEmpty()) {
            builder.withCustomNotificationChannel(androidSettings.getNotificationChannelId(),
                    androidSettings.getNotificationChannelName(),
                    androidSettings.getNotificationSound());
        }

        if (configuration.isInAppChatEnabled()) {
            InAppChat chat = InAppChat.getInstance(context);
            chat.activate();
        }

        if (configuration.isFullFeaturedInAppsEnabled()) {
            builder.withFullFeaturedInApps();
        }

        builder.withDisplayNotification(notificationBuilder.build());

        if (androidSettings != null && androidSettings.firebaseOptions != null) {
            builder.withFirebaseOptions(androidSettings.firebaseOptions);
        }

        builder.withJwtSupplier(() -> configuration.userDataJwt);

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

}
