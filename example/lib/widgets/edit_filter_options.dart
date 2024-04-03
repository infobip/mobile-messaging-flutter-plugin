import 'package:flutter/material.dart';
import 'package:infobip_mobilemessaging/models/inbox/filter_options.dart';
import 'package:intl/intl.dart';

class EditFilterOptions extends StatefulWidget {
  const EditFilterOptions(
      {Key key,
      this.externalUserId,
      this.filterOptions,
      this.onEditFilterOptions})
      : super(key: key);

  final String externalUserId;
  final FilterOptions filterOptions;

  final void Function(String externalUserId, FilterOptions filterOptions)
      onEditFilterOptions;

  @override
  State<StatefulWidget> createState() => _EditFilterOptionsState();
}

class _EditFilterOptionsState extends State<EditFilterOptions> {
  final _externalUserIdController = TextEditingController();
  final _limitController = TextEditingController();
  final _topicController = TextEditingController();
  DateTime _fromDateTime;
  DateTime _toDateTime;

  final formatter = DateFormat.yMd();

  @override
  void initState() {
    super.initState();
    _externalUserIdController.text = widget.externalUserId;
    if (widget.filterOptions != null) {
      _limitController.text = widget.filterOptions.limit?.toString();
      _topicController.text = widget.filterOptions.topic;
      _fromDateTime = widget.filterOptions.fromDateTime;
      _toDateTime = widget.filterOptions.toDateTime;
    }
  }

  void _fromDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _fromDateTime = pickedDate;
    });
  }

  void _toDatePicker() async {
    final now = DateTime.now();
    final firstDate = DateTime(now.year - 1, now.month, now.day);
    final pickedDate = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: firstDate,
      lastDate: now,
    );
    setState(() {
      _toDateTime = pickedDate;
    });
  }

  void _submitFilterOptions() {
    final enteredLimit = int.tryParse(_limitController.text);
    final enteredTopic = _topicController.text.trim();
    if (enteredLimit != null && enteredLimit < 0) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Invalid input'),
          content: const Text('Limit should be a natural number.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
              },
              child: const Text('Okay'),
            ),
          ],
        ),
      );
      return;
    }

    widget.onEditFilterOptions(
      _externalUserIdController.text.trim(),
      FilterOptions(
          limit: enteredLimit,
          topic: enteredTopic.isNotEmpty ? enteredTopic : null,
          fromDateTime: _fromDateTime,
          toDateTime: _toDateTime),
    );

    Navigator.pop(context);
  }

  @override
  void dispose() {
    _externalUserIdController.dispose();
    _limitController.dispose();
    _topicController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
        child: Column(
          children: [
            TextField(
              enabled: false,
              controller: _externalUserIdController,
              decoration: const InputDecoration(
                label: Text('ExternalUserId'),
                labelStyle: TextStyle(
                  decorationColor: Colors.grey,
                ),
              ),
            ),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _limitController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      label: Text('Limit'),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _topicController,
                    keyboardType: TextInputType.text,
                    decoration: const InputDecoration(
                      label: Text('Topic'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(
              height: 16,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                const Text('From'),
                Text(_fromDateTime == null
                    ? 'no datetime'
                    : formatter.format(_fromDateTime)),
                IconButton(
                  onPressed: _fromDatePicker,
                  icon: const Icon(
                    Icons.calendar_month,
                  ),
                ),
                const Text('To'),
                Text(_toDateTime == null
                    ? 'no datetime'
                    : formatter.format(_toDateTime)),
                IconButton(
                  onPressed: _toDatePicker,
                  icon: const Icon(
                    Icons.calendar_month,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('Cancel'),
                ),
                const Spacer(),
                TextButton(
                  onPressed: _submitFilterOptions,
                  child: const Text('Set Filter Options'),
                ),
              ],
            )
          ],
        ),
      );
}
