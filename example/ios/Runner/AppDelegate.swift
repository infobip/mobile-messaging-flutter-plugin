import UIKit
import Flutter
import MobileMessaging

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    MobileMessagingPluginApplicationDelegate.install()
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }
}
