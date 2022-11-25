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

  Configuration({
    required this.applicationCode,
    this.pluginVersion,
    this.inAppChatEnabled,
    this.androidSettings,
    this.iosSettings,
    this.privacySettings,
    this.notificationCategories,
    this.defaultMessageStorage,
  });

  Map<String, dynamic> toJson() => {
        'applicationCode': applicationCode,
        'pluginVersion': pluginVersion,
        'inAppChatEnabled': inAppChatEnabled,
        'androidSettings': androidSettings?.toJson(),
        'iosSettings': iosSettings?.toJson(),
        'privacySettings': privacySettings?.toJson(),
        'notificationCategories':
            (notificationCategories != null) ? notificationCategories!.map((e) => e.toJson()) : null,
        'defaultMessageStorage': defaultMessageStorage
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

  IOSSettings({
    this.notificationTypes,
    this.forceCleanup,
    this.logging,
    this.webViewSettings,
  });

  Map<String, dynamic> toJson() => {
        'notificationTypes': notificationTypes,
        'forceCleanup': forceCleanup,
        'logging': logging,
        'webViewSettings': webViewSettings?.toJson()
      };
}

class WebViewSettings {
  final String? title;
  final String? barTintColor;
  final String? titleColor;
  final String? tintColor;

  WebViewSettings({this.title, this.barTintColor, this.tintColor, this.titleColor});

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
    List<Map<String, dynamic>>? actions = this.actions!.map((i) => i.toJson()).toList();
    return {
      'identifier': identifier,
      'actions': actions,
    };
  }
}
