
import 'dart:async';
import 'dart:collection';
import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'models/Configuration.dart';
import 'models/LibraryEvent.dart';

class InfobipMobilemessaging {
  static const MethodChannel _channel =
    const MethodChannel('infobip_mobilemessaging');
  static const EventChannel _libraryEvent =
    const EventChannel('infobip_mobilemessaging/broadcast');
  static StreamSubscription _libraryEventSubscription = _libraryEvent.receiveBroadcastStream()
      .listen((dynamic event) {
        print('Received event: $event');
        LibraryEvent libraryEvent = LibraryEvent.fromJson(jsonDecode(event));
        print("callbacks:");
        print(callbacks.toString());
        print("libraryEvent.eventName:");
        print(libraryEvent.eventName);
        if (callbacks.containsKey(libraryEvent.eventName)) {
          print("libraryEvent.eventName: " + libraryEvent.eventName);
          callbacks[libraryEvent.eventName]?.forEach((callback) {
            print("Try to call callback");
            callback(libraryEvent.payload);
          });
        }
      },
      onError: (dynamic error) {
        print('Received error: ${error.message}');
      },
      cancelOnError: true);

  static Map<String, List<Function>?> callbacks = new HashMap();

  static Future<void> on(String eventName, Function callack) async {
    if (callbacks.containsKey(eventName)) {
      var existed = callbacks[eventName];
      existed?.add(callack);
      callbacks.update(eventName, (val) => existed);
    } else {
      callbacks.putIfAbsent(eventName, () => List.filled(1, callack));
    }
    _libraryEventSubscription.resume();
  }

  static Future<void> init(Configuration configuration) async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    configuration.pluginVersion = packageInfo.version;
    await _channel.invokeMethod('init', jsonEncode(configuration.toJson()));
  }
}
