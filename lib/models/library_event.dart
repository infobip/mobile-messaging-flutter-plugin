class LibraryEvent {
  final String eventName;

  final dynamic payload;

  // Occurs when an APNs device token is received. Contains device token - a hex-encoded string received from APNS. Returns device token as hex-encoded string.
  static const String tokenReceived = "tokenReceived";

  // Occurs when the registration is updated on backend server. Returns internalId - string for the registered user.
  static const String registrationUpdated = "registrationUpdated";

  // Occurs when save request to the server is successfully sent.
  static const String installationUpdated = "installationUpdated";

  // Occurs when save request to the server is successfully sent.
  static const String userUpdated = "userUpdated";

  // Occurs when request for personalization is successfully sent to the server.
  static const String personalized = "personalized";

  // Occurs when request for depersonalization is successfully sent to the server.
  static const String depersonalized = "depersonalized";

  // Occurs when notification is tapped.
  static const String notificationTapped = "notificationTapped";

  // Occurs when user taps on action inside notification or enters text as part of the notification response.
  static const String actionTapped = "actionTapped";

  // Occurs when new message arrives, see separate section for all available message fields
  static const String messageReceived = "messageReceived";

  // Occurs when in-app chat counter is updated.
  static const String unreadMessageCounterUpdated = "inAppChat.unreadMessageCounterUpdated";

  LibraryEvent({
    required this.eventName,
    this.payload,
  });

  factory LibraryEvent.fromJson(Map<String, dynamic> json) => LibraryEvent(
        eventName: json['eventName'] as String,
        payload: (json['payload'] != null) ? json['payload'] as dynamic : null,
      );
}
