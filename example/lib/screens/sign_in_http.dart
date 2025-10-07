//
//  sign_in_http.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/data/personalize_context.dart';

class FormData {
  String? email;
  String? phone;
  String? externalUserId;

  FormData({this.email, this.phone, this.externalUserId});

  factory FormData.fromJson(Map<String, dynamic> json) => _$FormDataFromJson(json);

  Map<String, dynamic> toJson() => _$FormDataToJson(this);
}

class SignInHttpDemo extends StatefulWidget {
  const SignInHttpDemo({super.key});

  @override
  State createState() => _SignInHttpDemoState();
}

class _SignInHttpDemoState extends State<SignInHttpDemo> {
  FormData formData = FormData();
  bool emailUsed = false;
  bool phoneUsed = false;
  bool externalUserIdUsed = false;

  @override
  Widget build(context) => Scaffold(
        appBar: AppBar(
          title: const Text('Personalize'),
        ),
        body: Form(
          child: Scrollbar(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ...[
                    TextFormField(
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        filled: true,
                        hintText: 'Your phone number',
                        labelText: 'Phone Number',
                      ),
                      obscureText: false,
                      onChanged: (value) {
                        formData.phone = value;
                      },
                    ),
                    TextButton(
                      child: const Text('Personalize'),
                      onPressed: () async {
                        UserIdentity userIdentity = UserIdentity(phones: [formData.phone!]);

                        try {
                          await InfobipMobilemessaging.personalize(
                            PersonalizeContext(
                              userIdentity: userIdentity,
                              userAttributes: null,
                              forceDepersonalize: true,
                              keepAsLead: true,
                            ),
                          );
                          _showDialog('Personalized successfully', '');
                        } catch (e) {
                          if (e is PlatformException) {
                            log('MobileMessaging: code ${e.code}');
                            log('MobileMessaging: message ${e.message}');
                            log('MobileMessaging: details ${e.details}');
                          } else {
                            _showDialog('Unable to personalize', '$e');
                          }
                        }
                      },
                    ),
                  ].expand(
                    (widget) => [
                      widget,
                      const SizedBox(
                        height: 24,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      );

  void _showDialog(String title, String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: message.isNotEmpty ? Text(message) : null,
        actions: [
          TextButton(
            child: const Text('OK'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }
}

FormData _$FormDataFromJson(Map<String, dynamic> json) => FormData(
      email: json['email'] as String,
      phone: json['phone'] as String,
      externalUserId: json['externalUserId'] as String,
    );

Map<String, dynamic> _$FormDataToJson(FormData instance) => <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'externalUserId': instance.externalUserId,
    };
