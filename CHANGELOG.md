# 6.0.0
## Changed
- Updated dependencies, check [Migration guide](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Migration-Guides)

## Fixed
- Default MessageStorage bug
# 5.1.0
## Added
- new chatAvailabilityUpdated event to indicate when chat is ready to be presented
# 5.0.3
## Changed
- Updated proguard rules for Android.
# 5.0.2
## Changed
- Improved message model for Inbox.
# 5.0.1
## Changed
- provided dictionary representation of Message object for iOS
# 5.0.0
## Added
- Introducing support for [Inbox](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Inbox)
# 4.1.0
## Added
- new [In-App Chat customisations](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/In-app-chat#customize-in-app-chat-view) attributes:
    - common:
       - `widgetTheme` 
    - Android only:
       - `chatMenuItemsIconTint` 
       - `chatMenuItemSaveAttachmentIcon` 
# 4.0.0
## Added
[Full-featured In-app notifications](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/In-app-notifications#full-featured-in-app-notifications). Check [Migration guide](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Migration-Guides#migration-from-30x-to-40x)
# 3.0.0
## Added
- In-app chat support for Simplified Chinese (zh-Hans) language

## Changed
- Android minimum SDK level is 21 (Android 5.0 - Lollipop) now
- In-app chat message limit increased to 4096 characters
# 2.1.1
## Fixed
- Send In-app chat message issue in Android
# 2.1.0
## Added
- New WebRTCUI reconnection indicator.
 
## Changed
- We improved In-app chat attachments feature permissions requesting, and chat connection handling.
 
## Fixed
- In-app chat bug when sending message with special characters.
# 2.0.0
## Added
- In-app chat support for Serbian (Latin) language
- In-app chat messages exceeding the max text length are now automatically sent as smaller messages
 
## Changed
- WebRTCUI using new `configurationId` and provides new options to register for calls. Check [Migration guide](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Migration-Guides#migration-from-1x-to-2x) for more details.
# 1.4.0
## Changed
- InAppChat customizations, check Migration guide
# 1.3.0
## Added
- Option to control In-app chat connection with new methods stopConnection and restartConnection on iOS.

## Changed
- In-app chat now automatically stops and restarts its connection when going to background/locking, and going to foreground/unlocking, optimising push notifications from chat events.
# 1.2.0
## Added
- Support for WebRTC audio and video calls, with built-in user interface.
# 1.1.2
## Fixed
- iOS crash on Hot Restart
## Changed
- iOS better error descriptions
# 1.1.1
## Fixed
- Getting plugin version for installations
# 1.1.0
## Added
- InAppChat authentication with JSON Web Token.
# 1.0.0
## Changed
- Android minimum SDK level is 19 now
- Minimum Flutter version is 3.3.0+
- Naming of files and events
## Fixed
- Plugin events' logging
# 0.9.3
## Added
- option to not start mobileMessaging plugin on iOS - withoutRegisteringForRemoteNotifications.
# 0.9.2
## Fixed
- Bug with using account's location baseUrl on Android.
# 0.9.1
## Fixed
- minor improvement of the android related code connected with asking the permissions
# 0.9.0
## Added
- Android 13 Support
# 0.8.5
## Added
- Added android:exported=true inside example app to correctly run on Android 12

## Fixed
- Fix render error inside example app for delete all message storage

## Changed
- Added linter 
- Reformatted and refactored code according to linter rules
- Remove redundant null checks 
# 0.8.4
## Added
- New wiki page about possible possible ways of setting up Firebase

## Changed
- FirebaseOptions parameter is now optional
- Update Example app to support Android 12
- Configure Firebase setup the preferred way inside Example app 
- Update "How to start Example" app wiki page
# 0.8.3
## Fixed
- Library version in User-Agent for iOS platform

## Changed
- PendingIntent Flag will be IMMUTABLE for all cases except when notification contains reply action
# 0.8.2
## Fixed
- Library version in User-Agent for iOS platform

## Changed
- PendingIntent Flag will be IMMUTABLE for all cases except when notification contains reply action
# 0.8.1
## Added
- Unit tests for json serialization

## Fixed
- Correctly providing FirebaseOptions to AndroidSettings
# 0.8.0
Added:
Method in In-App Chat to send contextual / meta data to Infobip's Conversations backend.
# 0.7.0
## Changed
- Message storage improvements - https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Message-storage
## 0.6.0
* Added Android 12 support

## 0.5.2
* Added ProGuard rules

## 0.5.1
* Fixed obfuscation parameters for configuration

## 0.5.0
* Added Default MessageStorage support

## 0.4.2
* Update Android SDK

## 0.4.1
* Fixed support for lists in customAttributes for Installation and User classes on Android

## 0.4.0
* Added unregister option for events
* iOS personalization fixed

## 0.3.1
* Added iOS WebViewSettings
* fetchInstallation and fetchUser methods fixed

## 0.3.0
* Added in-app chat methods getMessageCounter and resetMessageCounter
* Updated Android and iOS SDKs with new bug-fix versions

## 0.2.2
* Added custom events

## 0.2.1
* Updated iOS SDK dependency
* Fixed personalisation issues at Android

## 0.2.0

* Added example application
* Added InAppChat support
* Fixed callbacks list error
* Fixed events errors

## 0.1.0

* Support for User and Installation management (personalization).

## 0.0.2

* Fixed major bug at Android build

## 0.0.1

* Plugin initialization
  
  Supported features:
    - notification receiving with DLRs
    - seen reports on notification click event
    - notification settings
    - privacy settings
    - Installation (device) data default sync
    - rich notifications
    - interactive notifications
    - in-app notifications
