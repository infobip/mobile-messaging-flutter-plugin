package org.infobip.plugins.mobilemessaging.flutter.common;

import java.util.List;

import com.google.firebase.FirebaseOptions;

public class Configuration {
    /// The application code of your Application from Push Portal website
    String applicationCode;
    String pluginVersion = "unknown";
    boolean inAppChatEnabled;
    AndroidSettings androidSettings;
    PrivacySettings privacySettings;
    List<NotificationCategory> notificationCategories;
    boolean defaultMessageStorage;
    WebRTCUI webRTCUI;
    InAppChatCustomization inAppChatCustomization;

    public static class WebRTCUI {
        private String applicationId;

        public String getApplicationId() {
            return applicationId;
        }

        public void setApplicationId(String applicationId) {
            this.applicationId = applicationId;
        }
    }

    public static class AndroidSettings {
        String notificationIcon;
        boolean multipleNotifications;
        String notificationAccentColor;
        FirebaseOptions firebaseOptions;

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

    public static class InAppChatCustomization {
        String toolbarTitle;
        String toolbarTitleColor;
        String toolbarTintColor;
        String toolbarBackgroundColor;
        String sendButtonTintColor;
        String chatBackgroundColor;
        String noConnectionAlertTextColor;
        String noConnectionAlertBackgroundColor;
        String chatInputPlaceholderColor;
        String chatInputCursorColor;
        String chatInputBackgroundColor;
        String sendButtonIcon;
        String attachmentButtonIcon;
        Boolean chatInputSeparatorVisible;
        AndroidInAppChatCustomisation android;

        public String getToolbarTitle() {
            return toolbarTitle;
        }

        public void setToolbarTitle(String toolbarTitle) {
            this.toolbarTitle = toolbarTitle;
        }

        public String getToolbarTitleColor() {
            return toolbarTitleColor;
        }

        public void setToolbarTitleColor(String toolbarTitleColor) {
            this.toolbarTitleColor = toolbarTitleColor;
        }

        public String getToolbarTintColor() {
            return toolbarTintColor;
        }

        public void setToolbarTintColor(String toolbarTintColor) {
            this.toolbarTintColor = toolbarTintColor;
        }

        public String getToolbarBackgroundColor() {
            return toolbarBackgroundColor;
        }

        public void setToolbarBackgroundColor(String toolbarBackgroundColor) {
            this.toolbarBackgroundColor = toolbarBackgroundColor;
        }

        public String getSendButtonTintColor() {
            return sendButtonTintColor;
        }

        public void setSendButtonTintColor(String sendButtonTintColor) {
            this.sendButtonTintColor = sendButtonTintColor;
        }

        public String getChatBackgroundColor() {
            return chatBackgroundColor;
        }

        public void setChatBackgroundColor(String chatBackgroundColor) {
            this.chatBackgroundColor = chatBackgroundColor;
        }

        public String getNoConnectionAlertTextColor() {
            return noConnectionAlertTextColor;
        }

        public void setNoConnectionAlertTextColor(String noConnectionAlertTextColor) {
            this.noConnectionAlertTextColor = noConnectionAlertTextColor;
        }

        public String getNoConnectionAlertBackgroundColor() {
            return noConnectionAlertBackgroundColor;
        }

        public void setNoConnectionAlertBackgroundColor(String noConnectionAlertBackgroundColor) {
            this.noConnectionAlertBackgroundColor = noConnectionAlertBackgroundColor;
        }

        public String getChatInputPlaceholderColor() {
            return chatInputPlaceholderColor;
        }

        public void setChatInputPlaceholderColor(String chatInputPlaceholderColor) {
            this.chatInputPlaceholderColor = chatInputPlaceholderColor;
        }

        public String getChatInputCursorColor() {
            return chatInputCursorColor;
        }

        public void setChatInputCursorColor(String chatInputCursorColor) {
            this.chatInputCursorColor = chatInputCursorColor;
        }

        public String getChatInputBackgroundColor() {
            return chatInputBackgroundColor;
        }

        public void setChatInputBackgroundColor(String chatInputBackgroundColor) {
            this.chatInputBackgroundColor = chatInputBackgroundColor;
        }

        public String getSendButtonIcon() {
            return sendButtonIcon;
        }

        public void setSendButtonIcon(String sendButtonIcon) {
            this.sendButtonIcon = sendButtonIcon;
        }

        public String getAttachmentButtonIcon() {
            return attachmentButtonIcon;
        }

        public void setAttachmentButtonIcon(String attachmentButtonIcon) {
            this.attachmentButtonIcon = attachmentButtonIcon;
        }

        public Boolean getChatInputSeparatorVisible() {
            return chatInputSeparatorVisible;
        }

        public void setChatInputSeparatorVisible(Boolean chatInputSeparatorVisible) {
            this.chatInputSeparatorVisible = chatInputSeparatorVisible;
        }

        public AndroidInAppChatCustomisation getAndroid() {
            return android;
        }

        public void setAndroid(AndroidInAppChatCustomisation android) {
            this.android = android;
        }
    }

    public static class AndroidInAppChatCustomisation {
        String chatNavigationIconTint;
        String chatSubtitleTextColor;
        String chatInputTextColor;
        String chatProgressBarColor;
        String chatInputAttachmentIconTint;
        String chatInputSendIconTint;
        String chatInputSeparatorLineColor;
        String chatInputHintText;
        String chatSubtitleText;
        String chatSubtitleTextAppearanceRes;
        Boolean chatSubtitleCentered;
        Boolean chatTitleCentered;
        String chatInputTextAppearance;
        String chatNetworkConnectionErrorTextAppearanceRes;
        String chatNetworkConnectionErrorText;
        String chatNavigationIcon;
        Boolean chatStatusBarColorLight;
        String chatStatusBarBackgroundColor;
        String chatTitleTextAppearanceRes;

