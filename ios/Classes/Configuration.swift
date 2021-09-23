//
//  Configuration .swift
//  infobip_mobilemessaging_flutter_plugin
//
//  Created by Konstantin Latypov on 28.06.2021.
//

import Foundation
import MobileMessaging

class Configuration {
    struct Keys {
        static let iosSettings = "iosSettings"
        static let privacySettings = "privacySettings"
        static let userDataPersistingDisabled = "userDataPersistingDisabled"
        static let carrierInfoSendingDisabled = "carrierInfoSendingDisabled"
        static let systemInfoSendingDisabled = "systemInfoSendingDisabled"
        static let applicationCodePersistingDisabled = "applicationCodePersistingDisabled"
        static let applicationCode = "applicationCode"
        static let forceCleanup = "forceCleanup"
        static let logging = "logging"
        // static let defaultMessageStorage = "defaultMessageStorage"
        static let notificationTypes = "notificationTypes"
        // static let messageStorage = "messageStorage"
        static let pluginVersion = "pluginVersion"
        static let notificationCategories = "notificationCategories"
    }
    
    let appCode: String
    // let geofencingEnabled: Bool
    // let inAppChatEnabled: Bool
    // let messageStorageEnabled: Bool
    // let defaultMessageStorage: Bool
    let notificationType: MMUserNotificationType
    let forceCleanup: Bool
    let logging: Bool
    let privacySettings: [String: Any]
    let pluginVersion: String
    let categories: [MMNotificationCategory]?
    
    init?(rawConfig: [String: AnyObject]) {
        guard let appCode = rawConfig[Configuration.Keys.applicationCode] as? String,
              let ios = rawConfig["iosSettings"] as? [String: AnyObject] else
        {
            return nil
        }
        
        self.appCode = appCode
        self.forceCleanup = ios[Configuration.Keys.forceCleanup].unwrap(orDefault: false)
        self.logging = ios[Configuration.Keys.logging].unwrap(orDefault: false)
        
        if let rawPrivacySettings = rawConfig[Configuration.Keys.privacySettings] as? [String: Any] {
            var ps = [String: Any]()
            ps[Configuration.Keys.userDataPersistingDisabled] = rawPrivacySettings[Configuration.Keys.userDataPersistingDisabled].unwrap(orDefault: false)
            ps[Configuration.Keys.carrierInfoSendingDisabled] = rawPrivacySettings[Configuration.Keys.carrierInfoSendingDisabled].unwrap(orDefault: false)
            ps[Configuration.Keys.systemInfoSendingDisabled] = rawPrivacySettings[Configuration.Keys.systemInfoSendingDisabled].unwrap(orDefault: false)
            ps[Configuration.Keys.applicationCodePersistingDisabled] = rawPrivacySettings[Configuration.Keys.applicationCodePersistingDisabled].unwrap(orDefault: false)
            
            privacySettings = ps
        } else {
            privacySettings = [:]
        }
        
        self.pluginVersion = rawConfig[Configuration.Keys.pluginVersion].unwrap(orDefault: "unknown")
        
        self.categories = (rawConfig[Configuration.Keys.notificationCategories] as? [[String: Any]])?.compactMap(MMNotificationCategory.init)
        
        if let notificationTypeNames =  ios[Configuration.Keys.notificationTypes] as? [String] {
            let options = notificationTypeNames.reduce([], { (result, notificationTypeName) -> [MMUserNotificationType] in
                var result = result
                switch notificationTypeName {
                case "badge": result.append(MMUserNotificationType.badge)
                case "sound": result.append(MMUserNotificationType.sound)
                case "alert": result.append(MMUserNotificationType.alert)
                default: break
                }
                return result
            })
            
            self.notificationType = MMUserNotificationType(options: options)
        } else {
            self.notificationType = MMUserNotificationType.none
        }
    }
}
