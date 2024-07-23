import Foundation
import MobileMessaging

extension MM_MTMessage {
    var isGeoMessage: Bool {
        let geoAreasDicts = (originalPayload["internalData"] as? [String: Any])?["geo"] as? [[String: Any]]
        return geoAreasDicts != nil
    }
    
    override func dictionary() -> [String: Any] {
        return self.dictionaryRepresentation
    }
}

extension MMBaseMessage {
    class func createFrom(dictionary: [String: Any]) -> MMBaseMessage? {
        guard let messageId = dictionary["messageId"] as? String,
              let originalPayload = dictionary["originalPayload"] as? MMStringKeyPayload else
        {
            return nil
        }
        
        return MMBaseMessage(messageId: messageId, direction: MMMessageDirection.MT, originalPayload: originalPayload, deliveryMethod: .undefined)
    }
    
    func dictionary() -> [String: Any] {
        var result = [String: Any]()
        result["messageId"] = messageId
        result["customPayload"] = originalPayload["customPayload"]
        result["originalPayload"] = originalPayload
        
        if let aps = originalPayload["aps"] as? MMStringKeyPayload {
            result["body"] = aps["body"]
            result["sound"] = aps["sound"]
        }
        
        if let internalData = originalPayload["internalData"] as? MMStringKeyPayload,
           let _ = internalData["silent"] as? MMStringKeyPayload {
            result["silent"] = true
        } else if let silent = originalPayload["silent"] as? Bool {
            result["silent"] = silent
        }
        
        return result
    }
}

extension MMRegion {
    func dictionary() -> [String: Any] {
        var areaCenter = [String: Any]()
        areaCenter["lat"] = center.latitude
        areaCenter["lon"] = center.longitude
        
        var area = [String: Any]()
        area["id"] = identifier
        area["center"] = areaCenter
        area["radius"] = radius
        area["title"] = title
        
        var result = [String: Any]()
        result["area"] = area
        return result
    }
}

extension Optional {
    func unwrap<T>(orDefault fallbackValue: T) -> T {
        switch self {
        case .some(let val as T):
            return val
        default:
            return fallbackValue
        }
    }
}

extension MMInbox {
    func dictionary() -> [String: Any] {
        var result = [String: Any]()
        result["countTotal"] = countTotal
        result["countUnread"] = countUnread
        result["messages"] = messages.map({ return $0.dictionaryRepresentation })
        return result
    }
}

struct EventName {
    static let tokenReceived = "tokenReceived"
    static let registrationUpdated = "registrationUpdated"
    static let installationUpdated = "installationUpdated"
    static let userUpdated = "userUpdated"
    static let personalized = "personalized"
    static let depersonalized = "depersonalized"
    static let geofenceEntered = "geofenceEntered"
    static let actionTapped = "actionTapped"
    static let notificationTapped = "notificationTapped"
    static let messageReceived = "messageReceived"
    static let messageStorage_start = "messageStorage.start"
    static let messageStorage_stop = "messageStorage.stop"
    static let messageStorage_save = "messageStorage.save"
    static let messageStorage_find = "messageStorage.find"
    static let messageStorage_findAll = "messageStorage.findAll"
    static let inAppChat_availabilityUpdated = "inAppChat.availabilityUpdated"
    static let inAppChat_unreadMessageCounterUpdated = "inAppChat.unreadMessageCounterUpdated"
    static let inAppChat_chatViewChanged = "chatView.chatViewChanged"
}
