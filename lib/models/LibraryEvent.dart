
import 'package:infobip_mobilemessaging/models/Message.dart';

class LibraryEvent {
  final String eventName;

  final dynamic? payload;

  // Occurs when an APNs device token is received. Contains device token - a hex-encoded string received from APNS. Returns device token as hex-encoded string.
  static const String TOKEN_RECEIVED = "tokenReceived";

  // Occurs when the registration is updated on backend server. Returns internalId - string for the registered user.
  static const String REGISTRATION_UPDATED = "registrationUpdated";

  // Occurs when save request to the server is successfully sent.
  static const String INSTALLATION_UPDATED = "installationUpdated";

  // Occurs when save request to the server is successfully sent.
  static const String USER_UPDATED = "userUpdated";

  // Occurs when request for personalization is successfully sent to the server.
  static const String PERSONALIZED = "personalized";

  // Occurs when request for depersonalization is successfully sent to the server.
  static const String DEPERSONALIZED = "depersonalized";

  // Occurs when notification is tapped.
  static const String NOTIFICATION_TAPPED = "notificationTapped";

  // Occurs when user taps on action inside notification or enters text as part of the notification response.
  static const String NOTIFICATION_ACTION_TAPPED = "actionTapped";

  // Occurs when new message arrives, see separate section for all available message fields
  static const String MESSAGE_RECEIVED = "messageReceived";

  LibraryEvent({
    required this.eventName,
    this.payload
  });

  factory LibraryEvent.fromJson(Map<String, dynamic> json) {
    return LibraryEvent(
      eventName: json['eventName'] as String,
      payload:  (json['payload'] != null)?json['payload'] as dynamic : null,
    );
  }

}