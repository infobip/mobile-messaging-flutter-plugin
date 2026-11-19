//
//  cloud_inbox.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
import 'package:infobip_mobilemessaging/models/inbox/filter_options.dart';
import 'package:infobip_mobilemessaging/models/inbox/inbox.dart';
import 'package:infobip_mobilemessaging/models/inbox/inbox_message.dart';

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
  var _isLoadingMore = false;
  String? _nextCursor;
  // Changes whenever the list is replaced, so a response for an older list isn't applied.
  var _listGeneration = 0;
  // Fetches made shortly after a delete may still return deleted messages, so they are filtered out.
  final _deletedMessageIds = <String>{};

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
          _nextCursor = null;
          _listGeneration++;
          _isInboxLoaded = false;
        }),
      },
    );
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
    if (externalUserId.isEmpty ||
        (_externalUserId == externalUserId &&
            filterOptions == _filterOptions)) {
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
        _nextCursor = null;
        _listGeneration++;
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

    // A new first page: a cursor of the previous list mustn't be used with new filters.
    setState(() {
      _nextCursor = null;
      _listGeneration++;
    });
    final generation = _listGeneration;
    try {
      Inbox inbox = await InfobipMobilemessaging.fetchInboxMessagesWithoutToken(
        _externalUserId,
        _filterOptions,
      );
      // The screen is gone, or a newer refresh replaced the list meanwhile.
      if (!mounted || generation != _listGeneration) return;
      if (inbox.messages != null) {
        final messages = inbox.messages!
            .where((m) => !_deletedMessageIds.contains(m.messageId))
            .toList();
        setState(() {
          // Counters as returned by the server, they replace local adjustments made on delete
          _inbox = Inbox(
            messages: messages,
            countTotal: inbox.countTotal,
            countUnread: inbox.countUnread,
            countTotalFiltered: inbox.countTotalFiltered,
            countUnreadFiltered: inbox.countUnreadFiltered,
            nextCursor: inbox.nextCursor,
          );
          _nextCursor = inbox.nextCursor;
          values = messages.map((message) => message.seen).toList();
          _isInboxLoaded = true;
        });
        return;
      }
      const snackBar = SnackBar(content: Text('Inbox is empty'));
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
      return;
    } catch (e) {
      if (!mounted || generation != _listGeneration) return;
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

  Future<void> _loadMore() async {
    final cursor = _nextCursor;
    if (cursor == null || _isLoadingMore) {
      return;
    }
    final generation = _listGeneration;
    setState(() {
      _isLoadingMore = true;
    });
    try {
      // Same filters as for the first page, only the cursor changes.
      Inbox page = await InfobipMobilemessaging.fetchInboxMessagesWithoutToken(
        _externalUserId,
        FilterOptions(
          fromDateTime: _filterOptions.fromDateTime,
          toDateTime: _filterOptions.toDateTime,
          topic: _filterOptions.topic,
          topics: _filterOptions.topics,
          limit: _filterOptions.limit,
          cursor: cursor,
        ),
      );
      // The screen is gone, or the list was reloaded meanwhile and this page doesn't belong to it.
      if (!mounted || generation != _listGeneration) return;
      // The cursor isn't a snapshot, so pages may overlap. Also skips messages deleted meanwhile.
      final loadedIds = {...?_inbox.messages?.map((m) => m.messageId)};
      final pageMessages = (page.messages ?? [])
          .where(
            (m) =>
                !_deletedMessageIds.contains(m.messageId) &&
                loadedIds.add(m.messageId),
          )
          .toList();
      setState(() {
        _inbox = Inbox(
          messages: [...?_inbox.messages, ...pageMessages],
          countTotal: page.countTotal,
          countUnread: page.countUnread,
          countTotalFiltered: page.countTotalFiltered,
          countUnreadFiltered: page.countUnreadFiltered,
        );
        _nextCursor = page.nextCursor;
        values = [...values, ...pageMessages.map((message) => message.seen)];
      });
    } on PlatformException catch (e) {
      if (!mounted || generation != _listGeneration) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading more: ${e.code} ${e.message}')),
      );
      if (e.code == 'INVALID_CURSOR') {
        // The cursor can't be used anymore, the list has to be loaded again from the first page.
        await _handleRefresh();
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  Future<void> _deleteMessage(InboxMessage message) async {
    try {
      await InfobipMobilemessaging.deleteInboxMessagesWithoutToken(
        _externalUserId,
        [message.messageId],
      );
      _deletedMessageIds.add(message.messageId);
      if (!mounted) return;
      // By ID, as the list may have been reloaded meanwhile
      final current = _inbox.messages ?? [];
      final deletedIndex =
          current.indexWhere((m) => m.messageId == message.messageId);
      if (deletedIndex == -1) return;
      // Optimistic update for immediate feedback, the next refresh brings the server counters.
      // Unread ones go down by the seen state the message was fetched with.
      final wasUnread = !message.seen;
      int? decrement(int? count, {bool when = true}) =>
          count == null || !when ? count : max(count - 1, 0);
      setState(() {
        final messages = [...current]..removeAt(deletedIndex);
        values = [...values]..removeAt(deletedIndex);
        _inbox = Inbox(
          messages: messages,
          countTotal: decrement(_inbox.countTotal),
          countUnread: decrement(_inbox.countUnread, when: wasUnread),
          countTotalFiltered: decrement(_inbox.countTotalFiltered),
          countUnreadFiltered:
              decrement(_inbox.countUnreadFiltered, when: wasUnread),
        );
      });
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting message: ${e.code} ${e.message}'),
        ),
      );
    }
  }

  void _confirmDelete(int index) {
    // Captured now, the list may be replaced while the dialog is open
    final message = _inbox.messages![index];
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Deleting message'),
        content: Text(
          'Do you want to delete message with id ${message.messageId}?',
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
              Navigator.pop(ctx);
              _deleteMessage(message);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
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
                            ? Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Inbox total: ${_inbox.countTotal}, unread: ${_inbox.countUnread}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  if (_inbox.countTotalFiltered != null)
                                    Text(
                                      'filtered total: ${_inbox.countTotalFiltered}, filtered unread: ${_inbox.countUnreadFiltered}',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w400,
                                      ),
                                    ),
                                ],
                              )
                            : const Text('no messages yet'),
                      ],
                    ),
                    Expanded(
                      child: !_isInboxLoaded || _inbox.messages!.isEmpty
                          ? ListView.builder(
                              itemCount: 1,
                              itemBuilder: (BuildContext context, int index) =>
                                  const ListTile(
                                title:
                                    Text('Inbox messages will be shown here'),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _inbox.messages!.length +
                                  (_nextCursor != null ? 1 : 0),
                              itemBuilder: (BuildContext context, int index) =>
                                  index == _inbox.messages!.length
                                      ? ListTile(
                                          title: _isLoadingMore
                                              ? const Center(
                                                  child:
                                                      CircularProgressIndicator(),
                                                )
                                              : TextButton(
                                                  onPressed: _loadMore,
                                                  child:
                                                      const Text('Load more'),
                                                ),
                                        )
                                      : ListTile(
                                          onLongPress: () =>
                                              _confirmDelete(index),
                                          title: Text(
                                            _inbox.messages![index].body!,
                                            style: values[index]
                                                ? const TextStyle(
                                                    fontWeight:
                                                        FontWeight.normal,
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
                                                  title: const Text(
                                                      'Marking as seen'),
                                                  content: Text(
                                                    'Do you want to mark message with id ${_inbox.messages![index].messageId} as seen?',
                                                  ),
                                                  actions: [
                                                    TextButton(
                                                      onPressed: () {
                                                        Navigator.pop(ctx);
                                                      },
                                                      child:
                                                          const Text('Cancel'),
                                                    ),
                                                    TextButton(
                                                      onPressed: () {
                                                        try {
                                                          InfobipMobilemessaging
                                                              .setInboxMessagesSeen(
                                                                  _externalUserId,
                                                                  [
                                                                _inbox
                                                                    .messages![
                                                                        index]
                                                                    .messageId,
                                                              ]);
                                                          setState(() {
                                                            values[index] =
                                                                true;
                                                          });
                                                        } catch (e) {
                                                          const snackBar =
                                                              SnackBar(
                                                            content: Text(
                                                              'Error setting seen',
                                                            ),
                                                          );
                                                          ScaffoldMessenger.of(
                                                                  context)
                                                              .showSnackBar(
                                                                  snackBar);
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
