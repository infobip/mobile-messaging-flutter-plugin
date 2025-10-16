//
//  screen_chat_authentication.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/data/personalize_context.dart';

import '../../utils/chat_jwt.dart';

/// Live Chat widget ID.
/// Widget ID is used for generating JWT to be able use Chat as authenticated customer.
/// You can get your widget ID in widget configuration page.
// ignore: constant_identifier_names
const LIVECHAT_WIDGET_ID = 'YOUR_LIVECHAT_WIDGET_ID';

/// Widget secret key in JSON form.
/// Secret key is used for generating JWT to be able use Chat as authenticated customer.
/// You can generate new secret key following a guide https://www.infobip.com/docs/live-chat/user-types#enable-authenticated-customers.
// ignore: constant_identifier_names
const LIVECHAT_SECRET_KEY_JSON = 'YOUR_LIVECHAT_SECRET_KEY_JSON';

enum SubjectType {
  email('E-mail', 'email'),
  phoneNumber('Phone number', 'msisdn'),
  externalPersonId('External person ID', 'externalPersonId');

  final String label;
  final String stp;

  const SubjectType(this.label, this.stp);
}

class PersonalizationFormData {
  final String firstName;
  final String lastName;
  final SubjectType subjectType;
  final String subject;
  final bool keepAsLead;
  final bool forceDepersonalization;

  const PersonalizationFormData({
    required this.firstName,
    required this.lastName,
    required this.subjectType,
    required this.subject,
    required this.keepAsLead,
    required this.forceDepersonalization,
  });

  /// Validation: returns `null` if valid, or an error message otherwise
  String? validate() {
    if (firstName.trim().isEmpty && lastName.trim().isEmpty) {
      return 'At least one of first name or last name is required';
    }
    if (subject.trim().isEmpty) {
      return 'Subject is required';
    }
    return null;
  }

  PersonalizeContext? toPersonalizeContext() {
    if (subject.trim().isEmpty) {
      log('PersonalizationFormData.toPersonalizeContext: subject is empty, returning null');
      return null;
    }

    UserIdentity? userIdentity;
    switch (subjectType) {
      case SubjectType.email:
        userIdentity = UserIdentity(
          emails: [subject],
          phones: null,
          externalUserId: null,
        );
        break;
      case SubjectType.phoneNumber:
        userIdentity = UserIdentity(
          emails: null,
          phones: [subject],
          externalUserId: null,
        );
        break;
      case SubjectType.externalPersonId:
        userIdentity = UserIdentity(
          emails: null,
          phones: null,
          externalUserId: subject,
        );
        break;
    }

    UserAttributes userAttributes = UserAttributes();
    if (firstName.trim().isNotEmpty) {
      userAttributes.firstName = firstName.trim();
    }
    if (lastName.trim().isNotEmpty) {
      userAttributes.lastName = lastName.trim();
    }

    if (userAttributes.firstName == null && userAttributes.lastName == null) {
      log('PersonalizationFormData.toPersonalizeContext: no user attributes provided, returning null');
      return null;
    }

    PersonalizeContext context = PersonalizeContext(
      userIdentity: userIdentity,
      userAttributes: userAttributes,
      forceDepersonalize: forceDepersonalization,
      keepAsLead: keepAsLead,
    );
    log('PersonalizationFormData.toPersonalizeContext: created PersonalizeContext from $this');
    return context;
  }

  // Convert to JSON (useful if sending to API)
  Map<String, dynamic> toJson() => {
        'firstName': firstName,
        'lastName': lastName,
        'subjectType': subjectType.name, // "email", "phoneNumber", etc.
        'subject': subject,
        'keepAsLead': keepAsLead,
        'forceDepersonalization': forceDepersonalization,
      };

  // Create from JSON (e.g. if loading saved data)
  factory PersonalizationFormData.fromJson(Map<String, dynamic> json) => PersonalizationFormData(
        firstName: json['firstName'] ?? '',
        lastName: json['lastName'] ?? '',
        subjectType: SubjectType.values.firstWhere(
          (e) => e.name == json['subjectType'],
          orElse: () => SubjectType.email,
        ),
        subject: json['subject'] ?? '',
        keepAsLead: json['keepAsLead'] ?? false,
        forceDepersonalization: json['forceDepersonalization'] ?? false,
      );
}

class ChatAuthenticationScreen extends StatefulWidget {
  const ChatAuthenticationScreen({super.key});

