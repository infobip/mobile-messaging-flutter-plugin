enum OS {
  Android,
  iOS
}

class Installation {
  final bool? isPrimaryDevice;
  final bool? isPushRegistrationEnabled;
  final bool? notificationsEnabled;
  final bool? geoEnabled;
  final String? sdkVersion;
  final String? appVersion;
  final OS? os;
  final String? osVersion;
  final String? deviceManufacturer;
  final String? deviceModel;
  final bool? deviceSecure;
  final String? language;
  final String? deviceTimezoneId;
  final String? applicationUserId;
  final String? deviceName;
  final Map<String, dynamic>? customAttributes;

  Installation({
      this.isPrimaryDevice,
      this.isPushRegistrationEnabled,
      this.notificationsEnabled,
      this.geoEnabled,
      this.sdkVersion,
      this.appVersion,
      this.os,
      this.osVersion,
      this.deviceManufacturer,
      this.deviceModel,
      this.deviceSecure,
      this.language,
      this.deviceTimezoneId,
      this.applicationUserId,
      this.deviceName,
      this.customAttributes
  });

  static OS? fromString(String? str) {
    if (str == null) {
      return null;
    }
    try {
      return OS.values.firstWhere((e) => e.toString().split('.').last == str);
    } on Exception {
      return null;
    }
  }

  Map<String, dynamic> toJson() => {
        'isPrimaryDevice': isPrimaryDevice,
        'isPushRegistrationEnabled': isPushRegistrationEnabled,
        'notificationsEnabled': notificationsEnabled,
        'geoEnabled': geoEnabled,
        'sdkVersion': sdkVersion,
        'appVersion': appVersion,
        'os': os,
        'osVersion': osVersion,
        'deviceManufacturer': deviceManufacturer,
        'deviceModel': deviceModel,
        'deviceSecure': deviceSecure,
        'language': language,
        'deviceTimezoneId': deviceTimezoneId,
        'applicationUserId': applicationUserId,
        'deviceName': deviceName,
        'customAttributes': customAttributes,
      };

  Installation.fromJson(Map<String, dynamic> json)
      : isPrimaryDevice = json['isPrimaryDevice'],
        isPushRegistrationEnabled = json['isPushRegistrationEnabled'],
        notificationsEnabled = json['notificationsEnabled'],
        geoEnabled = json['geoEnabled'],
        sdkVersion = json['sdkVersion'],
        appVersion = json['appVersion'],
        os = Installation.fromString(json['os']),
        osVersion = json['osVersion'],
        deviceManufacturer = json['deviceManufacturer'],
        deviceModel = json['deviceModel'],
        deviceSecure = json['deviceSecure'],
        language = json['language'],
        deviceTimezoneId = json['deviceTimezoneId'],
        applicationUserId = json['applicationUserId'],
        deviceName = json['deviceName'],
        customAttributes = json['customAttributes'];
  }

  class InstallationPrimary {
    final String pushRegistrationId;
    final bool primary;

    InstallationPrimary(this.pushRegistrationId, this.primary);

    Map<String, dynamic> toJson() => {
      'pushRegistrationId': pushRegistrationId,
      'primary': primary
    };
  }
