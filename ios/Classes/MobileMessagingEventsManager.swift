import Foundation
import MobileMessaging

class MobileMessagingEventsManager: NSObject, FlutterStreamHandler {
    
    fileprivate var cachedMobileMessagingNotifications = [Notification]()
    
    func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
        _eventSink = events;
        cachedMobileMessagingNotifications.forEach { (n) in
            handleMMNotification(notification: n)
        }
        cachedMobileMessagingNotifications = []
        return nil;
    }
    
    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        _eventSink = nil;
        return nil;
    }
    
    fileprivate var _eventSink: FlutterEventSink?
    fileprivate var hasEventListeners = false
    
    var supportedNotifications: [String: String] = [
            EventName.messageReceived: MMNotificationMessageReceived,
            EventName.tokenReceived:  MMNotificationDeviceTokenReceived,
            EventName.registrationUpdated:  MMNotificationRegistrationUpdated,
            EventName.geofenceEntered: MMNotificationGeographicalRegionDidEnter,
            EventName.notificationTapped: MMNotificationMessageTapped,
            EventName.actionTapped: MMNotificationActionTapped,
            EventName.depersonalized: MMNotificationDepersonalized,
            EventName.personalized: MMNotificationPersonalized,
            EventName.installationUpdated: MMNotificationInstallationSynced,
            EventName.userUpdated: MMNotificationUserSynced,
            EventName.inAppChat_availabilityUpdated: MMNotificationInAppChatAvailabilityUpdated
        ]
    

    func startObserving() {
        hasEventListeners = true
    }

    func stopObserving() {
        hasEventListeners = false
    }

    override init() {
        super.init()
        setupObservingMMNotifications()
    }
    
    func stop() {
        setupObservingMMNotifications(stopObservations: true)
    }

    private func setupObservingMMNotifications(stopObservations: Bool = false) {
        supportedNotifications.forEach { (kv) in
            let name = NSNotification.Name(rawValue: kv.value)
            NotificationCenter.default.removeObserver(self, name: name, object: nil)
            if !stopObservations {
                NotificationCenter.default.addObserver(self, selector: #selector(handleMMNotification(notification:)), name: name, object: nil)
            }
        }
    }

    @objc func handleMMNotification(notification: Notification) {
        guard hasEventListeners else {
            return
        }

        guard _eventSink != nil else { 
            cachedMobileMessagingNotifications.append(notification)
            return
        }
        
        var eventName: String?
        var notificationResult: Any?
        switch notification.name.rawValue {
        case MMNotificationMessageReceived:
            eventName = EventName.messageReceived
            if let message = notification.userInfo?[MMNotificationKeyMessage] as? MM_MTMessage {
                notificationResult = message.dictionaryRepresentation
            }
        case MMNotificationDeviceTokenReceived:
            eventName = EventName.tokenReceived
            if let token = notification.userInfo?[MMNotificationKeyDeviceToken] as? String {
                notificationResult = token
            }
        case MMNotificationRegistrationUpdated:
            eventName = EventName.registrationUpdated
            if let internalId = notification.userInfo?[MMNotificationKeyRegistrationInternalId] as? String {
                notificationResult = internalId
            }
        case MMNotificationGeographicalRegionDidEnter:
            eventName = EventName.geofenceEntered
           if let region = notification.userInfo?[MMNotificationKeyGeographicalRegion] as? MMRegion {
               notificationResult = region.dictionary()
           }
        case MMNotificationMessageTapped:
            eventName = EventName.notificationTapped
            if let message = notification.userInfo?[MMNotificationKeyMessage] as? MM_MTMessage {
                notificationResult = message.dictionaryRepresentation
            }
        case MMNotificationActionTapped:
            eventName = EventName.actionTapped
            if let message = notification.userInfo?[MMNotificationKeyMessage] as? MM_MTMessage, let actionIdentifier = notification.userInfo?[MMNotificationKeyActionIdentifier] as? String {
                var parameters = [message.dictionary(), actionIdentifier] as [Any]
                if let textInput = notification.userInfo?[MMNotificationKeyActionTextInput] as? String {
                    parameters.append(textInput)
                }
                notificationResult = parameters
            }
        case MMNotificationDepersonalized:
            eventName = EventName.depersonalized
        case MMNotificationPersonalized:
            eventName = EventName.personalized
        case MMNotificationInstallationSynced, MMNotificationUserSynced :
            eventName = EventName.installationUpdated
            if let installation = notification.userInfo?[MMNotificationKeyInstallation] as? MMInstallation {
                notificationResult = installation.dictionaryRepresentation
            } else if let user = notification.userInfo?[MMNotificationKeyUser] as? MMUser {
                eventName = EventName.userUpdated
                notificationResult = user.dictionaryRepresentation
            }
        case MMNotificationInAppChatAvailabilityUpdated:
            eventName = EventName.inAppChat_availabilityUpdated
            notificationResult = notification.userInfo?[MMNotificationKeyInAppChatEnabled] as? Bool
        default: break
        }

        do {
            _eventSink?(String(data: try JSONSerialization.data(withJSONObject: ["eventName": eventName, "payload": notificationResult]), encoding: String.Encoding.utf8))
        } catch {
            //
        }
    }
    
}

class ChatMobileMessagingEventsManager: MobileMessagingEventsManager {
    
    override var supportedNotifications: [String: String] {
        get {
            return [
                EventName.inAppChat_availabilityUpdated: MMNotificationInAppChatAvailabilityUpdated,
                EventName.inAppChat_chatViewChanged: MMNotificationInAppChatViewChanged
            ]
        }
        set {
            super.supportedNotifications = newValue
        }
    }
    
    
    override func handleMMNotification(notification: Notification) {
        guard hasEventListeners else {
            return
        }

        guard _eventSink != nil else {
            cachedMobileMessagingNotifications.append(notification)
            return
        }
        
        var eventName: String?
        var notificationResult: Any?

        switch notification.name.rawValue {
        case MMNotificationInAppChatViewChanged:
            eventName = EventName.inAppChat_chatViewChanged
            notificationResult = notification.userInfo?[MMNotificationKeyInAppChatViewChanged] as? String
        case MMNotificationInAppChatAvailabilityUpdated:
            guard let status = notification.userInfo?[MMNotificationKeyInAppChatEnabled] as? Bool else {
                return
            }
            
            if status {
                eventName = "chatView.chatReconnected"
            } else {
                eventName = "chatView.chatDisconnected"
            }
        default:
            break
        }
        
        do {
            _eventSink?(String(data: try JSONSerialization.data(withJSONObject: ["eventName": eventName, "payload": notificationResult]), encoding: String.Encoding.utf8))
        } catch {
            //
        }
    }
}
