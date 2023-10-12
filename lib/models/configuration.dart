class Configuration {
  /// The application code of your Application from Push Portal website
  final String applicationCode;

  String? pluginVersion;

  final bool? inAppChatEnabled;

  final AndroidSettings? androidSettings;

  final IOSSettings? iosSettings;

  final PrivacySettings? privacySettings;

  final List<NotificationCategory>? notificationCategories;

  final bool? defaultMessageStorage;

  final WebRTCUI? webRTCUI;

  final InAppChatCustomization? inAppChatCustomization;

  Configuration(
      {required this.applicationCode,
      this.pluginVersion,
      this.inAppChatEnabled,
      this.androidSettings,
      this.iosSettings,
      this.privacySettings,
      this.notificationCategories,
      this.defaultMessageStorage,
      this.webRTCUI,
      this.inAppChatCustomization});

  Map<String, dynamic> toJson() => {
        'applicationCode': applicationCode,
        'pluginVersion': pluginVersion,
        'inAppChatEnabled': inAppChatEnabled,
        'androidSettings': androidSettings?.toJson(),
        'iosSettings': iosSettings?.toJson(),
        'privacySettings': privacySettings?.toJson(),
        'notificationCategories': (notificationCategories != null)
            ? notificationCategories!.map((e) => e.toJson())
            : null,
        'defaultMessageStorage': defaultMessageStorage,
        'webRTCUI': webRTCUI?.toJson(),
        'inAppChatCustomization': inAppChatCustomization?.toJson()
      };
}

class AndroidSettings {
  final FirebaseOptions? firebaseOptions;

  // A resource name for a status bar icon (without extension), located in '/platforms/android/app/src/main/res/mipmap'
  final String? notificationIcon;
  final bool? multipleNotifications;
  final String? notificationAccentColor;

  AndroidSettings({
    this.firebaseOptions,
    this.notificationIcon,
    this.multipleNotifications,
    this.notificationAccentColor,
  });

  Map<String, dynamic> toJson() => {
        'firebaseOptions': firebaseOptions?.toJson(),
        'notificationIcon': notificationIcon,
        'multipleNotifications': multipleNotifications,
        'notificationAccentColor': notificationAccentColor
      };
}

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
        'projectId': projectId
      };
}

class IOSSettings {
  final List<String>? notificationTypes;
  final bool? forceCleanup;
  final bool? logging;
  final WebViewSettings? webViewSettings;
  final bool? withoutRegisteringForRemoteNotifications;

  IOSSettings(
      {this.notificationTypes,
      this.forceCleanup,
      this.logging,
      this.webViewSettings,
      this.withoutRegisteringForRemoteNotifications});

  Map<String, dynamic> toJson() => {
        'notificationTypes': notificationTypes,
        'forceCleanup': forceCleanup,
        'logging': logging,
        'webViewSettings': webViewSettings?.toJson(),
        'withoutRegisteringForRemoteNotifications':
            withoutRegisteringForRemoteNotifications
      };
}

class WebViewSettings {
  final String? title;
  final String? barTintColor;
  final String? titleColor;
  final String? tintColor;

  WebViewSettings(
      {this.title, this.barTintColor, this.tintColor, this.titleColor});

  Map<String, dynamic> toJson() => {
        'title': title,
        'barTintColor': barTintColor,
        'titleColor': titleColor,
        'tintColor': tintColor,
      };
}

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
        'systemInfoSendingDisabled': systemInfoSendingDisabled
      };
}

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
    this.identifier,
    this.actions,
  });

  Map<String, dynamic> toJson() {
    List<Map<String, dynamic>>? actions =
        this.actions!.map((i) => i.toJson()).toList();
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

class InAppChatCustomization {
  final String? toolbarTitle;
  final String? toolbarTitleColor;
  final String? toolbarTintColor;
  final String? toolbarBackgroundColor;
  final String? sendButtonTintColor;
  final String? chatBackgroundColor;
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
      this.noConnectionAlertTextColor,
      this.noConnectionAlertBackgroundColor,
      this.chatInputPlaceholderColor,
      this.chatInputCursorColor,
      this.chatInputBackgroundColor,
      this.sendButtonIcon,
      this.attachmentButtonIcon,
      this.chatInputSeparatorVisible,
      this.android,
      this.ios});

  Map<String, dynamic> toJson() => {
        'toolbarTitle': toolbarTitle,
        'toolbarTitleColor': toolbarTitleColor,
        'toolbarTintColor': toolbarTintColor,
        'toolbarBackgroundColor': toolbarBackgroundColor,
        'sendButtonTintColor': sendButtonTintColor,
        'chatBackgroundColor': chatBackgroundColor,
        'noConnectionAlertTextColor': noConnectionAlertTextColor,
        'noConnectionAlertBackgroundColor': noConnectionAlertBackgroundColor,
        'chatInputPlaceholderColor': chatInputPlaceholderColor,
        'chatInputCursorColor': chatInputCursorColor,
        'chatInputBackgroundColor': chatInputBackgroundColor,
        'sendButtonIcon': sendButtonIcon,
        'attachmentButtonIcon': attachmentButtonIcon,
        'chatInputSeparatorVisible': chatInputSeparatorVisible,
        'android': android?.toJson(),
        'ios': ios?.toJson()
      };
}

class AndroidInAppChatCustomization {
  final String? chatNavigationIconTint;
  final String? chatSubtitleTextColor;
  final String? chatInputTextColor;
  final String? chatProgressBarColor;
  final String? chatInputAttachmentIconTint;
  final String? chatInputSendIconTint;
  final String? chatInputSeparatorLineColor;
  final String? chatInputHintText;
  final String? chatSubtitleText;
  final String? chatSubtitleTextAppearanceRes;
  final bool? chatSubtitleCentered;
  final bool? chatTitleCentered;
  final String? chatInputTextAppearance;
  final String? chatNetworkConnectionErrorTextAppearanceRes;
  final String? chatNetworkConnectionErrorText;
  final String? chatNavigationIcon;
  final bool? chatStatusBarColorLight;
  final String? chatTitleTextAppearanceRes;
  final String? chatStatusBarBackgroundColor;
  final String? chatInputAttachmentBackgroundDrawable;
  final String? chatInputAttachmentBackgroundColor;
  final String? chatInputSendBackgroundDrawable;
  final String? chatInputSendBackgroundColor;

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
    this.chatInputTextAppearance
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
        'chatInputTextAppearance': chatInputTextAppearance
      };
}

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

  IOSInAppChatCustomization({this.attachmentPreviewBarsColor,
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
      this.charCountFont});

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
        'charCountFont': charCountFont
      };
}
