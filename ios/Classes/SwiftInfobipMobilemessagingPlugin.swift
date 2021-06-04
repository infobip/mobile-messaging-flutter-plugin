import Flutter
import UIKit
import MobileMessaging

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

public class SwiftInfobipMobilemessagingPlugin: NSObject, FlutterPlugin {
    
    private var eventsManager: MobileMessagingEventsManager?

    @objc
    func supportedEvents() -> [String]! {
        return [
            EventName.tokenReceived,
            EventName.registrationUpdated,
            EventName.installationUpdated,
            EventName.userUpdated,
            EventName.personalized,
            EventName.depersonalized,
            EventName.geofenceEntered,
            EventName.actionTapped,
            EventName.notificationTapped,
            EventName.messageReceived,
            EventName.messageStorage_start,
            EventName.messageStorage_stop,
            EventName.messageStorage_save,
            EventName.messageStorage_find,
            EventName.messageStorage_findAll,
            EventName.inAppChat_availabilityUpdated
        ]
    }
    
   public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "infobip_mobilemessaging", binaryMessenger: registrar.messenger())
    let instance = SwiftInfobipMobilemessagingPlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
    
    let eventChannel = FlutterEventChannel(name: "infobip_mobilemessaging/broadcast", binaryMessenger: registrar.messenger())
    instance.eventsManager = MobileMessagingEventsManager()
    eventChannel.setStreamHandler(instance.eventsManager)
    instance.eventsManager?.startObserving()
   }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        if call.method == "init" {
            initPlugin(call: call, result: result)
        }
    }
    
    public func initPlugin(call: FlutterMethodCall, result: FlutterResult) {
        guard let jsonString = call.arguments as? String,
              let json = jsonString.toJSON() as? [String: AnyObject],
              let configuration = Configuration.init(rawConfig: json) else {
            return result(
                FlutterError( code: "invalidConfig",
                  message: "Error parsing Configuration",
                  details: "Error parsing Configuration" ))
        }
        
        return start(configuration: configuration)
    }
    
    private func start(configuration: Configuration) {
        MobileMessaging.privacySettings.applicationCodePersistingDisabled = configuration.privacySettings[Configuration.Keys.applicationCodePersistingDisabled].unwrap(orDefault: false)
        MobileMessaging.privacySettings.systemInfoSendingDisabled = configuration.privacySettings[Configuration.Keys.systemInfoSendingDisabled].unwrap(orDefault: false)
        MobileMessaging.privacySettings.carrierInfoSendingDisabled = configuration.privacySettings[Configuration.Keys.carrierInfoSendingDisabled].unwrap(orDefault: false)
        MobileMessaging.privacySettings.userDataPersistingDisabled = configuration.privacySettings[Configuration.Keys.userDataPersistingDisabled].unwrap(orDefault: false)

        var mobileMessaging = MobileMessaging.withApplicationCode(configuration.appCode, notificationType: configuration.notificationType, forceCleanup: configuration.forceCleanup)

        if let categories = configuration.categories {
            mobileMessaging = mobileMessaging?.withInteractiveNotificationCategories(Set(categories))
        }

        MobileMessaging.userAgent.pluginVersion = "flutter \(configuration.pluginVersion)"
        if (configuration.logging) {
            MobileMessaging.logger = MMDefaultLogger()
        }

        mobileMessaging?.start()
        MobileMessaging.sync()
    }

    
    
}
