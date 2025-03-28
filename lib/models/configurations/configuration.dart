import '../message_storage/default_message_storage.dart';

/// Mobile Messaging [Configuration] class.
class Configuration {
  /// The application code of your Application from <a href=https://portal.infobip.com/apps/mam/profiles>Infobip Portal</a>
  final String applicationCode;

  /// Version of the Mobile Messaging plugin.
  String? pluginVersion;

  /// Enables [In-App chat](https://www.infobip.com/docs/live-chat).
  final bool? inAppChatEnabled;

  /// Enables [In-App messages](https://www.infobip.com/docs/mobile-app-messaging/send-in-app-message).
  final bool? fullFeaturedInAppsEnabled;

  /// Android-only settings.
  final AndroidSettings? androidSettings;

  /// iOS-only settings.
  final IOSSettings? iosSettings;

  /// Privacy settings.
  final PrivacySettings? privacySettings;

  /// Notification categories for [Interactive notifications](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Interactive-notifications).
  final List<NotificationCategory>? notificationCategories;

  /// Enables [DefaultMessageStorage].
  final bool? defaultMessageStorage;

  /// Settings for [WebRTC](https://www.infobip.com/docs/voice-and-video/webrtc).
  final WebRTCUI? webRTCUI;

  /// Customization for LiveChat.
  @Deprecated('Should use [ChatCustomization] instead')
  final InAppChatCustomization? inAppChatCustomization;

  /// Default constructor with all params.
  Configuration({
    required this.applicationCode,
    this.pluginVersion,
    this.inAppChatEnabled,
    this.fullFeaturedInAppsEnabled,
    this.androidSettings,
    this.iosSettings,
    this.privacySettings,
    this.notificationCategories,
    this.defaultMessageStorage,
    this.webRTCUI,
    this.inAppChatCustomization,
  });

  /// Mapping [Configuration] to json.
  Map<String, dynamic> toJson() => {
        'applicationCode': applicationCode,
        'pluginVersion': pluginVersion,
        'inAppChatEnabled': inAppChatEnabled,
        'fullFeaturedInAppsEnabled': fullFeaturedInAppsEnabled,
        'androidSettings': androidSettings?.toJson(),
        'iosSettings': iosSettings?.toJson(),
        'privacySettings': privacySettings?.toJson(),
        'notificationCategories':
            (notificationCategories != null) ? notificationCategories!.map((e) => e.toJson()).toList() : null,
        'defaultMessageStorage': defaultMessageStorage,
        'webRTCUI': webRTCUI?.toJson(),
        // ignore: deprecated_member_use_from_same_package
        'inAppChatCustomization': inAppChatCustomization?.toJson(),
      };
}

/// Android specific settings.
class AndroidSettings {
  /// Helper class to initialize Firebase configuration using key/values.
  final FirebaseOptions? firebaseOptions;

  /// A resource name for a status bar icon (without extension), located in '/platforms/android/app/src/main/res/mipmap'
  final String? notificationIcon;

  /// Should multiple notifications in status bar be shown. By default only the latest notification is shown.
  final bool? multipleNotifications;

  /// Accent color for notification.
  final String? notificationAccentColor;

  /// Default constructor with all params.
  AndroidSettings({
    this.firebaseOptions,
    this.notificationIcon,
    this.multipleNotifications,
    this.notificationAccentColor,
  });

  /// Mapping [AndroidSettings] to json.
  Map<String, dynamic> toJson() => {
        'firebaseOptions': firebaseOptions?.toJson(),
        'notificationIcon': notificationIcon,
        'multipleNotifications': multipleNotifications,
        'notificationAccentColor': notificationAccentColor,
      };
}

/// Helper class to initialize Firebase configuration using key/values. Recommended to use Firebase configuration file instead, [docs](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Applying-Firebase-configuration-in-MobileMessaging-Flutter-plugin).
class FirebaseOptions {
  final String apiKey;
  final String applicationId;
  final String projectId;
  final String? databaseUrl;
  final String? gaTrackingId;
  final String? gcmSenderId;
  final String? storageBucket;