  static const title = 'Chat authentication';
  static const route = '/screen_chat_authentication';

  @override
  State createState() => _ChatAuthenticationScreenState();
}

class _ChatAuthenticationScreenState extends State<ChatAuthenticationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();

  SubjectType _selectedSubjectType = SubjectType.externalPersonId;
  bool _keepAsLead = false;
  bool _forceDepersonalization = true;

  PersonalizationFormData createFormData() => PersonalizationFormData(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
        subjectType: _selectedSubjectType,
        subject: _subjectController.text,
        keepAsLead: _keepAsLead,
        forceDepersonalization: _forceDepersonalization,
      );

  Future<void> personalize({
    required PersonalizationFormData formData,
    VoidCallback? onSuccess,
    Function(String message)? onError,
  }) async {
    handleError(String message) {
      if (onError != null) {
        onError(message);
      } else {
        log('Flutter app: $message');
      }
    }

    final error = formData.validate();
    if (error != null) {
      handleError(error);
      return;
    }

    PersonalizeContext? personalizationContext = formData.toPersonalizeContext();
    if (personalizationContext == null) {
      handleError('PersonalizationContext is null, cannot proceed with personalization');
      return;
    }

    try {
      await InfobipMobilemessaging.personalize(personalizationContext);
      if (onSuccess != null) onSuccess();
    } catch (e) {
      handleError('Failed to personalize: $e');
    }
  }

  Future<void> authenticate({
    required PersonalizationFormData formData,
    VoidCallback? onSuccess,
    Function(String message)? onError,
  }) async {
    handleError(String message) {
      if (onError != null) {
        onError(message);
      } else {
        log('Flutter app: $message');
      }
    }

    await personalize(
      formData: formData,
      onSuccess: () async {
        await InfobipMobilemessaging.setChatJwtProvider(() async {
          String jwt = await generateChatJWT(
            subjectType: formData.subjectType,
            subject: formData.subject,
            widgetId: LIVECHAT_WIDGET_ID,
            secretKeyJson: LIVECHAT_SECRET_KEY_JSON,
          );
          log('Flutter app: Providing new JWT: $jwt');
          return jwt;
        }, (error) {
          handleError('$error');
        });
        if (onSuccess != null) onSuccess();
      },
      onError: onError,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(title: const Text(ChatAuthenticationScreen.title)),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // First Name
                TextField(
                  controller: _firstNameController,
                  decoration: const InputDecoration(
                    labelText: 'First name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Last Name
                TextField(
                  controller: _lastNameController,
                  decoration: const InputDecoration(
                    labelText: 'Last name',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Subject Type Dropdown
                DropdownButtonFormField<SubjectType>(
                  value: _selectedSubjectType,
                  items: SubjectType.values
                      .map(
                        (type) => DropdownMenuItem(
                          value: type,
                          child: Text(type.label),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSubjectType = value!;
                    });
                  },
                  decoration: const InputDecoration(
                    labelText: 'Subject type',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Subject
                TextField(
                  controller: _subjectController,
                  decoration: const InputDecoration(
                    labelText: 'Subject',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // KeepAsLead Switch
                SwitchListTile(
                  title: const Text('Keep as Lead'),
                  value: _keepAsLead,
                  onChanged: (value) {
                    setState(() {
                      _keepAsLead = value;
                    });
                  },
                ),

                // ForceDepersonalization Switch
                SwitchListTile(
                  title: const Text('Force Depersonalization'),
                  value: _forceDepersonalization,
                  onChanged: (value) {
                    setState(() {
                      _forceDepersonalization = value;
                    });
                  },
                ),

                const SizedBox(height: 24),

                // Personalize Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      personalize(
                        formData: createFormData(),
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Personalization successful'),
                            ),
                          );
                        },
                        onError: (String message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Personalization error: $message'),
                            ),
                          );
                        },
                      );
                    },
                    child: const Text('Personalize'),
                  ),
                ),

                // Authenticate Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      authenticate(
                        formData: createFormData(),
                        onSuccess: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Authentication successful'),
                            ),
                          );
                        },
                        onError: (String message) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Authentication error: $message')),
                          );
                        },
                      );
                    },
                    child: const Text('Authenticate'),
                  ),
                ),

                // Show chat Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      InfobipMobilemessaging.showChat();
                    },
                    child: const Text('Show chat'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
}
