// ignore_for_file: constant_identifier_names
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

import 'installation.dart';

enum Gender { Male, Female }

enum Type { LEAD, CUSTOMER }

class UserData {
  String? externalUserId;
  String? firstName;
  String? lastName;
  String? middleName;
  Gender? gender;
  String? birthday;
  Type? type;
  List<String>? phones;
  List<String>? emails;
  List<String>? tags;
  Map<String, dynamic>? customAttributes;
  List<Installation>? installations;

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

  static Gender? resolveGender(String? str) {
    if (str == null) {
      return null;
    }
    try {
      return Gender.values
          .firstWhere((e) => e.toString().split('.').last == str);
    } on Exception {
      return null;
    }
  }

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

  static List<String>? resolveLists(List<dynamic>? str) {
    if (str != null) {
      return str.cast<String>();
    }
    return null;
  }

  static List<Installation>? resolveInstallations(List<dynamic>? str) {
    if (str != null) {
      var parsed = str.cast<Map<String, dynamic>>();
      return parsed
          .map<Installation>((json) => Installation.fromJson(json))
          .toList();
    }
    return null;
  }

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

  Map<String, dynamic> toJson() {
    final List<Map>? installations;
    if (this.installations != null) {
      installations = this.installations?.map((i) => i.toJson()).toList();
    } else {
      installations = null;
    }

    return {
      'externalUserId': externalUserId,
      'firstName': firstName,
      'lastName': lastName,
      'middleName': middleName,
      'gender': gender != null ? gender!.name : null,
      'birthday': birthday,
      'type': type,
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
          const DeepCollectionEquality()
              .equals(customAttributes, other.customAttributes) &&
          const DeepCollectionEquality()
              .equals(installations, other.installations);

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
