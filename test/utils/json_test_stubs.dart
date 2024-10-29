Map<String, dynamic> get configurationExampleJson => {
      'applicationCode': 'abc',
      'pluginVersion': '1.2.3',
      'inAppChatEnabled': true,
      'fullFeaturedInAppsEnabled': true,
      'androidSettings': {
        'firebaseOptions': {
          'apiKey': 'Some-API-Key',
          'applicationId': '1:1234567890:android:abc123',
          'projectId': 'project-123ab',
          'databaseUrl': null,
          'gaTrackingId': null,
          'gcmSenderId': null,
          'storageBucket': null,
        },
        'notificationIcon': 'icon.png',
        'multipleNotifications': true,
        'notificationAccentColor': '#ABCDEF',
      },
      'iosSettings': {
        'notificationTypes': ['sound'],
        'forceCleanup': true,
        'logging': true,
        'withoutRegisteringForRemoteNotifications': true,
        'webViewSettings': {
          'title': 'webViewTitle',
          'barTintColor': '#012345',
          'titleColor': '#135',
          'tintColor': '#246',
        }
      },
      'privacySettings': {
        'applicationCodePersistingDisabled': true,
        'userDataPersistingDisabled': true,
        'carrierInfoSendingDisabled': true,
        'systemInfoSendingDisabled': true,
      },
      'notificationCategories': [
        {
          'identifier': '123',
          'actions': [
            {
              'identifier': '123456',
              'title': 'Action Title',
              'foreground': true,
              'authenticationRequired': true,
              'moRequired': true,
              'destructive': true,
              'icon': 'icon-action.png',
              'textInputActionButtonTitle': 'Button Title',
              'textInputPlaceholder': 'Placeholder Title',
            },
          ],
        },
      ],
      'defaultMessageStorage': true,
      'webRTCUI': null,
      'inAppChatCustomization': null
    };

Map<String, dynamic> get installationExampleJson => {
      'pushRegistrationId': 'someRegistrationId',
      'pushServiceToken': 'pushServiceToken',
      'pushServiceType': 'GCM',
      'isPrimaryDevice': true,
      'isPushRegistrationEnabled': true,
      'notificationsEnabled': true,
      'sdkVersion': 'someSdkVersion',
      'appVersion': 'appVersion',
      'os': 'Android',
      'osVersion': '12.0',
      'deviceManufacturer': 'deviceManufacturer',
      'deviceModel': 'deviceModel',
      'deviceSecure': true,
      'language': 'EN',
      'deviceTimezoneOffset': '1234567',
      'applicationUserId': '123',
      'deviceName': 'deviceName',
      'customAttributes': {
        'alList': [
          {
            'alDate': '2021-10-11',
            'alWhole': 2,
            'alString': 'someAnotherString',
            'alBoolean': true,
            'alDecimal': 0.66
          },
        ],
      }
    };

Map<String, dynamic> get installationPrimaryExampleJson => {
      'pushRegistrationId': '123456',
      'primary': true,
    };

Map<String, dynamic> get iosChatSettingsExampleJson => {
      'title': 'title',
      'sendButtonColor': 'green',
      'navigationBarItemsColor': 'red',
      'navigationBarColor': 'blue',
      'navigationBarTitleColor': 'yellow',
    };

Map<String, dynamic> get userIdentityExampleJson => {
      'phones': [
        '123',
        '234',
      ],
      'emails': [
        'test@gmail.com',
        'test2@gmail.com',
      ],
      'externalUserId': '123456',
    };

Map<String, dynamic> get personalizeContextExampleJson => {
      'userIdentity': userIdentityExampleJson,
      'userAttributes': {
        'alList': [
          {
            'alDate': '2021-10-11',
            'alWhole': 2,
            'alString': 'someAnotherString',
            'alBoolean': true,
            'alDecimal': 0.66
          },
        ],
      },
      'forceDepersonalize': true,
      'keepAsLead': false,
    };

Map<String, dynamic> get userDataExampleJson => {
      'externalUserId': 'randomUID123',
      'firstName': 'First',
      'lastName': 'Last',
      'middleName': 'Middle',
      'gender': 'Male',
      'birthday': '01-01-1999',
      'phones': [
        '38516419710',
      ],
      'emails': [
        'some.email@email.com',
      ],
      'tags': [
        'randomTag',
      ],
      'customAttributes': {
        'alList': [
          {
            'alDate': '2021-10-11',
            'alWhole': 2,
            'alString': 'someAnotherString',
            'alBoolean': true,
            'alDecimal': 0.66
          }
        ]
      },
      'installations': [
        installationExampleJson,
      ]
    };

Map<String, dynamic> get messageExampleJson => {
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
      'originalPayload': {'param1': 'value1'},
      'browserUrl': 'https://some-browser.url',
      'deeplink': 'https://some-deeplink.url',
      'webViewUrl': 'https://some-browser.url',
      'inAppOpenTitle': 'InApp Title',
      'inAppDismissTitle': 'Dismiss title',
      'chat': true
    };