  FirebaseOptions({
    required this.apiKey,
    required this.applicationId,
    required this.projectId,
    this.databaseUrl,
    this.gaTrackingId,
    this.gcmSenderId,
    this.storageBucket,
  });

  Map<String, dynamic> toJson() => {
        'apiKey': apiKey,
        'applicationId': applicationId,
        'databaseUrl': databaseUrl,
        'gaTrackingId': gaTrackingId,
        'gcmSenderId': gcmSenderId,
        'storageBucket': storageBucket,
        'projectId': projectId,
      };
}

/// iOS specific settings.
class IOSSettings {
  /// List of notification types, recommended settings `['alert', 'badge', 'sound']`.
  final List<String>? notificationTypes;

  /// Perform deletion of local data on start.
  final bool? forceCleanup;

  /// Enables logging in Debug runs in XCode, recommended value `true`.
  final bool? logging;

  /// WebView settings.
  final WebViewSettings? webViewSettings;

  /// Postpone registering for push notifications from app start.
  final bool? withoutRegisteringForRemoteNotifications;

  /// Default constructor with all params.
  IOSSettings({
    this.notificationTypes,
    this.forceCleanup,
    this.logging,
    this.webViewSettings,
    this.withoutRegisteringForRemoteNotifications,
  });

  /// Mapping [IOSSettings] to json.
  Map<String, dynamic> toJson() => {
        'notificationTypes': notificationTypes,
        'forceCleanup': forceCleanup,
        'logging': logging,
        'webViewSettings': webViewSettings?.toJson(),
        'withoutRegisteringForRemoteNotifications': withoutRegisteringForRemoteNotifications,
      };
}

/// Helper class for iOS WebView settings.
class WebViewSettings {
  final String? title;
  final String? barTintColor;
  final String? titleColor;
  final String? tintColor;

  WebViewSettings({
    this.title,
    this.barTintColor,
    this.tintColor,
    this.titleColor,
  });

  /// Mapping [WebViewSettings] to json.
  Map<String, dynamic> toJson() => {
        'title': title,
        'barTintColor': barTintColor,
        'titleColor': titleColor,
        'tintColor': tintColor,
      };
}

/// Helper class with privacy settings.
class PrivacySettings {
  final bool? applicationCodePersistingDisabled;
  final bool? userDataPersistingDisabled;
  final bool? carrierInfoSendingDisabled;
  final bool? systemInfoSendingDisabled;

  PrivacySettings({
    this.applicationCodePersistingDisabled,
    this.userDataPersistingDisabled,
    this.carrierInfoSendingDisabled,
    this.systemInfoSendingDisabled,
  });

  Map<String, dynamic> toJson() => {
        'applicationCodePersistingDisabled': applicationCodePersistingDisabled,
        'userDataPersistingDisabled': userDataPersistingDisabled,
        'carrierInfoSendingDisabled': carrierInfoSendingDisabled,
        'systemInfoSendingDisabled': systemInfoSendingDisabled,
      };
}

/// Helper class for setting interactive notifications' action.
class NotificationAction {
  final String? identifier;
  final String? title;
  final bool? foreground;
  final bool? authenticationRequired;
  final bool? moRequired;
  final bool? destructive;
  final String? icon;
  final String? textInputActionButtonTitle;
  final String? textInputPlaceholder;

  NotificationAction({
    this.identifier,
    this.title,
    this.foreground,
    this.authenticationRequired,
    this.moRequired,
    this.destructive,
    this.icon,
    this.textInputActionButtonTitle,
    this.textInputPlaceholder,
  });

  Map<String, dynamic> toJson() => {
        'identifier': identifier,
        'title': title,
        'foreground': foreground,
        'authenticationRequired': authenticationRequired,
        'moRequired': moRequired,
        'destructive': destructive,
        'icon': icon,
        'textInputActionButtonTitle': textInputActionButtonTitle,
        'textInputPlaceholder': textInputPlaceholder,
      };
}

