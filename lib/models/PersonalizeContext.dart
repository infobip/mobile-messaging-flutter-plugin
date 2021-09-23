class UserIdentity {
  final List<String>? phones;
  final List<String>? emails;
  final String? externalUserId;

  UserIdentity({this.phones, this.emails, this.externalUserId});

  Map<String, dynamic> toJson() =>
      {
        'phones': phones,
        'emails': emails,
        'externalUserId': externalUserId
      };

}

class PersonalizeContext {
  final UserIdentity? userIdentity;
  final Map<String, dynamic>? userAttributes;
  final bool? forceDepersonalize;

  PersonalizeContext({
      this.userIdentity, this.userAttributes, this.forceDepersonalize
  });

  Map<String, dynamic> toJson() =>
      {
        'userIdentity': userIdentity!.toJson(),
        'userAttributes': userAttributes,
        'forceDepersonalize': forceDepersonalize
      };
}