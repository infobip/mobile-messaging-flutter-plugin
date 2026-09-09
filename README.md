# Mobile Messaging SDK plugin for Flutter

Mobile Messaging SDK is designed and developed to easily enable push notification channel in your mobile application. In almost no time of implementation you get push notification in your application and access to the features of [Infobip IP Messaging Platform](https://www.infobip.com/en/products/mobile-app-messaging).
The document describes plugin integration steps for your Flutter project.

* [Requirements](#requirements)
* [Quick start guide](#quick-start-guide)

## Requirements
- Flutter:
  - If using CocoaPods: 3.16.0+
  - If using Swift Package Manager (SPM): 3.24.0+

- For iOS project:
  - Xcode 16.x
  - Minimum deployment target 15.0
  - CocoaPods 1.16.2

- For Android project:
  - Android Studio
  - Supported API Levels: 23 (Android 6.0 - Marshmallow) - 37 (Android 17)

## Quick start guide

This guide is designed to get you up and running with Mobile Messaging SDK plugin for Flutter

1. Make sure to [setup application at the Infobip portal](https://www.infobip.com/docs/mobile-app-messaging/getting-started#create-and-enable-a-mobile-application-profile), if you haven't already.

2. Add MobileMessaging plugin by running:

```css
$ pub get infobip_mobilemessaging
```

3. It will add it to dependencies at `pubspec.yaml`:

  ```yaml
  dependencies:
    infobip_mobilemessaging: '^10.0.0'

  ```

3. Run `flutter pub get` to install plugin

4. Configure platforms

   - **iOS**

       The plugin ships both a CocoaPods podspec and a Swift Package Manager manifest, so your app can integrate it with either dependency manager.

       #### Dependency manager setup

       <details open><summary><b>CocoaPods</b></summary>

       1. Update the `ios/Podfile` with iOS deployment target platform 15.0 - `platform :ios, '15.0'` if needed, and perform in Terminal `cd ios && pod install`

       </details>

       <details><summary><b>Swift Package Manager</b></summary>

       1. Make sure your project uses Flutter 3.24+ with Swift Package Manager support enabled. To enable SPM, run the following command:
        ```bash
        flutter config --enable-swift-package-manager
        ``` 
        - see [Flutter's Swift Package Manager docs](https://docs.flutter.dev/packages-and-plugins/swift-package-manager/for-app-developers) for more information.
       2. Run `flutter pub get` - Flutter reads the plugin's `Package.swift` and wires it into `FlutterGeneratedPluginSwiftPackage` automatically. No manual Xcode project changes are required for the main app target.
       3. Set the iOS deployment target to 15.0.

       </details>

       2. Import MobileMessaging and add `MobileMessagingPluginApplicationDelegate.install()` into `<ProjectName>/ios/Runner/AppDelegate.swift` (this is required for OS callbacks such as `didRegisterForRemoteNotifications` to be intercepted by native MobileMessaging SDK). 
       - If using SPM, import the `infobip_mobilemessaging` dependency.
       - If using CocoaPods, import the `MobileMessaging` depdendency.
       The AppDelegate should now look like the following:
        ```swift
               import UIKit
               import Flutter
               // if using Swift Package Manager, import the infobip_mobilemessaging dependency
               import infobip_mobilemessaging
               // if using CocoaPods, import the MobileMessaging dependency
               import MobileMessaging 

               @main
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

       > ### Notice
       > An Objective-C `AppDelegate.m` is only supported with the CocoaPods integration:
       > ```objc
       >        ...
       >        @import MobileMessaging;
       >
       >        @implementation AppDelegate
       >
       >        - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
       >        {
       >            ...
       >            [MobileMessagingPluginApplicationDelegate install];
       >            ...
       >        }
       >        ...
       > ```
       > Swift Package Manager integration requires a Swift `AppDelegate.swift`.

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
              classpath 'com.google.gms:google-services:4.4.1'
           }
        }
        ```
        2. Add `apply plugin: 'com.google.gms.google-services'` at the end of your `android/app/build.gradle` in order to apply [Google Services Gradle Plugin](https://developers.google.com/android/guides/google-services-plugin)
        3. Setup Firebase for your project and add a Firebase configuration file (google-services.json) to the app as described in <a href="https://firebase.google.com/docs/android/setup#add-config-file" target="_blank">`Firebase documentation`</a>. Usually it needs to be added into `android/app` folder.
        
        > ### Notice
        > If you want to provide the Firebase configuration differently, check [Applying Firebase configuration](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Applying-Firebase-configuration-in-MobileMessaging-Flutter-plugin) 

        > ### Notice
        > Starting from Android 13, Google requires to ask user for notification permission. Follow <a href="https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Android-13-Notification-Permission-Handling" target="_blank">this guide</a> to make a permission request.

4. Use plugin in your `main.dart` file:
    ```dart
    import 'package:infobip_mobilemessaging/infobip_mobilemessaging.dart';
    import 'package:infobip_mobilemessaging/models/configurations/configuration.dart' as mmconf;
    import 'package:infobip_mobilemessaging/models/library_event.dart';

    ...

        await InfobipMobilemessaging.init(mmconf.Configuration(
          applicationCode: '<Your app code>',
          iosSettings: mmconf.IOSSettings(
            notificationTypes: ['alert', 'badge', 'sound'],
            logging: true,
          ),
          androidSettings: mmconf.AndroidSettings(
            multipleNotifications: true,
          ),  
        ));

        InfobipMobilemessaging.on(LibraryEvent.messageReceived, (Message event) => {
           print('Callback. messageReceived event,  message text: ${event.body}')
        });

    ...

    ```
#### More details on SDK features and FAQ you can find on [Wiki](https://github.com/infobip/mobile-messaging-flutter-plugin/wiki)

<br>
<p align="center"><b>NEXT STEPS: <a href="https://github.com/infobip/mobile-messaging-flutter-plugin/wiki/Users-and-installations">Users and installations</a></b></p>
<br>