class NotificationCategory {
  final String? identifier;
  final List<NotificationAction>? actions;

  NotificationCategory({
    required this.identifier,
    required this.actions,
  });

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>>? actions = this.actions!.map((i) => i.toJson()).toList();
    return {
      'identifier': identifier,
      'actions': actions,
    };
  }
}

class WebRTCUI {
  final String? configurationId;

  WebRTCUI({this.configurationId});

  Map<String, dynamic> toJson() => {'configurationId': configurationId};
}

class ToolbarCustomization {
  final String? titleTextAppearance;
  final String? titleTextColor;
  final String? titleText;
  final bool? titleCentered;
  final String? backgroundColor;
  final String? navigationIcon;
  final String? navigationIconTint;
  final String? subtitleTextAppearance; // android only
  final String? subtitleTextColor; // android only
  final String? subtitleText; // android only
  final bool? subtitleCentered; // android only

  ToolbarCustomization({
    this.titleTextAppearance,
    this.titleTextColor,
    this.titleText,
    this.titleCentered,
    this.backgroundColor,
    this.navigationIcon,
    this.navigationIconTint,
    this.subtitleTextAppearance,
    this.subtitleTextColor,
    this.subtitleText,
    this.subtitleCentered,
  });

  Map<String, dynamic> toJson() => {
        'titleTextAppearance': titleTextAppearance,
        'titleTextColor': titleTextColor,
        'titleText': titleText,
        'titleCentered': titleCentered,
        'backgroundColor': backgroundColor,
        'navigationIcon': navigationIcon,
        'navigationIconTint': navigationIconTint,
        'subtitleTextAppearance': subtitleTextAppearance,
        'subtitleTextColor': subtitleTextColor,
        'subtitleText': subtitleText,
        'subtitleCentered': subtitleCentered,
      };
}

class ChatCustomization {
  //	StatusBar
  final String? chatStatusBarBackgroundColor;
  final String? chatStatusBarIconsColorMode;

  // Toolbar
  final ToolbarCustomization? chatToolbar;
  final ToolbarCustomization? attachmentPreviewToolbar;
  final String? attachmentPreviewToolbarSaveMenuItemIcon;
  final String? attachmentPreviewToolbarMenuItemsIconTint;

  // NetworkError
  final String? networkErrorText;
  final String? networkErrorTextColor;
  final String? networkErrorTextAppearance;
  final String? networkErrorLabelBackgroundColor;

  // Chat
  final String? chatBackgroundColor;
  final String? chatProgressBarColor;

  // Input
  final String? chatInputTextAppearance;
  final String? chatInputTextColor;
  final String? chatInputBackgroundColor;
  final String? chatInputHintText;
  final String? chatInputHintTextColor;
  final String? chatInputAttachmentIcon;
  final String? chatInputAttachmentIconTint;
  final String? chatInputAttachmentBackgroundDrawable;
  final String? chatInputAttachmentBackgroundColor;
  final String? chatInputSendIcon;
  final String? chatInputSendIconTint;
  final String? chatInputSendBackgroundDrawable;
  final String? chatInputSendBackgroundColor;
  final String? chatInputSeparatorLineColor;
  final bool? chatInputSeparatorLineVisible;
  final String? chatInputCursorColor;
  final bool? shouldHandleKeyboardAppearance; // iOS only

  ChatCustomization({
    this.chatStatusBarBackgroundColor,
    this.chatStatusBarIconsColorMode,
    this.chatToolbar,
    this.attachmentPreviewToolbar,
    this.attachmentPreviewToolbarSaveMenuItemIcon,
    this.attachmentPreviewToolbarMenuItemsIconTint,
    this.networkErrorText,
    this.networkErrorTextColor,
    this.networkErrorTextAppearance,
    this.networkErrorLabelBackgroundColor,
    this.chatBackgroundColor,
    this.chatProgressBarColor,
    this.chatInputTextAppearance,
    this.chatInputTextColor,
    this.chatInputBackgroundColor,
    this.chatInputHintText,
    this.chatInputHintTextColor,
    this.chatInputAttachmentIcon,
    this.chatInputAttachmentIconTint,
    this.chatInputAttachmentBackgroundDrawable,
    this.chatInputAttachmentBackgroundColor,
    this.chatInputSendIcon,
    this.chatInputSendIconTint,
    this.chatInputSendBackgroundDrawable,
    this.chatInputSendBackgroundColor,
    this.chatInputSeparatorLineColor,
    this.chatInputSeparatorLineVisible,
    this.chatInputCursorColor,
    this.shouldHandleKeyboardAppearance,
  });

