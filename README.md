# Mobile Messaging SDK plugin for Flutter

Mobile Messaging SDK is designed and developed to easily enable push notification channel in your mobile application. In almost no time of implementation you get push notification in your application and access to the features of [Infobip IP Messaging Platform](https://portal.infobip.com/push/).
The document describes plugin integration steps for your Flutter project.

* [Requirements](#requirements)
* [Quick start guide](#quick-start-guide)

## Requirements
- Flutter 3.3.0+

For iOS project:
- Xcode 13.4.1
- Minimum deployment target 12.0

For Android project:
- Android Studio
- Supported API Levels: 21 (Android 5.0 - Lollipop) - 33 (Android 13.0)

## Quick start guide

This guide is designed to get you up and running with Mobile Messaging SDK plugin for Flutter

1. Make sure to [setup application at the Infobip portal](https://www.infobip.com/docs/mobile-app-messaging/create-mobile-application-profile), if you haven't already.

2. Add MobileMessaging plugin to dependencies at `pubspec.yaml`:

  ```yaml
  dependencies:
    infobip_mobilemessaging: '^5.0.1'

  ```

3. Run `flutter pub get` to install plugin

4. Configure platforms

   - **iOS**
       1. Update the `ios/Podfile` with iOS deployment target platform 12.0 - `platform :ios, '12.0'` if needed, and perform in Terminal `cd ios && pod update `
       2. Import MobileMessaging `@import MobileMessaging;` and add `[MobileMessagingPluginApplicationDelegate install];` into `<ProjectName>/ios/Runner/AppDelegate.m` (this is required for OS callbacks such as `didRegisterForRemoteNotifications` to be intercepted by native MobileMessaging SDK) :
        ```objc
               ...
               @import MobileMessaging;

               @implementation AppDelegate

               - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
               {
                   ...
                   [MobileMessagingPluginApplicationDelegate install];
                   ...
               }
               ...
        ```

     <details><summary>expand to see Swift code</summary>

      ```swift

               import MobileMessaging
               ...
               @UIApplicationMain
               @objc class AppDelegate: FlutterAppDelegate {
                 override func application(
                    _ application: UIApplication,
                    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
                  ) -> Bool {
                     ...
                     MobileMessagingPluginApplicationDelegate.install()
                     ...
                  }
                }
               ...
      ```
      </details>

       3. Configure your project to support Push Notification as described in item 2 of [iOS integration quick start guide](https://github.com/infobip/mobile-messaging-sdk-ios#quick-start-guide)
       4. [Integrate Notification Service Extension](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Delivery-improvements-and-rich-content-notifications) into your app in order to obtain:
           - more accurate processing of messages and delivery stats
           - support of rich notifications on the lock screen
   - **Android**
       1. Add 'com.google.gms:google-services' to `android/build.gradle` file
        ```groovy
        buildscript {
           ...
           dependencies {
               ...
              //Google Services gradle plugin
              classpath 'com.google.gms:google-services:4.3.10'
           }
        }
        ```
        2. Add `apply plugin: 'com.google.gms.google-services'` at the end of your `android/app/build.gradle` in order to apply [Google Services Gradle Plugin](https://developers.google.com/android/guides/google-services-plugin)
        3. Setup Firebase for your project and add a Firebase configuration file (google-services.json) to the app as described in <a href="https://firebase.google.com/docs/android/setup#add-config-file" target="_blank">`Firebase documentation`</a>. Usually it needs to be added into `android/app` folder.
        
        > ### Notice
        > If you want to provide the Firebase configuration differently, check [Applying Firebase configuration](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Applying-Firebase-configuration-in-MobileMessaging-Flutter-plugin) 

        > ### Notice
        > Starting from Android 13, Google requires to ask user for notification permission. Follow <a href="https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Android-13-Notification-Permission-Handling" target="_blank">this guide</a> to make a permission request.

4. Use plugin in your Dart code:
    ```dart
    import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
    import 'package:infobip_mobilemessaging/models/configuration.dart';
    import 'package:infobip_mobilemessaging/models/library_event.dart';

    ...

        await InfobipMobilemessagingFlutterPlugin.init(Configuration(
          applicationCode: "<Your app code>",
          iosSettings: IOSSettings(
            notificationTypes: ["alert", "badge", "sound"],
            logging: true
          )
        ));

        InfobipMobilemessaging.on(LibraryEvent.MESSAGE_RECEIVED, (Message event) => {
           print("Callback. MESSAGE_RECEIVED event,  message text: ${event.body}")
        });

    ...

    ```
