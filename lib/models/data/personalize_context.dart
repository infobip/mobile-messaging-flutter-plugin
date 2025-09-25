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
}

/// [PersonalizeContext] class for personalization with parameters.
class PersonalizeContext {
  /// [UserIdentity] class.
  final UserIdentity? userIdentity;

  /// Map of userAttributes.
  final Map<String, dynamic>? userAttributes;

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
        'userAttributes': userAttributes,
        'forceDepersonalize': forceDepersonalize,
        'keepAsLead': keepAsLead,
      };
}