  Map<String, dynamic> toJson() => {
        'chatStatusBarBackgroundColor': chatStatusBarBackgroundColor,
        'chatStatusBarIconsColorMode': chatStatusBarIconsColorMode,
        'chatToolbar': chatToolbar,
        'attachmentPreviewToolbar': attachmentPreviewToolbar,
        'attachmentPreviewToolbarSaveMenuItemIcon': attachmentPreviewToolbarSaveMenuItemIcon,
        'attachmentPreviewToolbarMenuItemsIconTint': attachmentPreviewToolbarMenuItemsIconTint,
        'networkErrorText': networkErrorText,
        'networkErrorTextColor': networkErrorTextColor,
        'networkErrorTextAppearance': networkErrorTextAppearance,
        'networkErrorLabelBackgroundColor': networkErrorLabelBackgroundColor,
        'chatBackgroundColor': chatBackgroundColor,
        'chatProgressBarColor': chatProgressBarColor,
        'chatInputTextAppearance': chatInputTextAppearance,
        'chatInputTextColor': chatInputTextColor,
        'chatInputBackgroundColor': chatInputBackgroundColor,
        'chatInputHintText': chatInputHintText,
        'chatInputHintTextColor': chatInputHintTextColor,
        'chatInputAttachmentIcon': chatInputAttachmentIcon,
        'chatInputAttachmentIconTint': chatInputAttachmentIconTint,
        'chatInputAttachmentBackgroundDrawable': chatInputAttachmentBackgroundDrawable,
        'chatInputAttachmentBackgroundColor': chatInputAttachmentBackgroundColor,
        'chatInputSendIcon': chatInputSendIcon,
        'chatInputSendIconTint': chatInputSendIconTint,
        'chatInputSendBackgroundDrawable': chatInputSendBackgroundDrawable,
        'chatInputSendBackgroundColor': chatInputSendBackgroundColor,
        'chatInputSeparatorLineColor': chatInputSeparatorLineColor,
        'chatInputSeparatorLineVisible': chatInputSeparatorLineVisible,
        'chatInputCursorColor': chatInputCursorColor,
        'shouldHandleKeyboardAppearance': shouldHandleKeyboardAppearance,
      };
}

@Deprecated('Should use [ChatCustomization] instead')
class InAppChatCustomization {
  final String? toolbarTitle;
  final String? toolbarTitleColor;
  final String? toolbarTintColor;
  final String? toolbarBackgroundColor;
  final String? sendButtonTintColor;
  final String? chatBackgroundColor;
  final String? widgetTheme;
  final String? noConnectionAlertTextColor;
  final String? noConnectionAlertBackgroundColor;
  final String? chatInputPlaceholderColor;
  final String? chatInputCursorColor;
  final String? chatInputBackgroundColor;
  final String? sendButtonIcon;
  final String? attachmentButtonIcon;
  final bool? chatInputSeparatorVisible;
  final AndroidInAppChatCustomization? android;
  final IOSInAppChatCustomization? ios;

  InAppChatCustomization({
    this.toolbarTitle,
    this.toolbarTitleColor,
    this.toolbarTintColor,
    this.toolbarBackgroundColor,
    this.sendButtonTintColor,
    this.chatBackgroundColor,
    this.widgetTheme,
    this.noConnectionAlertTextColor,
    this.noConnectionAlertBackgroundColor,
    this.chatInputPlaceholderColor,
    this.chatInputCursorColor,
    this.chatInputBackgroundColor,
    this.sendButtonIcon,
    this.attachmentButtonIcon,
    this.chatInputSeparatorVisible,
    this.android,
    this.ios,
  });

