import 'package:flutter_test/flutter_test.dart';
import 'package:infobip_mobilemessaging/models/Configuration.dart';
import 'package:infobip_mobilemessaging/models/Message.dart';

void main() {
  Configuration getConfiguration() {
    return new Configuration(
      applicationCode: 'abc',
      pluginVersion: "1.2.3",
      inAppChatEnabled: true,
      androidSettings: AndroidSettings(
          firebaseOptions: FirebaseOptions(
              apiKey: "Some-API-Key",
              applicationId: "1:1234567890:android:abc123",
              projectId: "project-123ab"
          ),
          notificationIcon: 'icon.png',
          multipleNotifications: true,
          notificationAccentColor: "#ABCDEF"),
      iosSettings: IOSSettings(
          notificationTypes: ['sound'],
          forceCleanup: true,
          logging: true,
          webViewSettings: WebViewSettings(
              title: 'webViewTitle',
              barTintColor: '#012345',
              titleColor: '#135',
              tintColor: '#246')),
      privacySettings: PrivacySettings(
          applicationCodePersistingDisabled: true,
          userDataPersistingDisabled: true,
          carrierInfoSendingDisabled: true,
          systemInfoSendingDisabled: true),
      notificationCategories: [
        NotificationCategory(identifier: '123', actions: [
          NotificationAction(
              identifier: '123456',
              title: 'Action Title',
              foreground: true,
              authenticationRequired: true,
              moRequired: true,
              destructive: true,
              icon: 'icon-action.png',
              textInputActionButtonTitle: 'Button Title',
              textInputPlaceholder: 'Placeholder Title')
        ])
      ],
      defaultMessageStorage: true,
    );
  }

  Message getMessage() {
    return new Message(
        messageId: 'mess-123',
        title: 'Message Title',
        body: 'message body',
        sound: 'Sound1',
        vibrate: true,
        icon: 'icon.png',
        silent: true,
        category: 'Category1',
        customPayload: {'customParam1': 'customValue1'},
        internalData: 'internalData1',
        receivedTimestamp: 1234567890,
        seenDate: 1234567890,
        contentUrl: 'https://some.url',
        seen: true,
        geo: true,
        originalPayload: {'param1': 'value1'},
        browserUrl: 'https://some-browser.url',
        deeplink: 'https://some-deeplink.url',
        webViewUrl: 'https://some-browser.url',
        inAppOpenTitle: 'InApp Title',
        inAppDismissTitle: 'Dismiss title',
        chat: true
    );
  }

  Map<String, dynamic> getMessageMap() {
    return {
      'messageId': 'mess-123',
      'title': 'Message Title',
      'body': 'message body',
      'sound': 'Sound1',
      'vibrate': true,
      'icon': 'icon.png',
      'silent': true,
      'category': 'Category1',
      'customPayload': {'customParam1': 'customValue1'},
      'internalData': 'internalData1',
      'receivedTimestamp': 1234567890,
      'seenDate': 1234567890,
      'contentUrl': 'https://some.url',
      'seen': true,
      'geo': true,
      'originalPayload': {'param1': 'value1'},
      'browserUrl': 'https://some-browser.url',
      'deeplink': 'https://some-deeplink.url',
      'webViewUrl': 'https://some-browser.url',
      'inAppOpenTitle': 'InApp Title',
      'inAppDismissTitle': 'Dismiss title',
      'chat': true
    };
  }

  group('toJSON', () {
    test('Configuration', () {
      Configuration configuration = getConfiguration();
      String jsonString = "{applicationCode: abc, pluginVersion: 1.2.3, inAppChatEnabled: true, androidSettings: {firebaseSenderId: ABC-XYZ, notificationIcon: icon.png, multipleNotifications: true, notificationAccentColor: #ABCDEF}, iosSettings: {notificationTypes: [sound], forceCleanup: true, logging: true, webViewSettings: {title: webViewTitle, barTintColor: #012345, titleColor: #135, tintColor: #246}}, privacySettings: {applicationCodePersistingDisabled: true, userDataPersistingDisabled: true, carrierInfoSendingDisabled: true, systemInfoSendingDisabled: true}, notificationCategories: ({identifier: 123, actions: [{identifier: 123456, title: Action Title, foreground: true, authenticationRequired: true, moRequired: true, destructive: true, icon: icon-action.png, textInputActionButtonTitle: Button Title, textInputPlaceholder: Placeholder Title}]}), defaultMessageStorage: true}";

      expect(configuration.toJson().toString(), jsonString);
    });
  });


  group('fromJSON', () {
    test('Message', () {
      Message fromJson = Message.fromJson(getMessageMap());
      Message message = getMessage();

      expect(message, fromJson);
    });
  });
}
