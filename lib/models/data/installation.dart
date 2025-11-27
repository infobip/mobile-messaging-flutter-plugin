//
//  installation.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'package:collection/collection.dart';
import '../../infobip_mobilemessaging.dart';

/// Enum with values for OS. Possible values: Android, iOS.
// ignore: constant_identifier_names, public_member_api_docs
enum OS { Android, iOS }

/// Enum with values for push notifications service type. Values: GCM, Firebase, APNS.
// ignore: constant_identifier_names, public_member_api_docs
enum PushServiceType { GCM, Firebase, APNS }

/// Mobile Messaging [Installation] class.
class Installation {
  /// Push registration ID of the installation issued by Infobip platform.
  final String? pushRegistrationId;

  /// Token issued by respective push service.
  final String? pushServiceToken;

  /// Type of the push service.
  final PushServiceType? pushServiceType;

  /// Flag to indicate if installation is primary. Can be used to distinguish main device of user, and to target only it
  /// to deliver sensitive messages.
  bool? isPrimaryDevice;

  /// Flag if installation opted-in for receiving push notifications on OS level.
  bool? isPushRegistrationEnabled;

  /// Flag if installation opted-in for receiving push notifications on app level.
  bool? notificationsEnabled;

  /// Mobile Messaging SDK version.
  final String? sdkVersion;

  /// Application version.
  final String? appVersion;

  /// [OS] value.
  final OS? os;

  /// OS version.
  final String? osVersion;

  /// Device manufacturer name.
  final String? deviceManufacturer;

  /// Model of the device.
  final String? deviceModel;

  /// Flag if device screen lock is enabled.
  final bool? deviceSecure;

  /// Device language.
  final String? language;

  /// Timezone from system settings, difference from UTC.
  final String? deviceTimezoneOffset;

  /// iOS specific internal setting.
  final String? applicationUserId;

  /// Name of the device.
  final String? deviceName;

  /// Installation-level custom attributes.
  Map<String, dynamic>? customAttributes;

  /// Default constructor with all params. Use [InfobipMobilemessaging.fetchInstallation] or
  /// [InfobipMobilemessaging.getInstallation] to get [Installation].
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

  static PushServiceType? _resolvePushServiceType(String? pst) {
    if (pst == null) {
      return null;
    }
    try {
      return PushServiceType.values.firstWhere((e) => e.toString().split('.').last == pst);
    } on Exception {
      return null;
    }
  }

  static OS? _fromString(String? str) {
    if (str == null) {
      return null;
    }
    try {
      return OS.values.firstWhere((e) => e.toString().split('.').last == str);
    } on Exception {
      return null;
    }
  }

  /// Mapping [Installation] to json.
  Map<String, dynamic> toJson() => {
        'pushRegistrationId': pushRegistrationId,
        'pushServiceToken': pushServiceToken,
        'pushServiceType': pushServiceType?.name,
        'isPrimaryDevice': isPrimaryDevice,
        'isPushRegistrationEnabled': isPushRegistrationEnabled,
        'notificationsEnabled': notificationsEnabled,
        'sdkVersion': sdkVersion,
        'appVersion': appVersion,
        'os': os?.name,
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

  /// Parsing [Installation] from json.
  Installation.fromJson(Map<String, dynamic> json)
      : isPrimaryDevice = json['isPrimaryDevice'],
        pushRegistrationId = json['pushRegistrationId'],
        pushServiceToken = json['pushServiceToken'],
        pushServiceType = _resolvePushServiceType(json['pushServiceType']),
        isPushRegistrationEnabled = json['isPushRegistrationEnabled'],
        notificationsEnabled = json['notificationsEnabled'],
        sdkVersion = json['sdkVersion'],
        appVersion = json['appVersion'],
        os = _fromString(json['os']),
        osVersion = json['osVersion'],
        deviceManufacturer = json['deviceManufacturer'],
        deviceModel = json['deviceModel'],
        deviceSecure = json['deviceSecure'],
        language = json['language'],
        deviceTimezoneOffset = json['deviceTimezoneOffset'],
        applicationUserId = json['applicationUserId'],
        deviceName = json['deviceName'],
        customAttributes = json['customAttributes'];

  /// Returns [pushRegistrationId] for installation.
  String? getPushRegistrationId() => pushRegistrationId;

  static const DeepCollectionEquality _deepCollectionEquality = DeepCollectionEquality();

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
          _deepCollectionEquality.equals(customAttributes, other.customAttributes);

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
      _deepCollectionEquality.hash(customAttributes);
}

/// Helper class for setting [Installation] as a primary.
class InstallationPrimary {
  /// Push registration ID of the device to set as primary.
  final String pushRegistrationId;

  /// Should be set to true.
  final bool primary;

  /// Default constructor with all params.
  InstallationPrimary(this.pushRegistrationId, this.primary);

  /// Mapping [InstallationPrimary] to json.
  Map<String, dynamic> toJson() => {'pushRegistrationId': pushRegistrationId, 'primary': primary};
}
