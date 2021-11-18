import 'package:flutter/foundation.dart';

enum OS { Android, iOS }

enum PushServiceType { GCM, Firebase, APNS }

class Installation {
  final String? pushRegistrationId;
  final String? pushServiceToken;
  final PushServiceType? pushServiceType;
  bool? isPrimaryDevice;
  bool? isPushRegistrationEnabled;
  bool? notificationsEnabled;
  bool? geoEnabled;
  final String? sdkVersion;
  final String? appVersion;
  final OS? os;
  final String? osVersion;
  final String? deviceManufacturer;
  final String? deviceModel;
  final bool? deviceSecure;
  final String? language;
  final String? deviceTimezoneOffset;
  final String? applicationUserId;
  final String? deviceName;
  Map<String, dynamic>? customAttributes;

  Installation(
      {this.pushRegistrationId,
      this.pushServiceType,
      this.pushServiceToken,
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
      this.deviceTimezoneOffset,
      this.applicationUserId,
      this.deviceName,
      this.customAttributes});

  static PushServiceType? resolvePushServiceType(String? pst) {
    if (pst == null) {
      return null;
    }
    try {
      return PushServiceType.values
          .firstWhere((e) => e.toString().split('.').last == pst);
    } on Exception {
      return null;
    }
  }

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
        'pushRegistrationId': pushRegistrationId,
        'pushServiceToken': pushServiceToken,
        'pushServiceType':
            pushServiceType != null ? describeEnum(pushServiceType!) : null,
        'isPrimaryDevice': isPrimaryDevice,
        'isPushRegistrationEnabled': isPushRegistrationEnabled,
        'notificationsEnabled': notificationsEnabled,
        'geoEnabled': geoEnabled,
        'sdkVersion': sdkVersion,
        'appVersion': appVersion,
        'os': os != null ? describeEnum(os!) : null,
        'osVersion': osVersion,
        'deviceManufacturer': deviceManufacturer,
        'deviceModel': deviceModel,
        'deviceSecure': deviceSecure,
        'language': language,
        'deviceTimezoneOffset': deviceTimezoneOffset,
        'applicationUserId': applicationUserId,
        'deviceName': deviceName,
        'customAttributes': customAttributes,
      };

  Installation.fromJson(Map<String, dynamic> json)
      : isPrimaryDevice = json['isPrimaryDevice'],
        pushRegistrationId = json['pushRegistrationId'],
        pushServiceToken = json['pushServiceToken'],
        pushServiceType =
            Installation.resolvePushServiceType(json['pushServiceType']),
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
        deviceTimezoneOffset = json['deviceTimezoneOffset'],
        applicationUserId = json['applicationUserId'],
        deviceName = json['deviceName'],
        customAttributes = json['customAttributes'];

  String? getPushRegistrationId() {
    return this.pushRegistrationId;
  }
}

class InstallationPrimary {
  final String pushRegistrationId;
  final bool primary;

  InstallationPrimary(this.pushRegistrationId, this.primary);

  Map<String, dynamic> toJson() =>
      {'pushRegistrationId': pushRegistrationId, 'primary': primary};
}
