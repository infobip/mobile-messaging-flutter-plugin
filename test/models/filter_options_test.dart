//   filter_options_test.dart
//   MobileMessagingFlutter
//
//   Copyright (c) 2016-2025 Infobip Limited
//   Licensed under the Apache License, Version 2.0
//

import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/models/inbox/filter_options.dart';

void main() {
  group('FilterOptions', () {
    group('toJson', () {
      test('serializes complete FilterOptions', () {
        final now = DateTime.now();
        final from = now.subtract(const Duration(days: 7));
        final to = now;

        final filter = FilterOptions(
          fromDateTime: from,
          toDateTime: to,
          topic: 'promotions',
          limit: 50,
        );

        final json = filter.toJson();

        expect(json['fromDateTime'], FilterOptions().timeFormatter(from));
        expect(json['toDateTime'], FilterOptions().timeFormatter(to));
        expect(json['topic'], 'promotions');
        expect(json['limit'], 50);
      });

      test('serializes with minimal fields', () {
        final filter = FilterOptions(limit: 20);

        final json = filter.toJson();

        expect(json.containsKey('fromDateTime'), false);
        expect(json.containsKey('toDateTime'), false);
        expect(json.containsKey('topic'), false);
        expect(json['limit'], 20);
      });

      test('excludes null date fields', () {
        final filter = FilterOptions(
          fromDateTime: null,
          toDateTime: null,
          topic: 'alerts',
          limit: 20,
        );

        final json = filter.toJson();

        expect(json.containsKey('fromDateTime'), false);
        expect(json.containsKey('toDateTime'), false);
        expect(json['topic'], 'alerts');
      });

      test('excludes null topic field', () {
        final filter = FilterOptions(
          topic: null,
          limit: 20,
        );

        final json = filter.toJson();

        expect(json.containsKey('topic'), false);
      });
    });

    group('complex filtering scenarios', () {
      test('filter by date range and topic', () {
        final filter = FilterOptions(
          fromDateTime: DateTime(2024, 1, 1),
          toDateTime: DateTime(2024, 1, 31),
          topic: 'promotions',
          limit: 50,
        );

        final json = filter.toJson();

        expect(json.containsKey('fromDateTime'), true);
        expect(json.containsKey('toDateTime'), true);
        expect(json['topic'], 'promotions');
        expect(json['limit'], 50);
      });

      test('filter by date range only', () {
        final filter = FilterOptions(
          fromDateTime: DateTime(2024, 1, 1),
          toDateTime: DateTime(2024, 1, 31),
          limit: 100,
        );

        final json = filter.toJson();

        expect(json.containsKey('fromDateTime'), true);
        expect(json.containsKey('toDateTime'), true);
        expect(json.containsKey('topic'), false);
        expect(json['limit'], 100);
      });

      test('filter by topic only', () {
        final filter = FilterOptions(
          topic: 'alerts',
          limit: 20,
        );

        final json = filter.toJson();

        expect(json.containsKey('fromDateTime'), false);
        expect(json.containsKey('toDateTime'), false);
        expect(json['topic'], 'alerts');
        expect(json['limit'], 20);
      });
    });
  });
}
