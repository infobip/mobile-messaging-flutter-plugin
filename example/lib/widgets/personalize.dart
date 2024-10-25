import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/personalize_context.dart';

class Personalize extends StatefulWidget {
  const Personalize({super.key, required this.onPersonalize});

  final void Function(String externalUserId) onPersonalize;

  @override
  State<StatefulWidget> createState() => _PersonalizeState();
}

class _PersonalizeState extends State<Personalize> {
  final _externalUserIdController = TextEditingController();
  var _isLoading = true;
  var _isPersonalized = false;

  @override
  void initState() {
    super.initState();
    _getMobileMessagingUser();
  }

  @override
  void dispose() {
    super.dispose();
    _externalUserIdController.dispose();
  }

  Future<void> _getMobileMessagingUser() async {
    var user = await InfobipMobilemessaging.getUser();
    if (user.externalUserId != null) {
      setState(() {
        _externalUserIdController.text = user.externalUserId!;
        _isPersonalized = true;
      });
    }
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onPersonalizeBtn() async {
    if (_externalUserIdController.text.trim().isEmpty) {
      const snackBar =
          SnackBar(content: Text('externalUserId cannot be empty'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    UserIdentity userIdentity =
        UserIdentity(externalUserId: _externalUserIdController.text.trim());
    try {
      await InfobipMobilemessaging.personalize(
        PersonalizeContext(
          userIdentity: userIdentity,
          userAttributes: null,
          forceDepersonalize: true,
          keepAsLead: false
        ),
      );
    } catch (e) {
      const snackBar = SnackBar(content: Text('Personalization failed'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }
    setState(() {
      _isPersonalized = true;
    });
  }

  void _onClosed() {
    widget.onPersonalize(_externalUserIdController.text.trim());
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: Padding(
          padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
          child: _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : Column(
                  children: [
                    TextField(
                      enabled: !_isPersonalized,
                      controller: _externalUserIdController,
                      decoration:
                          const InputDecoration(label: Text('ExternalUserId')),
                    ),
                    _isPersonalized
                        ? ElevatedButton(
                            onPressed: () {
                              InfobipMobilemessaging.depersonalize();
                              setState(() {
                                _externalUserIdController.text = '';
                                _isPersonalized = false;
                              });
                            },
                            child: const Text('Depersonalize'),
                          )
                        : ElevatedButton(
                            onPressed: _onPersonalizeBtn,
                            child: const Text('Personalize'),
                          ),
                    ElevatedButton(
                      onPressed: _onClosed,
                      child: const Text('Close'),
                    ),
                  ],
                ),
        ),
      );
}
