import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/inbox/filter_options.dart';
import 'package:infobip_mobilemessaging/models/inbox/inbox.dart';

import '../widgets/edit_filter_options.dart';
import '../widgets/personalize.dart';

class CloudInboxScreen extends StatefulWidget {
  const CloudInboxScreen({super.key});

  @override
  State<StatefulWidget> createState() => _CloudInboxScreenState();
}

class _CloudInboxScreenState extends State<CloudInboxScreen> {
  var _isLoading = true;
  var _isInboxLoaded = false;

  Inbox _inbox = Inbox();
  FilterOptions _filterOptions = FilterOptions();
  String _externalUserId = '';
  List<bool> values = List.generate(1, (index) => false);

  @override
  void initState() {
    super.initState();
    InfobipMobilemessaging.on(
        'depersonalized',
        () => {
              setState(() {
                _inbox = Inbox();
                _isInboxLoaded = false;
              }),
            });
    _getMobileMessagingUser();
  }

  Future<void> _getMobileMessagingUser() async {
    var user = await InfobipMobilemessaging.getUser();
    if (user.externalUserId != null) {
      setState(() {
        _externalUserId = user.externalUserId!;
      });
      await _handleRefresh();
    }
    setState(() {
      _isLoading = false;
    });
  }

  void _openEditFilterOptions() {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      builder: (ctx) => EditFilterOptions(
        externalUserId: _externalUserId,
        filterOptions: _filterOptions,
        onEditFilterOptions: _editFilterOptions,
      ),
    );
  }

  void _editFilterOptions(String externalUserId, FilterOptions filterOptions) {
    if (externalUserId.isEmpty || (_externalUserId == externalUserId && filterOptions == _filterOptions)) {
      return;
    }
    setState(() {
      _externalUserId = externalUserId;
      _filterOptions = filterOptions;
    });
    _handleRefresh();
  }

  void _openPersonalize() {
    showModalBottomSheet(
      isScrollControlled: true,
      isDismissible: false,
      context: context,
      builder: (ctx) => Personalize(
        onPersonalize: _editPersonalize,
      ),
    );
  }

  void _editPersonalize(String externalUserId) {
    if (_externalUserId == externalUserId) {
      return;
    }

    setState(() {
      _externalUserId = externalUserId;
    });

    if (externalUserId.isEmpty) {
      setState(() {
        _inbox = Inbox();
        _isInboxLoaded = false;
      });
    } else {
      _handleRefresh();
    }
  }

  Future<void> _handleRefresh() async {
    if (_externalUserId.isEmpty) {
      const snackBar = SnackBar(
        content: Text('ExternalUserId should be provided'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    }

    try {
      Inbox inbox = await InfobipMobilemessaging.fetchInboxMessagesWithoutToken(
        _externalUserId,
        _filterOptions,
      );
      if (inbox.messages != null) {
        setState(() {
          _inbox = inbox;
          if (inbox.messages!.isNotEmpty) {
            values = List.generate(
              inbox.messages!.length,
              (index) => inbox.messages![index].seen,
            );
          }
          _isInboxLoaded = true;
        });
        return;
      }
      const snackBar = SnackBar(content: Text('Inbox is empty'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } catch (e) {
      const snackBar = SnackBar(
        content: Text('Error fetching inbox, check logs'),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      setState(() {
        _isInboxLoaded = false;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: const Text('Inbox'),
          actions: [
            IconButton(
              onPressed: _openEditFilterOptions,
              icon: const Icon(
                Icons.filter_alt_sharp,
              ),
            ),
            IconButton(
              onPressed: _openPersonalize,
              icon: const Icon(
                Icons.person,
              ),
            ),
          ],
        ),
        body: _isLoading
            ? const Center(
                child: CircularProgressIndicator(),
              )
            : RefreshIndicator(
                onRefresh: _handleRefresh,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const SizedBox(width: 16),
                        _isInboxLoaded
                            ? Text(
                                'Inbox total: ${_inbox.countTotal}, unread: ${_inbox.countUnread}',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              )
                            : const Text('no messages yet'),
                      ],
                    ),
                    Expanded(
                      child: !_isInboxLoaded || _inbox.messages!.isEmpty
                          ? ListView.builder(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) => const ListTile(
                                title: Text('Inbox messages will be shown here'),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _inbox.messages?.length,
                              itemBuilder: (BuildContext context, int index) => ListTile(
                                title: Text(
                                  _inbox.messages![index].body!,
                                  style: values[index]
                                      ? const TextStyle(
                                          fontWeight: FontWeight.normal,
                                        )
                                      : const TextStyle(
                                          fontWeight: FontWeight.bold,
                                        ),
                                ),
                                subtitle: Text(
                                  'topic: ${_inbox.messages![index].topic}, ID: ${_inbox.messages![index].messageId}',
                                ),
                                onTap: () {
                                  if (!values[index]) {
                                    showDialog(
                                      context: context,
                                      builder: (ctx) => AlertDialog(
                                        title: const Text('Marking as seen'),
                                        content: Text(
                                          'Do you want to mark message with id ${_inbox.messages![index].messageId} as seen?',
                                        ),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              try {
                                                InfobipMobilemessaging.setInboxMessagesSeen(_externalUserId, [
                                                  _inbox.messages![index].messageId,
                                                ]);
                                                setState(() {
                                                  values[index] = true;
                                                });
                                              } catch (e) {
                                                const snackBar = SnackBar(
                                                  content: Text(
                                                    'Error setting seen',
                                                  ),
                                                );
                                                ScaffoldMessenger.of(context).showSnackBar(snackBar);
                                              }
                                              Navigator.pop(ctx);
                                            },
                                            child: const Text('Okay'),
                                          ),
                                        ],
                                      ),
                                    );
                                  }
                                },
                              ),
                            ),
                    ),
                  ],
                ),
              ),
      );
}
