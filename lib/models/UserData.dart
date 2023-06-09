import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';

enum Gender { Male, Female }

class UserData {
  String? externalUserId;
  String? firstName;
  String? lastName;
  String? middleName;
  Gender? gender;
  String? birthday;
  List<String>? phones;
  List<String>? emails;
  List<String>? tags;
  Map<String, dynamic>? customAttributes;

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
  });

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

  static List<String>? resolveLists(List<dynamic>? str) {
    if (str != null) {
      return str.cast<String>();
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
        phones = UserData.resolveLists(json['phones']),
        emails = UserData.resolveLists(json['emails']),
        tags = UserData.resolveLists(json['tags']),
        customAttributes = json['customAttributes'];

  Map<String, dynamic> toJson() => {
        'externalUserId': externalUserId,
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'gender': gender != null ? describeEnum(gender!) : null,
        'birthday': birthday,
        'phones': phones,
        'emails': emails,
        'tags': tags,
        'customAttributes': customAttributes
      }..removeWhere((dynamic key, dynamic value) => value == null);

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
          const DeepCollectionEquality().equals(customAttributes, other.customAttributes);

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
      customAttributes.hashCode;
}
