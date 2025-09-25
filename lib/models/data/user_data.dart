// ignore_for_file: constant_identifier_names
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'installation.dart';

/// Gender of the User
// ignore: public_member_api_docs
enum Gender { Male, Female }

/// Enum for [Type] of the person. Lead is a not verified profile, Customer is a verified one (acquired by personalization).
// ignore: public_member_api_docs
enum Type { LEAD, CUSTOMER }

/// UserData class for profiling at Infobip platform.
class UserData {
  /// ExternalUserId of user.
  String? externalUserId;

  /// First name of the user, String.
  String? firstName;

  /// Last name of the user, String.
  String? lastName;

  /// Middle name of the user, String.
  String? middleName;

  /// [Gender] of the user.
  Gender? gender;

  /// Birthday, accepted format is YYYY-MM-DD.
  String? birthday;

  /// [Type] of the person. Lead is a not verified profile, Customer is a verified one (acquired by personalization).
  Type? type;

  /// List of phones of the user, Strings in [E.164 format](https://en.wikipedia.org/wiki/E.164), i.e. `38516419710`.
  List<String>? phones;

  /// List of emails of the user, String in [rfc2822 format](https://datatracker.ietf.org/doc/html/rfc2822), i.e. `user@infobip.com`.
  List<String>? emails;

  /// List of tags of the user, String.
  List<String>? tags;

  /// Custom attributes of the user, configurable at [Portal](https://portal.infobip.com/people/configuration/person-custom-attributes).
  Map<String, dynamic>? customAttributes;

  /// List of [Installation]s, assigned to the current user.
  List<Installation>? installations;

  /// Default constructor with all params.
  UserData({
    this.externalUserId,
    this.firstName,
    this.lastName,
    this.middleName,
    this.gender,
    this.birthday,
    this.phones,
    this.emails,
    this.tags,
    this.customAttributes,
    this.installations,
  });

  /// Resolving [Gender] from json.
  static Gender? resolveGender(String? str) {
    if (str == null) {
      return null;
    }
    try {
      return Gender.values.firstWhere((e) => e.toString().split('.').last == str);
    } on Exception {
      return null;
    }
  }

  /// Resolving [Type] from json.
  static Type? resolveType(String? str) {
    if (str == null) {
      return null;
    }
    try {
      return Type.values.firstWhere((e) => e.toString().split('.').last == str);
    } on Exception {
      return null;
    }
  }

  /// Resolving lists from json.
  static List<String>? resolveLists(List<dynamic>? str) {
    if (str != null) {
      return str.cast<String>();
    }
    return null;
  }

  /// Resolving [Installation]s from json.
  static List<Installation>? resolveInstallations(List<dynamic>? str) {
    if (str != null) {
      var parsed = str.cast<Map<String, dynamic>>();
      return parsed.map<Installation>((json) => Installation.fromJson(json)).toList();
    }
    return null;
  }

  /// Resolving [UserData] from json.
  UserData.fromJson(Map<String, dynamic> json)
      : externalUserId = json['externalUserId'],
        firstName = json['firstName'],
        lastName = json['lastName'],
        middleName = json['middleName'],
        gender = UserData.resolveGender(json['gender']),
        birthday = json['birthday'],
        type = resolveType(json['type']),
        phones = UserData.resolveLists(json['phones']),
        emails = UserData.resolveLists(json['emails']),
        tags = UserData.resolveLists(json['tags']),
        customAttributes = json['customAttributes'],
        installations = UserData.resolveInstallations(json['installations']);

  /// Mapping [UserData] to json.
  Map<String, dynamic> toJson() {
    List<Map>? installations = this.installations?.map((i) => i.toJson()).toList();

    return {
      'externalUserId': externalUserId,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'gender': gender?.name,
      'birthday': birthday,
      'type': type?.name,
      'phones': phones,
      'emails': emails,
      'tags': tags,
      'customAttributes': customAttributes,
      'installations': installations,
    }..removeWhere((dynamic key, dynamic value) => value == null);
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserData &&
          runtimeType == other.runtimeType &&
          externalUserId == other.externalUserId &&
          firstName == other.firstName &&
          lastName == other.lastName &&
          middleName == other.middleName &&
          gender == other.gender &&
          birthday == other.birthday &&
          listEquals(phones, other.phones) &&
          listEquals(emails, other.emails) &&
          listEquals(tags, other.tags) &&
          const DeepCollectionEquality().equals(customAttributes, other.customAttributes) &&
          const DeepCollectionEquality().equals(installations, other.installations);

  @override
  int get hashCode =>
      externalUserId.hashCode ^
      firstName.hashCode ^
      lastName.hashCode ^
      middleName.hashCode ^
      gender.hashCode ^
      birthday.hashCode ^
      phones.hashCode ^
      emails.hashCode ^
      tags.hashCode ^
      customAttributes.hashCode ^
      installations.hashCode;
}
