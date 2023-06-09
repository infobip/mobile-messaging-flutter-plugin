import Flutter
import UIKit
import MobileMessaging

extension String {
    func toJSON() -> Any? {
        guard let data = self.data(using: .utf8, allowLossyConversion: false) else { return nil }
        return try? JSONSerialization.jsonObject(with: data, options: .mutableContainers)
    }
}

extension UIApplication {
    class func topViewController(controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
        if let navigationController = controller as? UINavigationController {
            return topViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return topViewController(controller: selected)
            }
        }
        if let presented = controller?.presentedViewController {
            return topViewController(controller: presented)
        }
        return controller
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
            EventName.inAppChat_availabilityUpdated,
            EventName.inAppChat_unreadMessageCounterUpdated
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
        } else if call.method == "showChat" {
            showChat(call: call, result: result)
        } else if call.method == "setupiOSChatSettings" {
            setupiOSChatSettings(call: call, result: result)
        } else if call.method == "setLanguage" {
            setLanguage(call: call, result: result)
        } else if call.method == "sendContextualData" {
            sendContextualData(call: call, result: result)
        } else if call.method == "submitEvent" {
            submitEvent(call: call, result: result)
        } else if call.method == "submitEventImmediately" {
            submitEventImmediately(call: call, result: result)
        } else if call.method == "getMessageCounter" {
            getMessageCounter(call: call, result: result)
        } else if call.method == "resetMessageCounter" {
            resetMessageCounter()
        } else if call.method == "defaultMessageStorage_find" {
            defaultMessageStorage_find(call: call, result: result)
        } else if call.method == "defaultMessageStorage_findAll" {
            defaultMessageStorage_findAll(result: result)
        } else if call.method == "defaultMessageStorage_delete" {
            defaultMessageStorage_delete(call: call, result: result)
        } else if call.method == "defaultMessageStorage_deleteAll" {
            defaultMessageStorage_deleteAll(result: result)
        } else if call.method == "registerForRemoteNotifications" {
            registerForRemoteNotifications()
        } else {
            result(FlutterError( code: "NotImplemented",
                          message: "Error NotImplemented",
                          details: "Error NotImplemented" ))
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
        
        if configuration.inAppChatEnabled {
            mobileMessaging = mobileMessaging?.withInAppChat()
        }
        
        if let categories = configuration.categories {
            mobileMessaging = mobileMessaging?.withInteractiveNotificationCategories(Set(categories))
        }
        
        if let webViewSettings = configuration.webViewSettings {
            mobileMessaging?.webViewSettings.configureWith(rawConfig: webViewSettings)
        }
 
        MobileMessaging.userAgent.pluginVersion = "flutter \(configuration.pluginVersion)"
        if (configuration.logging) {
            MobileMessaging.logger = MMDefaultLogger()
        }
        
        if configuration.defaultMessageStorage {
            mobileMessaging = mobileMessaging?.withDefaultMessageStorage()
        }

        if (configuration.withoutRegisteringForRemoteNotifications) {
            mobileMessaging = mobileMessaging?.withoutRegisteringForRemoteNotifications()
        }
        
        mobileMessaging?.start()
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
                return self.dictionaryResult(result: result, dict: MobileMessaging.getUser()?.dictionaryRepresentation)
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
                return self.dictionaryResult(result: result, dict: user?.dictionaryRepresentation)
            }
        })
    }
    
    func getUser(result: @escaping FlutterResult) {
        return self.dictionaryResult(result: result, dict: MobileMessaging.getUser()?.dictionaryRepresentation)
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
                return self.dictionaryResult(result: result, dict: MobileMessaging.getInstallation()?.dictionaryRepresentation)
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
                return self.dictionaryResult(result: result, dict: installation?.dictionaryRepresentation)
            }
        })
    }
    
    func getInstallation(result: @escaping FlutterResult) {
        return self.dictionaryResult(result: result, dict: MobileMessaging.getInstallation()?.dictionaryRepresentation)
    }
    
    func setInstallationAsPrimary(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? Dictionary<String, Any> else {
            
            return result(
                FlutterError( code: "invalidArguments",
                              message: "iOS could not recognize Flutter arguments",
                              details: "iOS could not recognize Flutter arguments" ))
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
                return self.dictionaryResult(result: result, dict: installations?.map({ $0.dictionaryRepresentation }) ?? [])
            }
        })
    }
    
    func personalize(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let jsonString = call.arguments as? String,
              let context = convertStringToDictionary(text: jsonString) else {
                  return result(
                    FlutterError( code: "invalidArguments",
                                  message: "iOS could not recognize Flutter arguments",
                                  details: "iOS could not recognize Flutter arguments" ))
              }
        guard let uiDict = context["userIdentity"] as? [String: Any] else
        {
            return result(
                FlutterError( code: "invalidContext",
                              message: "Error parsing Context Data",
                              details: "Error parsing Context Data" ))
        }
        guard let ui = MMUserIdentity(phones: uiDict["phones"] as? [String], emails: uiDict["emails"] as? [String], externalUserId: uiDict["externalUserId"] as? String)    else
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
                return self.dictionaryResult(result: result, dict: MobileMessaging.getUser()?.dictionaryRepresentation)
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
        guard let pushRegId = call.arguments as? String else
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
                return self.dictionaryResult(result: result, dict: installations?.map({ $0.dictionaryRepresentation }) ?? [])
            }
        })
    }
    
    func showChat(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let shouldBePresentedModallyIOS = call.arguments as? Bool else {
            
            return result(
                FlutterError( code: "invalidArguments",
                              message: "iOS could not recognize Flutter arguments",
                              details: "iOS could not recognize Flutter arguments" ))
        }
        
        let vc = shouldBePresentedModallyIOS ? MMChatViewController.makeRootNavigationViewController(): MMChatViewController.makeRootNavigationViewControllerWithCustomTransition()
        if shouldBePresentedModallyIOS {
            vc.modalPresentationStyle = .fullScreen
        }
        if let rootVc = UIApplication.topViewController() {
            rootVc.present(vc, animated: true, completion: nil)
        } else {
            MMLogDebug("[InAppChat] could not define root vc to present in-app-chat")
        }
        return result("success")
    }
    
    func setupiOSChatSettings(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let jsonString = call.arguments as? String,
              let chatSettings = convertStringToDictionary(text: jsonString) else {
                  return result(
                    FlutterError( code: "invalidiOSChatSettings",
                                  message: "Error parsing iOSChatSettings",
                                  details: "Error parsing iOSChatSettings" ))
              }
        
        MobileMessaging.inAppChat?.settings.configureWith(rawConfig: chatSettings)
    }
    
    func setLanguage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let localeString = call.arguments as? String else {
                  return result(
                    FlutterError( code: "invalidSetLanguage",
                                  message: "Error parsing locale string",
                                  details: "Error parsing locale string" ))
              }

        MobileMessaging.inAppChat?.setLanguage(localeString)
        return result("success")
    }

    func sendContextualData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let data = args["data"] as? String,
              let multiThreadStrategy = args["allMultiThreadStrategy"] as? Bool else {
                  return result(
                    FlutterError( code: "CONTEXTUAL_METADATA_ERROR",
                                  message: "Cannot resolve data or allMultiThreadStrategy from arguments",
                                  details: nil ))
              }
        if let chatVc = UIApplication.topViewController() as? MMChatViewController {
            chatVc.sendContextualData(data, multiThreadStrategy: multiThreadStrategy ? .ALL : .ACTIVE) { error in
                if let error = error {
                    result(FlutterError( code: String(error.code),
                                         message: error.mm_message,
                                         details: error.description ))
                } else {
                    return result("success")
                }
            }
        } else {
            MMLogDebug("[InAppChat] could find chat view controller to send contextual data to")
        }
    }

    func submitEvent(call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let jsonString = call.arguments as? String,
              let customEventDictionary = convertStringToDictionary(text: jsonString),
              let customEvent = MMCustomEvent(dictRepresentation: customEventDictionary) else
              {
                  return result(
                    FlutterError( code: "invalidEvent",
                                  message: "Error parsing Custom Event Data",
                                  details: "Error parsing Custom Event Data" ))
              }
        MobileMessaging.submitEvent(customEvent)
    }
    
    func submitEventImmediately(call: FlutterMethodCall, result: @escaping FlutterResult){
        guard let jsonString = call.arguments as? String,
              let customEventDictionary = convertStringToDictionary(text: jsonString),
              let customEvent = MMCustomEvent(dictRepresentation: customEventDictionary) else
              {
                  return result(
                    FlutterError( code: "invalidEvent",
                                  message: "Error parsing Custom Event Data",
                                  details: "Error parsing Custom Event Data" ))
              }
        MobileMessaging.submitEvent(customEvent) { (error) in
            if let error = error {
                return result(
                    FlutterError( code: String(error.code),
                                  message: error.mm_message,
                                  details: error.description ))
            } else {
                return result("success")
            }
        }
    }
    
    func getMessageCounter(call: FlutterMethodCall, result: @escaping FlutterResult){
        return result(MobileMessaging.inAppChat?.getMessageCounter ?? 0)
    }
    
    func resetMessageCounter(){
        MobileMessaging.inAppChat?.resetMessageCounter()
    }

    func registerForRemoteNotifications(){
        MobileMessaging.registerForRemoteNotifications()
    }
    
    
    func defaultMessageStorage_find(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let messageId = call.arguments as? String else
        {
            return result(
                FlutterError( code: "invalidMessageId",
                              message: "Error parsing messageId Data",
                              details: "Error parsing messageId Data" ))
        }
        
        guard let storage = MobileMessaging.defaultMessageStorage else {
            return result(
              FlutterError( code: "invalidMessageStorage",
                            message: "Error fetching MessageStorage",
                            details: "Error fetching MessageStorage" ))
        }

        storage.findMessages(withIds: [(messageId as MessageId)], completion: { messages in
            let res = [messages?[0].dictionary() ?? [:]]
            return self.dictionaryResult(result: result, dict: res)
        })
    }

    func defaultMessageStorage_findAll(result: @escaping FlutterResult) {
        guard let storage = MobileMessaging.defaultMessageStorage else {
            return result(
              FlutterError( code: "invalidMessageStorage",
                            message: "Error fetching MessageStorage",
                            details: "Error fetching MessageStorage" ))
        }

        storage.findAllMessages(completion: { messages in
            let res = messages?.map({$0.dictionary()})
            return self.dictionaryResult(result: result, dict: res ?? [])
        })
    }

    func defaultMessageStorage_delete(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let messageId = call.arguments as? String else
        {
            return result(
                FlutterError( code: "invalidMessageId",
                              message: "Error parsing messageId Data",
                              details: "Error parsing messageId Data" ))
        }
        
        guard let storage = MobileMessaging.defaultMessageStorage else {
            return result(
              FlutterError( code: "invalidMessageStorage",
                            message: "Error fetching MessageStorage",
                            details: "Error fetching MessageStorage" ))
        }

        storage.remove(withIds: [(messageId as MessageId)]) { _ in
            return result("success")
        }
    }

    func defaultMessageStorage_deleteAll(result: @escaping FlutterResult) {
        MobileMessaging.defaultMessageStorage?.removeAllMessages() { _ in
            return result("success")
        }
    }
    
    private func dictionaryResult(result: @escaping FlutterResult, dict: DictionaryRepresentation?) {
        do {
            return result(String(data:
                                    try JSONSerialization.data(withJSONObject: dict ?? [:]),
                                 encoding: String.Encoding.utf8))
        } catch {
            return result(
                FlutterError( code: "errorSerializingResult",
                              message: "Error while serializing Result Data",
                              details: "Error while serializing Result Data" ))
        }
    }
    
    private func dictionaryResult(result: @escaping FlutterResult, dict: [[String: Any]]) {
        do {
            return result(String(data:
                                    try JSONSerialization.data(withJSONObject: dict),
                                 encoding: String.Encoding.utf8))
        } catch {
            return result(
                FlutterError( code: "errorSerializingResult",
                              message: "Error while serializing Result Data",
                              details: "Error while serializing Result Data" ))
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