        public String getChatNavigationIconTint() {
            return chatNavigationIconTint;
        }

        public void setChatNavigationIconTint(String chatNavigationIconTint) {
            this.chatNavigationIconTint = chatNavigationIconTint;
        }

        public String getChatSubtitleTextColor() {
            return chatSubtitleTextColor;
        }

        public void setChatSubtitleTextColor(String chatSubtitleTextColor) {
            this.chatSubtitleTextColor = chatSubtitleTextColor;
        }

        public String getChatInputTextColor() {
            return chatInputTextColor;
        }

        public void setChatInputTextColor(String chatInputTextColor) {
            this.chatInputTextColor = chatInputTextColor;
        }

        public String getChatProgressBarColor() {
            return chatProgressBarColor;
        }

        public void setChatProgressBarColor(String chatProgressBarColor) {
            this.chatProgressBarColor = chatProgressBarColor;
        }

        public String getChatInputAttachmentIconTint() {
            return chatInputAttachmentIconTint;
        }

        public void setChatInputAttachmentIconTint(String chatInputAttachmentIconTint) {
            this.chatInputAttachmentIconTint = chatInputAttachmentIconTint;
        }

        public String getChatInputSendIconTint() {
            return chatInputSendIconTint;
        }

        public void setChatInputSendIconTint(String chatInputSendIconTint) {
            this.chatInputSendIconTint = chatInputSendIconTint;
        }

        public String getChatInputSeparatorLineColor() {
            return chatInputSeparatorLineColor;
        }

        public void setChatInputSeparatorLineColor(String chatInputSeparatorLineColor) {
            this.chatInputSeparatorLineColor = chatInputSeparatorLineColor;
        }

        public String getChatInputHintText() {
            return chatInputHintText;
        }

        public void setChatInputHintText(String chatInputHintText) {
            this.chatInputHintText = chatInputHintText;
        }

        public String getChatSubtitleText() {
            return chatSubtitleText;
        }

        public void setChatSubtitleText(String chatSubtitleText) {
            this.chatSubtitleText = chatSubtitleText;
        }

        public String getChatSubtitleTextAppearanceRes() {
            return chatSubtitleTextAppearanceRes;
        }

        public void setChatSubtitleTextAppearanceRes(String chatSubtitleTextAppearanceRes) {
            this.chatSubtitleTextAppearanceRes = chatSubtitleTextAppearanceRes;
        }

        public Boolean getChatSubtitleCentered() {
            return chatSubtitleCentered;
        }

        public void setChatSubtitleCentered(Boolean chatSubtitleCentered) {
            this.chatSubtitleCentered = chatSubtitleCentered;
        }

        public Boolean getChatTitleCentered() {
            return chatTitleCentered;
        }

        public void setChatTitleCentered(Boolean chatTitleCentered) {
            this.chatTitleCentered = chatTitleCentered;
        }

        public String getChatInputTextAppearance() {
            return chatInputTextAppearance;
        }

        public void setChatInputTextAppearance(String chatInputTextAppearance) {
            this.chatInputTextAppearance = chatInputTextAppearance;
        }

        public String getChatNetworkConnectionErrorTextAppearanceRes() {
            return chatNetworkConnectionErrorTextAppearanceRes;
        }

        public void setChatNetworkConnectionErrorTextAppearanceRes(String chatNetworkConnectionErrorTextAppearanceRes) {
            this.chatNetworkConnectionErrorTextAppearanceRes = chatNetworkConnectionErrorTextAppearanceRes;
        }

        public String getChatNavigationIcon() {
            return chatNavigationIcon;
        }

        public void setChatNavigationIcon(String chatNavigationIcon) {
            this.chatNavigationIcon = chatNavigationIcon;
        }

        public Boolean getChatStatusBarColorLight() {
            return chatStatusBarColorLight;
        }

        public void setChatStatusBarColorLight(Boolean chatStatusBarColorLight) {
            this.chatStatusBarColorLight = chatStatusBarColorLight;
        }

        public String getChatTitleTextAppearanceRes() {
            return chatTitleTextAppearanceRes;
        }

        public void setChatTitleTextAppearanceRes(String chatTitleTextAppearanceRes) {
            this.chatTitleTextAppearanceRes = chatTitleTextAppearanceRes;
        }

        public String getChatNetworkConnectionErrorText() {
            return chatNetworkConnectionErrorText;
        }

        public void setChatNetworkConnectionErrorText(String chatNetworkConnectionErrorText) {
            this.chatNetworkConnectionErrorText = chatNetworkConnectionErrorText;
        }

        public String getChatStatusBarBackgroundColor() {
            return chatStatusBarBackgroundColor;
        }

        public void setChatStatusBarBackgroundColor(String chatStatusBarBackgroundColor) {
            this.chatStatusBarBackgroundColor = chatStatusBarBackgroundColor;
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

    public InAppChatCustomization getCustomisation() {
        return inAppChatCustomization;
    }

    public void setCustomisation(InAppChatCustomization inAppChatCustomization) {
        this.inAppChatCustomization = inAppChatCustomization;
    }

    public boolean isInAppChatEnabled() {
        return inAppChatEnabled;
    }

    public void setInAppChatEnabled(boolean inAppChatEnabled) {
        this.inAppChatEnabled = inAppChatEnabled;
    }
}
