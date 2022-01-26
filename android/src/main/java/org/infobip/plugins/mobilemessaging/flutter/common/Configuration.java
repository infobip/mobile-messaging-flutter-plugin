package org.infobip.plugins.mobilemessaging.flutter.common;

import com.google.gson.annotations.SerializedName;

import java.util.List;

public class Configuration {
    /// The application code of your Application from Push Portal website
    String applicationCode;
    String pluginVersion = "unknown";
    boolean inAppChatEnabled;
    AndroidSettings androidSettings;
    PrivacySettings privacySettings;
    List<NotificationCategory> notificationCategories;
    boolean defaultMessageStorage;

    public class AndroidSettings {
        /// The firebase sender ID of your Application
        String firebaseSenderId;
        String notificationIcon;
        boolean multipleNotifications;
        String notificationAccentColor;

        public String getFirebaseSenderId() {
            return firebaseSenderId;
        }

        public void setFirebaseSenderId(String firebaseSenderId) {
            this.firebaseSenderId = firebaseSenderId;
        }

        public String getNotificationIcon() {
            return notificationIcon;
        }

        public void setNotificationIcon(String notificationIcon) {
            this.notificationIcon = notificationIcon;
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
    }

    public class PrivacySettings {
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

    public class NotificationAction {
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

    public class NotificationCategory {
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
}
