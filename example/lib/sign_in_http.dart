import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/PersonalizeContext.dart';

class FormData {
  String email;
  String phone;
  String externalUserId;

  FormData({this.email, this.phone, this.externalUserId});

  factory FormData.fromJson(Map<String, dynamic> json) =>
      _$FormDataFromJson(json);

  Map<String, dynamic> toJson() => _$FormDataToJson(this);
}

class SignInHttpDemo extends StatefulWidget {
  const SignInHttpDemo({
    Key key,
  }) : super(key: key);

  @override
  _SignInHttpDemoState createState() => _SignInHttpDemoState();
}

class _SignInHttpDemoState extends State<SignInHttpDemo> {
  FormData formData = FormData();
  bool emailUsed = false;
  bool phoneUsed = false;
  bool externalUserIdUsed = false;

  @override
  Widget build(BuildContext context) => Scaffold(
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
                      UserIdentity userIdentity =
                          UserIdentity(phones: [formData.phone]);

                      InfobipMobilemessaging.personalize(PersonalizeContext(
                          userIdentity: userIdentity,
                          userAttributes: null,
                          forceDepersonalize: true));

                      showDialog<void>(
                        context: context,
                        builder: (context) => AlertDialog(
                          content: const Text('Personalized successfully'),
                          actions: [
                            TextButton(
                              child: const Text('Done'),
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ].expand(
                  (widget) => [
                    widget,
                    const SizedBox(
                      height: 24,
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );

  void _showDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(message),
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
      externalUserId: json['externalUserId'] as String);

Map<String, dynamic> _$FormDataToJson(FormData instance) => <String, dynamic>{
      'email': instance.email,
      'phone': instance.phone,
      'externalUserId': instance.externalUserId
    };
