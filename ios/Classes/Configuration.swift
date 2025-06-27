//
//  Configuration .swift
//  infobip_mobilemessaging_flutter_plugin
//
//  Created by Konstantin Latypov on 28.06.2021.
//

import Foundation
import MobileMessaging

class Configuration {
    static let userDefaultsConfigKey = "com.mobile-messaging.flutterPluginConfiguration"
    
    struct Keys {
        static let iosSettings = "iosSettings"
        static let privacySettings = "privacySettings"
        static let userDataPersistingDisabled = "userDataPersistingDisabled"
        static let carrierInfoSendingDisabled = "carrierInfoSendingDisabled"
        static let systemInfoSendingDisabled = "systemInfoSendingDisabled"
        static let applicationCodePersistingDisabled = "applicationCodePersistingDisabled"
        static let applicationCode = "applicationCode"
        static let inAppChatEnabled = "inAppChatEnabled"
        static let fullFeaturedInAppsEnabled = "fullFeaturedInAppsEnabled"
        static let forceCleanup = "forceCleanup"
        static let logging = "logging"
        static let defaultMessageStorage = "defaultMessageStorage"
        static let notificationTypes = "notificationTypes"
        static let pluginVersion = "pluginVersion"
        static let notificationCategories = "notificationCategories"
        static let webViewSettings = "webViewSettings"
        static let withoutRegisteringForRemoteNotifications = "withoutRegisteringForRemoteNotifications"
        static let webRTCUI = "webRTCUI"
        static let configurationId = "configurationId"
        static let customization = "inAppChatCustomization"
        static let shouldHandleKeyboardAppearance = "shouldHandleKeyboardAppearance"
        static let userDataJwt = "userDataJwt"
    }
    
    let appCode: String
    let inAppChatEnabled: Bool
    let fullFeaturedInAppsEnabled: Bool
    // let messageStorageEnabled: Bool
    let webRTCUI: [String: Any]?
    let defaultMessageStorage: Bool
    let notificationType: MMUserNotificationType
    let forceCleanup: Bool
    let logging: Bool
    let privacySettings: [String: Any]
    let pluginVersion: String
    let categories: [MMNotificationCategory]?
    let webViewSettings: [String: AnyObject]?
    let withoutRegisteringForRemoteNotifications: Bool
    let customization: Customization?
    let userDataJwt: String?
    
    init?(rawConfig: [String: AnyObject]) {
        guard let appCode = rawConfig[Configuration.Keys.applicationCode] as? String,
              let ios = rawConfig["iosSettings"] as? [String: AnyObject] else
        {
            return nil
        }
        
        if let rawConfig = rawConfig[Configuration.Keys.customization] as? [String: Any],
           let jsonObject = try? JSONSerialization.data(
            withJSONObject: rawConfig
           ),
           let customization = try? JSONDecoder().decode(Customization.self, from: jsonObject) {
            self.customization = customization
        } else {
            self.customization = nil
        }
        
        self.webRTCUI = rawConfig[Configuration.Keys.webRTCUI] as? [String: Any]
        self.appCode = appCode
        self.inAppChatEnabled = rawConfig[Configuration.Keys.inAppChatEnabled].unwrap(orDefault: false)
        self.fullFeaturedInAppsEnabled = rawConfig[Configuration.Keys.fullFeaturedInAppsEnabled].unwrap(orDefault: false)
        self.forceCleanup = ios[Configuration.Keys.forceCleanup].unwrap(orDefault: false)
        self.logging = ios[Configuration.Keys.logging].unwrap(orDefault: false)
        self.withoutRegisteringForRemoteNotifications = ios[Configuration.Keys.withoutRegisteringForRemoteNotifications].unwrap(orDefault: false)
        self.userDataJwt = rawConfig[Configuration.Keys.userDataJwt].unwrap(orDefault: nil)
        
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
        
        self.defaultMessageStorage = rawConfig[Configuration.Keys.defaultMessageStorage].unwrap(orDefault: false)
        
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
        
        if let rawWebViewSettings = ios[Configuration.Keys.webViewSettings] as? [String: AnyObject] {
            self.webViewSettings = rawWebViewSettings
        } else {
            self.webViewSettings = nil
        }
    }
    
    static func saveConfigToDefaults(rawConfig: [String: AnyObject]) {
        let data: Data = NSKeyedArchiver.archivedData(withRootObject: rawConfig)
        UserDefaults.standard.set(data, forKey: userDefaultsConfigKey)
    }
    
    static func getRawConfigFromDefaults() -> [String: AnyObject]? {
        let data = UserDefaults.standard.data(forKey: userDefaultsConfigKey)
        guard let data = data else {
            return nil
        }
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? [String : AnyObject]
    }
}
