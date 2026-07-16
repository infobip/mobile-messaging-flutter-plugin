//   Configuration.java
//   MobileMessagingFlutter
//
//   Copyright (c) 2016-2026 Infobip Limited
//   Licensed under the Apache License, Version 2.0
//

package org.infobip.plugins.mobilemessaging.flutter.common;

import com.google.firebase.FirebaseOptions;

import java.util.List;

public class Configuration {
    /// The application code of your Application from Push Portal website
    String applicationCode;
    String pluginVersion = "unknown";
    boolean inAppChatEnabled;
    boolean fullFeaturedInAppsEnabled;
    AndroidSettings androidSettings;
    PrivacySettings privacySettings;
    List<NotificationCategory> notificationCategories;
    boolean defaultMessageStorage;
    WebRTCUI webRTCUI;
    String userDataJwt;
    boolean logging;

    public static class WebRTCUI {
        private String configurationId;

        public String getConfigurationId() {
            return configurationId;
        }

        public void setConfigurationId(String configurationId) {
            this.configurationId = configurationId;
        }
    }

    public static class AndroidSettings {
        String notificationIcon;
        String notificationChannelId;
        String notificationChannelName;
        String notificationSound;
        boolean multipleNotifications;
        String notificationAccentColor;
        FirebaseOptions firebaseOptions;

        public String getNotificationIcon() {
            return notificationIcon;
        }

        public void setNotificationIcon(String notificationIcon) {
            this.notificationIcon = notificationIcon;
        }

        public String getNotificationChannelId() {
            return notificationChannelId;
        }

        public String getNotificationChannelName() {
            return notificationChannelName;
        }

        public String getNotificationSound() {
            return notificationSound;
        }

        public boolean isMultipleNotifications() {
            return multipleNotifications;
        }

        public void setMultipleNotifications(boolean multipleNotifications) {
            this.multipleNotifications = multipleNotifications;
        }

        public String getNotificationAccentColor() {
            return notificationAccentColor;
        }

        public void setNotificationAccentColor(String notificationAccentColor) {
            this.notificationAccentColor = notificationAccentColor;
        }

        public FirebaseOptions getFirebaseOptions() {
            return firebaseOptions;
        }

        public void setFirebaseOptions(FirebaseOptions firebaseOptions) {
            this.firebaseOptions = firebaseOptions;
        }
    }

    public static class PrivacySettings {
        boolean applicationCodePersistingDisabled;
        boolean userDataPersistingDisabled;
        boolean carrierInfoSendingDisabled;
        boolean systemInfoSendingDisabled;

        public boolean isApplicationCodePersistingDisabled() {
            return applicationCodePersistingDisabled;
        }

        public void setApplicationCodePersistingDisabled(boolean applicationCodePersistingDisabled) {
            this.applicationCodePersistingDisabled = applicationCodePersistingDisabled;
        }

        public boolean isUserDataPersistingDisabled() {
            return userDataPersistingDisabled;
        }

        public void setUserDataPersistingDisabled(boolean userDataPersistingDisabled) {
            this.userDataPersistingDisabled = userDataPersistingDisabled;
        }

        public boolean isCarrierInfoSendingDisabled() {
            return carrierInfoSendingDisabled;
        }

        public void setCarrierInfoSendingDisabled(boolean carrierInfoSendingDisabled) {
            this.carrierInfoSendingDisabled = carrierInfoSendingDisabled;
        }

        public boolean isSystemInfoSendingDisabled() {
            return systemInfoSendingDisabled;
        }

        public void setSystemInfoSendingDisabled(boolean systemInfoSendingDisabled) {
            this.systemInfoSendingDisabled = systemInfoSendingDisabled;
        }
    }

    public static class NotificationAction {
        String identifier;
        String title;
        boolean foreground;
        boolean authenticationRequired;
        boolean moRequired;
        boolean destructive;
        String icon;
        String textInputActionButtonTitle;
        String textInputPlaceholder;

        public String getIdentifier() {
            return identifier;
        }

        public void setIdentifier(String identifier) {
            this.identifier = identifier;
        }

        public String getTitle() {
            return title;
        }

        public void setTitle(String title) {
            this.title = title;
        }

        public boolean isForeground() {
            return foreground;
        }

        public void setForeground(boolean foreground) {
            this.foreground = foreground;
        }

        public boolean isAuthenticationRequired() {
            return authenticationRequired;
        }

        public void setAuthenticationRequired(boolean authenticationRequired) {
            this.authenticationRequired = authenticationRequired;
        }

        public boolean isMoRequired() {
            return moRequired;
        }

        public void setMoRequired(boolean moRequired) {
            this.moRequired = moRequired;
        }

        public boolean isDestructive() {
            return destructive;
        }

        public void setDestructive(boolean destructive) {
            this.destructive = destructive;
        }

        public String getIcon() {
            return icon;
        }

        public void setIcon(String icon) {
            this.icon = icon;
        }

        public String getTextInputActionButtonTitle() {
            return textInputActionButtonTitle;
        }

        public void setTextInputActionButtonTitle(String textInputActionButtonTitle) {
            this.textInputActionButtonTitle = textInputActionButtonTitle;
        }

        public String getTextInputPlaceholder() {
            return textInputPlaceholder;
        }

        public void setTextInputPlaceholder(String textInputPlaceholder) {
            this.textInputPlaceholder = textInputPlaceholder;
        }
    }

    public static class NotificationCategory {
        String identifier;
        List<NotificationAction> actions;

        public String getIdentifier() {
            return identifier;
        }

        public void setIdentifier(String identifier) {
            this.identifier = identifier;
        }

        public List<NotificationAction> getActions() {
            return actions;
        }

        public void setActions(List<NotificationAction> actions) {
            this.actions = actions;
        }
    }

    public String getApplicationCode() {
        return applicationCode;
    }

    public void setApplicationCode(String applicationCode) {
        this.applicationCode = applicationCode;
    }

    public String getPluginVersion() {
        return pluginVersion;
    }

    public void setPluginVersion(String pluginVersion) {
        this.pluginVersion = pluginVersion;
    }

    public AndroidSettings getAndroidSettings() {
        return androidSettings;
    }

    public void setAndroidSettings(AndroidSettings androidSettings) {
        this.androidSettings = androidSettings;
    }

    public PrivacySettings getPrivacySettings() {
        return privacySettings;
    }

    public void setPrivacySettings(PrivacySettings privacySettings) {
        this.privacySettings = privacySettings;
    }

    public List<NotificationCategory> getNotificationCategories() {
        return notificationCategories;
    }

    public void setNotificationCategories(List<NotificationCategory> notificationCategories) {
        this.notificationCategories = notificationCategories;
    }

    public WebRTCUI getWebRTCUI() {
        return webRTCUI;
    }

    public void setWebRTCUI(WebRTCUI webRTCUI) {
        this.webRTCUI = webRTCUI;
    }

    public boolean isInAppChatEnabled() {
        return inAppChatEnabled;
    }

    public void setInAppChatEnabled(boolean inAppChatEnabled) {
        this.inAppChatEnabled = inAppChatEnabled;
    }

    public boolean isFullFeaturedInAppsEnabled() {
        return fullFeaturedInAppsEnabled;
    }

    public void setFullFeaturedInAppsEnabled(boolean fullFeaturedInAppsEnabled) {
        this.fullFeaturedInAppsEnabled = fullFeaturedInAppsEnabled;
    }

    public boolean isLogging() {
        return logging;
    }

    public void setLogging(boolean logging) {
        this.logging = logging;
    }
}
