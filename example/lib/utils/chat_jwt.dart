//
//  chat_jwt.dart
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import 'dart:convert';
import 'dart:developer';

import 'package:crypto/crypto.dart';
import 'package:uuid/uuid.dart';

import '../screens/chat/screen_chat_authentication.dart';

String base64UrlEncodeNoPadding(List<int> bytes) => base64Url.encode(bytes).replaceAll('=', '');

Future<String> generateChatJWT({
  required SubjectType subjectType,
  required String subject,
  required String widgetId,
  required String secretKeyJson,
}) async {
  try {
    final uuid = const Uuid().v4();
    final nowSeconds = DateTime.now().millisecondsSinceEpoch ~/ 1000;

    final keyData = jsonDecode(secretKeyJson);
    final keyId = keyData['id'] as String;
    final keySecret = keyData['key'] as String;

    final header = {
      'alg': 'HS256',
      'typ': 'JWT',
    };

    final payload = {
      'jti': uuid,
      'sub': subject,
      'iss': widgetId,
      'iat': nowSeconds,
      'exp': nowSeconds + 60,
      'ski': keyId,
      'stp': subjectType.stp,
      'sid': uuid,
    };

    final encodedHeader = base64UrlEncodeNoPadding(utf8.encode(jsonEncode(header)));
    final encodedPayload = base64UrlEncodeNoPadding(utf8.encode(jsonEncode(payload)));

    final signingInput = '$encodedHeader.$encodedPayload';

    final keyBytes = base64.decode(keySecret);
    final hmac = Hmac(sha256, keyBytes);
    final signature = hmac.convert(utf8.encode(signingInput));

    final encodedSignature = base64UrlEncodeNoPadding(signature.bytes);

    return '$signingInput.$encodedSignature';
  } catch (e) {
    log('Flutter app: Chat JWT generation failed: $e');
    rethrow;
  }
}