  Map<String, dynamic> toJson() => {
        'toolbarTitle': toolbarTitle,
        'toolbarTitleColor': toolbarTitleColor,
        'toolbarTintColor': toolbarTintColor,
        'toolbarBackgroundColor': toolbarBackgroundColor,
        'sendButtonTintColor': sendButtonTintColor,
        'chatBackgroundColor': chatBackgroundColor,
        'widgetTheme': widgetTheme,
        'noConnectionAlertTextColor': noConnectionAlertTextColor,
        'noConnectionAlertBackgroundColor': noConnectionAlertBackgroundColor,
        'chatInputPlaceholderColor': chatInputPlaceholderColor,
        'chatInputCursorColor': chatInputCursorColor,
        'chatInputBackgroundColor': chatInputBackgroundColor,
        'sendButtonIcon': sendButtonIcon,
        'attachmentButtonIcon': attachmentButtonIcon,
        'chatInputSeparatorVisible': chatInputSeparatorVisible,
        'android': android?.toJson(),
        'ios': ios?.toJson(),
      };
}

class AndroidInAppChatCustomization {
  //status bar
  final bool? chatStatusBarColorLight;
  final String? chatStatusBarBackgroundColor;

  //toolbar
  final String? chatNavigationIcon;
  final String? chatNavigationIconTint;
  final String? chatSubtitleText;
  final String? chatSubtitleTextColor;
  final String? chatSubtitleTextAppearanceRes;
  final bool? chatSubtitleCentered;
  final bool? chatTitleCentered;
  final String? chatTitleTextAppearanceRes;
  final String? chatMenuItemsIconTint;
  final String? chatMenuItemSaveAttachmentIcon;

  //chat
  final String? chatProgressBarColor;
  final String? chatNetworkConnectionErrorTextAppearanceRes;
  final String? chatNetworkConnectionErrorText;

  //input
  final String? chatInputTextColor;
  final String? chatInputAttachmentIconTint;
  final String? chatInputAttachmentBackgroundColor;
  final String? chatInputAttachmentBackgroundDrawable;
  final String? chatInputSendIconTint;
  final String? chatInputSendBackgroundColor;
  final String? chatInputSendBackgroundDrawable;
  final String? chatInputSeparatorLineColor;
  final String? chatInputHintText;
  final String? chatInputTextAppearance;

  AndroidInAppChatCustomization({
    //status bar
    this.chatStatusBarColorLight,
    this.chatStatusBarBackgroundColor,
    //toolbar
    this.chatNavigationIcon,
    this.chatNavigationIconTint,
    this.chatSubtitleText,
    this.chatSubtitleTextColor,
    this.chatSubtitleTextAppearanceRes,
    this.chatSubtitleCentered,
    this.chatTitleCentered,
    this.chatTitleTextAppearanceRes,
    this.chatMenuItemsIconTint,
    this.chatMenuItemSaveAttachmentIcon,
    //chat
    this.chatProgressBarColor,
    this.chatNetworkConnectionErrorTextAppearanceRes,
    this.chatNetworkConnectionErrorText,
    //input
    this.chatInputTextColor,
    this.chatInputAttachmentIconTint,
    this.chatInputAttachmentBackgroundColor,
    this.chatInputAttachmentBackgroundDrawable,
    this.chatInputSendIconTint,
    this.chatInputSendBackgroundColor,
    this.chatInputSendBackgroundDrawable,
    this.chatInputSeparatorLineColor,
    this.chatInputHintText,
    this.chatInputTextAppearance,
  });

