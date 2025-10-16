//
//  personalize_context.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'user_data.dart';

/// [UserIdentity] class used for personalization.
class UserIdentity {
  /// List of phones in [E.164 format](https://en.wikipedia.org/wiki/E.164), i.e. `38516419710`.
  final List<String>? phones;

  /// List of emails in [rfc2822 format](https://datatracker.ietf.org/doc/html/rfc2822), i.e. `user@infobip.com`.
  final List<String>? emails;

  /// ExternalUserId.
  final String? externalUserId;

  /// Default constructor with all params.
  UserIdentity({
    this.phones,
    this.emails,
    this.externalUserId,
  });

  /// Mapping [UserIdentity] to json.
  Map<String, dynamic> toJson() => {
        'phones': phones,
        'emails': emails,
        'externalUserId': externalUserId,
      }..removeWhere((dynamic key, dynamic value) => value == null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserIdentity &&
          runtimeType == other.runtimeType &&
          listEquals(phones, other.phones) &&
          listEquals(emails, other.emails) &&
          externalUserId == other.externalUserId;

  @override
  int get hashCode => phones.hashCode ^ emails.hashCode ^ externalUserId.hashCode;
}

/// [UserIdentity] class to update Person profile with the data provided. Overrides any existing values with the
/// provided ones, `null` values will remove pre-existing data from server.
class UserAttributes {
  /// First name of the user, String.
  String? firstName;

  /// Middle name of the user, String.
  String? middleName;

  /// Last name of the user, String.
  String? lastName;

  /// [Gender] of the user.
  Gender? gender;

  /// Birthday, accepted format is `YYYY-MM-DD`.
  String? birthday;

  /// List of tags of the user, String.
  List<String>? tags;

  ///
  Map<String, dynamic>? customAttributes;

  /// Default constructor with all params.
  UserAttributes({
    this.firstName,
    this.middleName,
    this.lastName,
    this.gender,
    this.birthday,
    this.tags,
    this.customAttributes,
  });

  /// Mapping [UserAttributes] to json.
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'middleName': middleName,
        'lastName': lastName,
        'gender': gender?.name,
        'birthday': birthday,
        'tags': tags,
        'customAttributes': customAttributes,
      }..removeWhere((dynamic key, dynamic value) => value == null);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAttributes &&
          runtimeType == other.runtimeType &&
          firstName == other.firstName &&
          middleName == other.middleName &&
          lastName == other.lastName &&
          gender == other.gender &&
          birthday == other.birthday &&
          listEquals(tags, other.tags) &&
          const DeepCollectionEquality().equals(customAttributes, other.customAttributes);

  @override
  int get hashCode =>
      firstName.hashCode ^
      middleName.hashCode ^
      lastName.hashCode ^
      gender.hashCode ^
      birthday.hashCode ^
      tags.hashCode ^
      customAttributes.hashCode;
}

/// [PersonalizeContext] class for personalization with parameters.
class PersonalizeContext {
  /// [UserIdentity] class.
  final UserIdentity? userIdentity;

  /// [UserAttributes] class.
  final UserAttributes? userAttributes;

  /// Flag to depersonalize the current installation from previous person profile. Recommended to set as true unless
  /// special profiling logic introduced. If set to false and installation is already personalized - will produce an error.
  final bool? forceDepersonalize;

  /// Flag to perform personalization without promoting profile to [Type.CUSTOMER] and keep [Type.LEAD].
  final bool? keepAsLead;

  /// Default constructor with all params.
  PersonalizeContext({
    this.userIdentity,
    this.userAttributes,
    this.forceDepersonalize,
    this.keepAsLead,
  });

  /// Mapping [PersonalizeContext] to json.
  Map<String, dynamic> toJson() => {
        'userIdentity': userIdentity!.toJson(),
        'userAttributes': userAttributes!.toJson(),
        'forceDepersonalize': forceDepersonalize,
        'keepAsLead': keepAsLead,
      };
}
