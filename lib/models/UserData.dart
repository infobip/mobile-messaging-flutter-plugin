enum Gender {
  Male, Female
}

class UserData {
  final String? externalUserId;
  final String? firstName;
  final String? lastName;
  final String? middleName;
  final Gender? gender;
  final String? birthday;
  final List<String>? phones;
  final List<String>? emails;
  final List<String>? tags;
  final Map<String, dynamic>? customAttributes;

  UserData({this.externalUserId, this.firstName, this.lastName, this.middleName,
      this.gender, this.birthday, this.phones, this.emails, this.tags,
      this.customAttributes});

  Map<String, dynamic> toJson() =>
      {
        'externalUserId': externalUserId,
        'firstName': firstName,
        'lastName': lastName,
        'middleName': middleName,
        'gender': gender,
        'birthday': birthday,
        'phones': phones,
        'emails': emails,
        'tags': tags,
        'customAttributes': customAttributes
      };

}