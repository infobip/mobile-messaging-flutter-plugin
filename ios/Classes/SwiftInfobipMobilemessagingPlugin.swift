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
    private static var chatVC: MMChatViewController?
    private var isStarted: Bool = false
    private var webrtcConfigId: String?
    private var controller: FlutterPluginRegistrar?
    
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
        instance.controller = registrar
        
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
        } else if call.method == "cleanup" {
            cleanup()
        } else if call.method == "setupiOSChatSettings" {
            setupiOSChatSettings(call: call, result: result)
        } else if call.method == "setLanguage" {
            setLanguage(call: call, result: result)
        } else if call.method == "sendContextualData" {
            sendContextualData(call: call, result: result)
        } else if call.method == "setJwt" {
            setJwt(call: call, result: result)
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
        } else if call.method == "enableCalls" {
            enableCalls(call: call, result: result)
        } else if call.method == "enableChatCalls" {
            enableChatCalls(result: result)
        } else if call.method == "disableCalls" {
            disableCalls(result: result)
        } else if call.method == "restartConnection" {
            restartConnection()
        } else if call.method == "stopConnection" {
            stopConnection()
        } else if call.method == "fetchInboxMessages" {
            fetchInboxMessages(call: call, result: result)
        } else if call.method == "fetchInboxMessagesWithoutToken" {
            fetchInboxMessagesWithoutToken(call: call, result: result)
        } else if call.method == "setInboxMessagesSeen" {
            setInboxMessagesSeen(call: call, result: result)
        } else if call.method == "markMessagesSeen" {
            markMessagesSeen(call: call, result: result)
        } else {
            result(FlutterError( code: "NotImplemented",
                                 message: "Error NotImplemented",
                                 details: "Error NotImplemented" ))
        }
    }
    
    public func initPlugin(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let jsonString = call.arguments as? String,
              let json = jsonString.toJSON() as? [String: AnyObject],
              let configuration = Configuration.init(rawConfig: json) else {
            return result(
                FlutterError( code: "invalidConfig",
                              message: "Error parsing Configuration",
                              details: "Error parsing Configuration" ))
        }
        
        let successCallback: FlutterResult = { [weak self] response in
            Configuration.saveConfigToDefaults(rawConfig: json)
            self?.isStarted = true
            return result(response)
        }
        
        let cachedConfigDict = Configuration.getRawConfigFromDefaults()
        if let cachedConfigDict = cachedConfigDict, (json as NSDictionary) != (cachedConfigDict as NSDictionary)
        {
            stop {
                self.start(configuration: configuration, result: successCallback)
            }
        } else if cachedConfigDict == nil || !isStarted {
            start(configuration: configuration, result: successCallback)
        } else {
            return result("success")
        }
    }
    
    private func stop(completion: @escaping () -> Void) {
        self.isStarted = false
        eventsManager?.stop()
        MobileMessaging.stop(false, completion: completion)
    }
    
    private func start(configuration: Configuration, result: @escaping FlutterResult) {
        MobileMessaging.privacySettings.applicationCodePersistingDisabled = configuration.privacySettings[Configuration.Keys.applicationCodePersistingDisabled].unwrap(orDefault: false)
        MobileMessaging.privacySettings.systemInfoSendingDisabled = configuration.privacySettings[Configuration.Keys.systemInfoSendingDisabled].unwrap(orDefault: false)
        MobileMessaging.privacySettings.carrierInfoSendingDisabled = configuration.privacySettings[Configuration.Keys.carrierInfoSendingDisabled].unwrap(orDefault: false)
        MobileMessaging.privacySettings.userDataPersistingDisabled = configuration.privacySettings[Configuration.Keys.userDataPersistingDisabled].unwrap(orDefault: false)
        
        var mobileMessaging = MobileMessaging
            .withApplicationCode(configuration.appCode, notificationType: configuration.notificationType)
        
        if configuration.inAppChatEnabled {
            mobileMessaging = mobileMessaging?.withInAppChat()
        }
        
        if configuration.fullFeaturedInAppsEnabled {
            mobileMessaging = mobileMessaging?.withFullFeaturedInApps()
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
        
#if WEBRTCUI_ENABLED
        if let webrtcDict = configuration.webRTCUI,
           let configId = webrtcDict[Configuration.Keys.configurationId] as? String {
            webrtcConfigId = configId
        }
#endif
        
        mobileMessaging?.start({
            return result("success")
        })
        
        if let customisation = configuration.customisation {
            setupCustomisation(customisation: customisation)
        }
    }
    
    func setupCustomisation(customisation: Customisation) {
        let settings = MMChatSettings.sharedInstance
        if let controller = self.controller {
            CustomisationUtils().setup(customisation: customisation, with: controller, in: settings)
        }
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
                    FlutterError( code: error.mm_code ?? "0",
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
                    FlutterError( code: error.mm_code ?? "0",
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
                    FlutterError( code: error.mm_code ?? "0",
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
                    FlutterError( code: error.mm_code ?? "0",
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
                    FlutterError( code: error.mm_code ?? "0",
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
                    FlutterError( code: error.mm_code ?? "0",
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
                    FlutterError( code: error.mm_code ?? "0",
                                  message: error.mm_message,
                                  details: error.description ))
            } else {
                return self.dictionaryResult(result: result, dict: installations?.map({ $0.dictionaryRepresentation }) ?? [])
            }
        })
    }

    func cleanup() {
        MobileMessaging.cleanUpAndStop(false, completion: {})
    }
    
    func showChat(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let shouldBePresentedModallyIOS = call.arguments as? Bool else {
            
            return result(
                FlutterError( code: "invalidArguments",
                              message: "iOS could not recognize Flutter arguments",
                              details: "iOS could not recognize Flutter arguments" ))
        }
        
        let vc = shouldBePresentedModallyIOS ? MMChatViewController.makeRootNavigationViewController(): MMChatViewController.makeRootNavigationViewControllerWithCustomTransition()
        SwiftInfobipMobilemessagingPlugin.chatVC = vc.children.first as? MMChatViewController
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
        
        MMChatSettings.settings.configureWith(rawConfig: chatSettings)
    }
    
    func setLanguage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let localeString = call.arguments as? String else {
            return result(
                FlutterError( code: "invalidSetLanguage",
                              message: "Error parsing locale string",
                              details: "Error parsing locale string" ))
        }
        guard let chatVC = SwiftInfobipMobilemessagingPlugin.chatVC else {
            MobileMessaging.inAppChat?.setLanguage(localeString)
            return result("success")
        }
        
        let localeS = String(localeString)
        let separator = localeS.contains("_") ? "_" : "-"
        let components = localeS.components(separatedBy: separator)
        let langCode = localeS.contains("zh") ? localeS : components.first
        let lang = MMLanguage.mapLanguage(from: langCode ??
                                          String(localeS.prefix(2)))
        chatVC.setLanguage(lang) { error in
            if let error = error {
                return result(
                    FlutterError( code: "invalidSetLanguage",
                                  message: "Error setting locale in chat",
                                  details: "\(error.localizedDescription)" ))
            } else {
                return result("success")
            }
        }
    }
    
    func setJwt(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let jwt = call.arguments as? String else {
            return result(
                FlutterError( code: "invalidSetJwt",
                              message: "Error parsing JWT string",
                              details: "Error parsing JWT string" ))
        }
        MobileMessaging.inAppChat?.jwt = jwt
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
        if let chatVc = SwiftInfobipMobilemessagingPlugin.chatVC {
            chatVc.sendContextualData(data, multiThreadStrategy: multiThreadStrategy ? .ALL : .ACTIVE) { error in
                if let error = error {
                    result(FlutterError( code: error.mm_code ?? "0",
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
                    FlutterError( code: error.mm_code ?? "0",
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
    
    func fetchInboxMessages(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String : Any],
              let token = args["token"] as? String,
              let extUserId = args["externalUserId"] as? String else {
            return result(
                FlutterError( code: "invalidInbox",
                              message: "Could not retrieve inbox data",
                              details: "Could not retrieve inbox data" ))
        }
        
        let filters = MMInboxFilterOptions(dictRepresentation: convertStringToDictionary(text: args["filterOptions"] as! String) ?? [:])
        MobileMessaging.inbox?.fetchInbox(token: token, externalUserId: extUserId, options: filters, completion: { (inbox, error) in
            if let error = error {
                return result(
                    FlutterError( code: error.mm_code ?? "0",
                                  message: error.mm_message,
                                  details: error.description ))
            } else {
                self.dictionaryResult(result: result, dict: inbox?.dictionary() ?? [:])
            }
        })
    }
    
    func fetchInboxMessagesWithoutToken(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String : Any],
              let extUserId = args["externalUserId"] as? String else {
            return result(
                FlutterError( code: "invalidInbox",
                              message: "Could not retrieve inbox data",
                              details: "Could not retrieve inbox data" ))
        }
        
        let filters = MMInboxFilterOptions(dictRepresentation: convertStringToDictionary(text: args["filterOptions"] as! String) ?? [:])
        MobileMessaging.inbox?.fetchInbox(externalUserId: extUserId, options: filters, completion: { (inbox, error) in
            if let error = error {
                return result(
                    FlutterError( code: error.mm_code ?? "0",
                                  message: error.mm_message,
                                  details: error.description ))
            } else {
                self.dictionaryResult(result: result, dict: inbox?.dictionary() ?? [:])
            }
        })
    }
    
    func setInboxMessagesSeen(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String : Any],
              let extUserId = args["externalUserId"] as? String,
              let mIds = args["messageIds"] as? [String]
        else {
            return result(
                FlutterError( code: "invalidInbox",
                              message: "Could not retrieve inbox data",
                              details: "Could not retrieve inbox data" ))
        }
        
        
        MobileMessaging.inbox?.setSeen(externalUserId: extUserId, messageIds: mIds, completion: { error in
            if let error = error {
                return result(
                    FlutterError( code: error.mm_code ?? "0",
                                  message: error.mm_message,
                                  details: error.description ))
            } else {
                return result("success")
            }
        })
    }
    
    func markMessagesSeen(call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let messageIds = call.arguments as? [String], !messageIds.isEmpty  else {
            return result(
                FlutterError( code: "invalidSeen",
                              message: "Could not retrieve message ids from data",
                              details: "Could not retrieve message ids from data" ))
        }
        
        MobileMessaging.setSeen(messageIds: messageIds, completion: {
            return result("success")
        })
        
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
    
    private func convertStringToDictionary(text: String) -> [String:AnyObject]? {
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
    
#if WEBRTCUI_ENABLED
    private func handleCalls(
        _ identity: MMWebRTCIdentityMode,
        result: @escaping FlutterResult)
    {
        if let webRTCId = webrtcConfigId {
            MobileMessaging.webRTCService?.configurationId = webRTCId
            MobileMessaging.webRTCService?.identityMode = identity
            MobileMessaging.webRTCService?.start({ response in
                switch response {
                case true:
                    return result("[WebRTCUI] Request for enabling calls ended with success.")
                case false:
                    return result(
                        FlutterError( code: "errorWebRTCUIResult",
                                      message: "[WebRTCUI] Request for enabling calls ended with failure - See further logs.",
                                      details: "[WebRTCUI] Request for enabling calls ended with failure - See further logs." ))
                    
                }
            })
        } else {
            return result(
                FlutterError( code: "errorWebRTCUIResult",
                              message: "[WebRTCUI] WebRTC's applicationId not defined in the configuration, calls were not enabled.",
                              details: "[WebRTCUI] WebRTC's applicationId not defined in the configuration, calls were not enabled." ))
        }
    }
#endif
    
    func enableCalls(call: FlutterMethodCall, result: @escaping FlutterResult) {
#if WEBRTCUI_ENABLED
        guard let identityString = call.arguments as? String else {
            return result(
                FlutterError( code: "errorWebRTCUIResult",
                              message: "[WebRTCUI] No identity was provided.",
                              details: "[WebRTCUI] No identity was provided." ))
        }
        let identityMode: MMWebRTCIdentityMode = identityString.isEmpty ? .default : .custom(identityString)
        handleCalls(identityMode, result: result)
#else
        return result(
            FlutterError( code: "errorWebRTCUIResult",
                          message: "[WebRTCUI] Not imported properly in podfile: library cannot be used.",
                          details: "[WebRTCUI] Not imported properly in podfile: library cannot be used." ))
#endif
    }
    
    func enableChatCalls(result: @escaping FlutterResult) {
#if WEBRTCUI_ENABLED
        handleCalls(.inAppChat, result: result)
#else
        return result(
            FlutterError( code: "errorWebRTCUIResult",
                          message: "[WebRTCUI] Not imported properly in podfile: library cannot be used.",
                          details: "[WebRTCUI] Not imported properly in podfile: library cannot be used." ))
#endif
    }
    
    func disableCalls(result: @escaping FlutterResult) {
#if WEBRTCUI_ENABLED
        MobileMessaging.webRTCService?.stopService({ response in
            switch response {
            case true:
                return result("[WebRTCUI] Request for disabling calls ended with success")
            case false:
                return result(
                    FlutterError( code: "errorWebRTCUIResult",
                                  message: "[WebRTCUI] Request for disabling calls ended with failure - See further logs.",
                                  details: "[WebRTCUI] Request for disabling calls ended with failure - See further logs." ))
            }
        })
#else
        return result(
            FlutterError( code: "errorWebRTCUIResult",
                          message: "[WebRTCUI] Not imported properly in podfile: library cannot be used.",
                          details: "[WebRTCUI] Not imported properly in podfile: library cannot be used." ))
#endif
    }
    
    func restartConnection() {
        guard let chatVC = SwiftInfobipMobilemessagingPlugin.chatVC else { return }
        chatVC.restartConnection()
    }
    
    func stopConnection() {
        guard let chatVC = SwiftInfobipMobilemessagingPlugin.chatVC else { return }
        chatVC.stopConnection()
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if (hexString.hasPrefix("#")) {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let r = Int(color >> 16) & mask
        let g = Int(color >> 8) & mask
        let b = Int(color) & mask
        let red   = CGFloat(r) / 255.0
        let green = CGFloat(g) / 255.0
        let blue  = CGFloat(b) / 255.0
        self.init(red:red, green:green, blue:blue, alpha:alpha)
    }
}

extension String {
    func toColor() -> UIColor? {
        return UIColor(hexString: self)
    }
}
