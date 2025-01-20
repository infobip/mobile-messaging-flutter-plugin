// ignore_for_file: constant_identifier_names
import 'package:collection/collection.dart';

enum OS { Android, iOS }

enum PushServiceType { GCM, Firebase, APNS }

class Installation {
  final String? pushRegistrationId;
  final String? pushServiceToken;
  final PushServiceType? pushServiceType;
  bool? isPrimaryDevice;
  bool? isPushRegistrationEnabled;
  bool? notificationsEnabled;
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

  Installation({
    this.pushRegistrationId,
    this.pushServiceType,
    this.pushServiceToken,
    this.isPrimaryDevice,
    this.isPushRegistrationEnabled,
    this.notificationsEnabled,
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
    this.customAttributes,
  });

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
            pushServiceType != null ? pushServiceType!.name : null,
        'isPrimaryDevice': isPrimaryDevice,
        'isPushRegistrationEnabled': isPushRegistrationEnabled,
        'notificationsEnabled': notificationsEnabled,
        'sdkVersion': sdkVersion,
        'appVersion': appVersion,
        'os': os != null ? os!.name : null,
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

  String? getPushRegistrationId() => pushRegistrationId;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Installation &&
          runtimeType == other.runtimeType &&
          pushRegistrationId == other.pushRegistrationId &&
          pushServiceToken == other.pushServiceToken &&
          pushServiceType == other.pushServiceType &&
          isPrimaryDevice == other.isPrimaryDevice &&
          isPushRegistrationEnabled == other.isPushRegistrationEnabled &&
          notificationsEnabled == other.notificationsEnabled &&
          sdkVersion == other.sdkVersion &&
          appVersion == other.appVersion &&
          os == other.os &&
          osVersion == other.osVersion &&
          deviceManufacturer == other.deviceManufacturer &&
          deviceModel == other.deviceModel &&
          deviceSecure == other.deviceSecure &&
          language == other.language &&
          deviceTimezoneOffset == other.deviceTimezoneOffset &&
          applicationUserId == other.applicationUserId &&
          deviceName == other.deviceName &&
          const DeepCollectionEquality()
              .equals(customAttributes, other.customAttributes);

  @override
  int get hashCode =>
      pushRegistrationId.hashCode ^
      pushServiceToken.hashCode ^
      pushServiceType.hashCode ^
      isPrimaryDevice.hashCode ^
      isPushRegistrationEnabled.hashCode ^
      notificationsEnabled.hashCode ^
      sdkVersion.hashCode ^
      appVersion.hashCode ^
      os.hashCode ^
      osVersion.hashCode ^
      deviceManufacturer.hashCode ^
      deviceModel.hashCode ^
      deviceSecure.hashCode ^
      language.hashCode ^
      deviceTimezoneOffset.hashCode ^
      applicationUserId.hashCode ^
      deviceName.hashCode ^
      customAttributes.hashCode;
}

class InstallationPrimary {
  final String pushRegistrationId;
  final bool primary;

  InstallationPrimary(this.pushRegistrationId, this.primary);

  Map<String, dynamic> toJson() =>
      {'pushRegistrationId': pushRegistrationId, 'primary': primary};
}
