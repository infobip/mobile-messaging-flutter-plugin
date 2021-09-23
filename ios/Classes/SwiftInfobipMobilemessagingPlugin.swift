import Flutter
import UIKit
import MobileMessaging

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

public typealias DictionaryRepresentation = [String : Any]

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
        } else if call.method == "saveUser" {
            saveUser(call: call, result: result)
        } else if call.method == "fetchUser" {
            fetchUser(result: result)
        } else if call.method == "getUser" {
            getUser(result: result)
        } else if call.method == "saveInstallation" {
            saveInstallation(call: call, result: result)
        } else if call.method == "fetchInstallation" {
            fetchInstallation(result: result)
        } else if call.method == "getInstallation" {
            getInstallation(result: result)
        } else if call.method == "setInstallationAsPrimary" {
            setInstallationAsPrimary(call: call, result: result)
        } else if call.method == "personalize" {
            personalize(call: call, result: result)
        } else if call.method == "depersonalize" {
            depersonalize(result: result)
        } else if call.method == "depersonalizeInstallation" {
            depersonalizeInstallation(call: call, result: result)
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
        
        start(configuration: configuration)
        return result("success")
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
    
    func saveUser(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let jsonString = call.arguments as? String,
              let userDataDictionary = convertStringToDictionary(text: jsonString),
              let user = MMUser(dictRepresentation: userDataDictionary) else
        {
            return result(
               FlutterError( code: "invalidUser",
                 message: "Error parsing User Data",
                 details: "Error parsing User Data" ))
        }

        MobileMessaging.saveUser(user, completion: { (error) in
            if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                 message: error.mm_message,
                                 details: error.description ))
            } else {
                return self.dictionaryResulut(result: result, dict: MobileMessaging.getUser()?.dictionaryRepresentation)
            }
        })
    }
    
    func fetchUser(result: @escaping FlutterResult) {
        MobileMessaging.fetchUser(completion: { (user, error) in
            if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                 message: error.mm_message,
                                 details: error.description ))
            } else {
                return self.dictionaryResulut(result: result, dict: MobileMessaging.getUser()?.dictionaryRepresentation)
            }
        })
    }
    
    func getUser(result: @escaping FlutterResult) {
        return self.dictionaryResulut(result: result, dict: MobileMessaging.getUser()?.dictionaryRepresentation)
    }
    
    func saveInstallation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let jsonString = call.arguments as? String,
              let installationDictionary = convertStringToDictionary(text: jsonString),
              let installation = MMInstallation(dictRepresentation: installationDictionary) else
        {
            return result(
               FlutterError( code: "invalidInstallation",
                 message: "Error parsing Installation Data",
                 details: "Error parsing Installation Data" ))
        }
        
        MobileMessaging.saveInstallation(installation, completion: { (error) in
            if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                 message: error.mm_message,
                                 details: error.description ))
            } else {
                return self.dictionaryResulut(result: result, dict: MobileMessaging.getInstallation()?.dictionaryRepresentation)
            }
        })
    }
    
    func fetchInstallation(result: @escaping FlutterResult) {
        MobileMessaging.fetchInstallation(completion: { (installation, error) in
            if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                 message: error.mm_message,
                                 details: error.description ))
            } else {
                return self.dictionaryResulut(result: result, dict: installation?.dictionaryRepresentation)
            }
        })
    }
    
    func getInstallation(result: @escaping FlutterResult) {
        return self.dictionaryResulut(result: result, dict: MobileMessaging.getInstallation()?.dictionaryRepresentation)
    }
    
    func setInstallationAsPrimary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {

            return result(
               FlutterError( code: "invalidArguments",
                 message: "iOS could not recognize flutter arguments",
                 details: "iOS could not recognize flutter arguments" ))
        }
        guard let pushRegId = args["pushRegistrationId"] as? String,
              let primary = args["primary"] as? Bool else
        {
            return result(
               FlutterError( code: "invalidInstallation",
                 message: "Error parsing Installation Data",
                 details: "Error parsing Installation Data" ))
        }
        MobileMessaging.setInstallation(withPushRegistrationId: pushRegId, asPrimary: primary, completion: { (installations, error) in
            if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                 message: error.mm_message,
                                 details: error.description ))
            } else {
                return result("success")
            }
        })
    }
    
    func personalize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {

            return result(
               FlutterError( code: "invalidArguments",
                 message: "iOS could not recognize flutter arguments",
                 details: "iOS could not recognize flutter arguments" ))
        }
        guard let context = args["context"] as? [String: Any],
              let uiDict = context["userIdentity"] as? [String: Any] else
        {
            return result(
               FlutterError( code: "invalidContext",
                 message: "Error parsing Context Data",
                 details: "Error parsing Context Data" ))
        }
        guard let ui = MMUserIdentity(phones: uiDict["phones"] as? [String], emails: uiDict["emails"] as? [String], externalUserId: uiDict["externalUserId"] as? String) else
        {
            return result(
               FlutterError( code: "invalidContext",
                 message: "userIdentity must have at least one non-nil property",
                 details: "userIdentity must have at least one non-nil property" ))
        }
        let uaDict = context["userAttributes"] as? [String: Any]
        let ua = uaDict == nil ? nil : MMUserAttributes(dictRepresentation: uaDict!)
        MobileMessaging.personalize(withUserIdentity: ui, userAttributes: ua) { (error) in
            if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                 message: error.mm_message,
                                 details: error.description ))
            } else {
                return self.dictionaryResulut(result: result, dict: MobileMessaging.getUser()?.dictionaryRepresentation)
            }
        }
    }
    
    func depersonalize(result: @escaping FlutterResult) {
        MobileMessaging.depersonalize(completion: { (status, error) in
            if (status == MMSuccessPending.pending) {
                return result("pending")
            } else if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                 message: error.mm_message,
                                 details: error.description ))
            } else {
                return result("success")
            }
        })
    }
 
    func depersonalizeInstallation(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {

            return result(
               FlutterError( code: "invalidArguments",
                 message: "iOS could not recognize flutter arguments",
                 details: "iOS could not recognize flutter arguments" ))
        }
        guard let pushRegId = args["pushRegistrationId"] as? String else
        {
            return result(
               FlutterError( code: "invalidPushRegId",
                 message: "Error parsing PushRegId Data",
                 details: "Error parsing PushRegId Data" ))
        }
        MobileMessaging.depersonalizeInstallation(withPushRegistrationId: pushRegId, completion: { (installations, error) in
            if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                 message: error.mm_message,
                                 details: error.description ))
            } else {
                return result("success")
            }
        })
    }
    
    private func dictionaryResulut(result: @escaping FlutterResult, dict: DictionaryRepresentation?) {
        do {
            return result(String(data:
                            try JSONSerialization.data(withJSONObject: dict ?? [:]),
                          encoding: String.Encoding.utf8))
        } catch {
            return result(
               FlutterError( code: "errorSerializingResult",
                 message: "Error while serializing result Data",
                 details: "Error while serializing result Data" ))
        }
    }
    
    private  func convertStringToDictionary(text: String) -> [String:AnyObject]? {
       if let data = text.data(using: .utf8) {
           do {
               let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:AnyObject]
               return json
           } catch {
               print("Something went wrong")
           }
       }
       return nil
   }
}