  Map<String, dynamic> toJson() => {
        //status bar
        'chatStatusBarColorLight': chatStatusBarColorLight,
        'chatStatusBarBackgroundColor': chatStatusBarBackgroundColor,
        //toolbar
        'chatNavigationIcon': chatNavigationIcon,
        'chatNavigationIconTint': chatNavigationIconTint,
        'chatSubtitleText': chatSubtitleText,
        'chatSubtitleTextColor': chatSubtitleTextColor,
        'chatSubtitleTextAppearanceRes': chatSubtitleTextAppearanceRes,
        'chatSubtitleCentered': chatSubtitleCentered,
        'chatTitleCentered': chatTitleCentered,
        'chatTitleTextAppearanceRes': chatTitleTextAppearanceRes,
        'chatMenuItemsIconTint': chatMenuItemsIconTint,
        'chatMenuItemSaveAttachmentIcon': chatMenuItemSaveAttachmentIcon,
        //chat
        'chatProgressBarColor': chatProgressBarColor,
        'chatNetworkConnectionErrorTextAppearanceRes': chatNetworkConnectionErrorTextAppearanceRes,
        'chatNetworkConnectionErrorText': chatNetworkConnectionErrorText,
        //input
        'chatInputTextColor': chatInputTextColor,
        'chatInputAttachmentIconTint': chatInputAttachmentIconTint,
        'chatInputAttachmentBackgroundColor': chatInputAttachmentBackgroundColor,
        'chatInputAttachmentBackgroundDrawable': chatInputAttachmentBackgroundDrawable,
        'chatInputSendIconTint': chatInputSendIconTint,
        'chatInputSendBackgroundColor': chatInputSendBackgroundColor,
        'chatInputSendBackgroundDrawable': chatInputSendBackgroundDrawable,
        'chatInputSeparatorLineColor': chatInputSeparatorLineColor,
        'chatInputHintText': chatInputHintText,
        'chatInputTextAppearance': chatInputTextAppearance,
      };
}

@Deprecated('Should use [ChatCustomization] instead')
class IOSInAppChatCustomization {
  final String? attachmentPreviewBarsColor;
  final String? attachmentPreviewItemsColor;
  final double? textContainerTopMargin;
  final double? textContainerLeftPadding;
  final double? textContainerCornerRadius;
  final double? textViewTopMargin;
  final double? placeholderHeight;
  final double? placeholderSideMargin;
  final double? buttonHeight;
  final double? buttonTouchableOverlap;
  final double? buttonRightMargin;
  final double? utilityButtonWidth;
  final double? utilityButtonBottomMargin;
  final double? initialHeight;
  final String? mainFont;
  final String? charCountFont;

  IOSInAppChatCustomization({
    this.attachmentPreviewBarsColor,
    this.attachmentPreviewItemsColor,
    this.textContainerTopMargin,
    this.textContainerLeftPadding,
    this.textContainerCornerRadius,
    this.textViewTopMargin,
    this.placeholderHeight,
    this.placeholderSideMargin,
    this.buttonHeight,
    this.buttonTouchableOverlap,
    this.buttonRightMargin,
    this.utilityButtonWidth,
    this.utilityButtonBottomMargin,
    this.initialHeight,
    this.mainFont,
    this.charCountFont,
  });

  Map<String, dynamic> toJson() => {
        'attachmentPreviewBarsColor': attachmentPreviewBarsColor,
        'attachmentPreviewItemsColor': attachmentPreviewItemsColor,
        'textContainerTopMargin': textContainerTopMargin,
        'textContainerLeftPadding': textContainerLeftPadding,
        'textContainerCornerRadius': textContainerCornerRadius,
        'textViewTopMargin': textViewTopMargin,
        'placeholderHeight': placeholderHeight,
        'placeholderSideMargin': placeholderSideMargin,
        'buttonHeight': buttonHeight,
        'buttonTouchableOverlap': buttonTouchableOverlap,
        'buttonRightMargin': buttonRightMargin,
        'utilityButtonWidth': utilityButtonWidth,
        'utilityButtonBottomMargin': utilityButtonBottomMargin,
        'initialHeight': initialHeight,
        'mainFont': mainFont,
        'charCountFont': charCountFont,
      };
}
