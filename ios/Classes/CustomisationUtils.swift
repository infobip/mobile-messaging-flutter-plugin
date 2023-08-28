//
//  CustomisationUtils.swift
//  infobip_mobilemessaging_flutter_plugin
//
//  Created by Maksym Svitlovskyi on 16.08.2023.
//

import Foundation
import MobileMessaging
import Flutter
import UIKit

struct Customisation: Decodable {
    var toolbarTitle: String?
    var sendButtonTintColor: String?
    var toolbarTintColor: String?
    var toolbarBackgroundColor: String?
    var toolbarTitleColor: String?
    var chatBackgroundColor: String?
    var noConnectionAlertTextColor: String?
    var noConnectionAlertBackgroundColor: String?
    var chatInputPlaceholderTextColor: String?
    var chatInputCursorColor: String?
    var sendButtonIcon: String?
    var attachmentButtonIcon: String?
    var chatInputSeparatorVisible: Bool?

    var ios: IOSSpecificCustomisation?
}

struct IOSSpecificCustomisation: Decodable { 
    var attachmentPreviewBarsColor: String?
    var attachmentPreviewItemsColor: String?
    var textContainerTopMargin: CGFloat?
    var textContainerLeftPadding: CGFloat?
    var textContainerCornerRadius: CGFloat?
    var textViewTopMargin: CGFloat?
    var placeholderHeight: CGFloat?
    var placeholderSideMargin: CGFloat?
    var buttonHeight: CGFloat?
    var buttonTouchableOverlap: CGFloat?
    var buttonRightMargin: CGFloat?
    var utilityButtonWidth: CGFloat?
    var utilityButtonBottomMargin: CGFloat?
    var initialHeight: CGFloat?
    var mainFont: String?
    var charCountFont: String?
}

class CustomisationUtils { 

    func setup(customisation: Customisation, with registrar: FlutterPluginRegistrar, in settings: MMChatSettings) { 
        setNotNil(&settings.title, customisation.toolbarTitle)
        setNotNil(&settings.sendButtonTintColor, customisation.sendButtonTintColor?.toColor())
        setNotNil(&settings.navBarItemsTintColor, customisation.toolbarTintColor?.toColor())
        setNotNil(&settings.navBarColor, customisation.toolbarBackgroundColor?.toColor())
        setNotNil(&settings.navBarTitleColor, customisation.toolbarTitleColor?.toColor())
        setNotNil(&settings.backgroungColor, customisation.chatBackgroundColor?.toColor())
        setNotNil(&settings.errorLabelTextColor, customisation.noConnectionAlertTextColor?.toColor())
        setNotNil(&settings.errorLabelBackgroundColor, customisation.noConnectionAlertBackgroundColor?.toColor())
        setNotNil(&settings.advancedSettings.mainPlaceholderTextColor, customisation.chatInputPlaceholderTextColor?.toColor())
        setNotNil(&settings.advancedSettings.typingIndicatorColor, customisation.chatInputCursorColor?.toColor())
        setNotNil(&settings.attachmentPreviewBarsColor, customisation.ios?.attachmentPreviewBarsColor?.toColor())
        setNotNil(&settings.attachmentPreviewItemsColor, customisation.ios?.attachmentPreviewItemsColor?.toColor())
        
        setNotNil(&settings.advancedSettings.sendButtonIcon, getImage(with: customisation.sendButtonIcon, with: registrar))
        setNotNil(&settings.advancedSettings.attachmentButtonIcon, getImage(with: customisation.attachmentButtonIcon, with: registrar))
        
        if let chatInputSeparatorVisible = customisation.chatInputSeparatorVisible {
            settings.advancedSettings.isLineSeparatorHidden = !chatInputSeparatorVisible
        }
        
        setNotNil(&settings.advancedSettings.textContainerTopMargin, customisation.ios?.textContainerTopMargin)
        setNotNil(&settings.advancedSettings.textContainerLeftPadding, customisation.ios?.textContainerLeftPadding)
        setNotNil(&settings.advancedSettings.textContainerCornerRadius, customisation.ios?.textContainerCornerRadius)
        setNotNil(&settings.advancedSettings.textViewTopMargin, customisation.ios?.textViewTopMargin)
        setNotNil(&settings.advancedSettings.placeholderHeight, customisation.ios?.placeholderHeight)
        setNotNil(&settings.advancedSettings.placeholderSideMargin, customisation.ios?.placeholderSideMargin)
        setNotNil(&settings.advancedSettings.buttonHeight, customisation.ios?.buttonHeight)
        setNotNil(&settings.advancedSettings.buttonTouchableOverlap, customisation.ios?.buttonTouchableOverlap)
        setNotNil(&settings.advancedSettings.buttonRightMargin, customisation.ios?.buttonRightMargin)
        setNotNil(&settings.advancedSettings.utilityButtonWidth, customisation.ios?.utilityButtonWidth)
        setNotNil(&settings.advancedSettings.utilityButtonBottomMargin, customisation.ios?.utilityButtonBottomMargin)
        setNotNil(&settings.advancedSettings.initialHeight, customisation.ios?.initialHeight)

        if let mainFontSize = settings.advancedSettings.mainFont?.pointSize,
           let newFontPath = customisation.ios?.mainFont,
           let font = getFont(with: newFontPath, with: registrar, size: mainFontSize) {
            settings.advancedSettings.mainFont = font
        }
 
        if let mainFontSize = settings.advancedSettings.charCountFont?.pointSize,
           let newFontPath = customisation.ios?.charCountFont,
           let font = getFont(with: newFontPath, with: registrar, size: mainFontSize) {
            settings.advancedSettings.charCountFont = font
        }
    }

    func getImage(with name: String?, with registrar: FlutterPluginRegistrar) -> UIImage? {
        guard let name = name else { return nil }
        let bundleName = registrar.lookupKey(forAsset: name)
        guard let bundlePath = Bundle.main.path(forResource: bundleName, ofType: nil) else { return nil }
        return UIImage(named: bundlePath)
    }
    
    func getFont(with path: String?, with registrar: FlutterPluginRegistrar, size: CGFloat) -> UIFont? {
        guard let path = path else { return nil }
        let fontKey = registrar.lookupKey(forAsset: path)
        guard let bundlePath = Bundle.main.path(forResource: fontKey, ofType: nil) else { return nil }
        
        guard let data = NSData(contentsOfFile: bundlePath) else { return nil }
        guard let dataProvider = CGDataProvider(data: data) else { return nil }
        guard let fontReference = CGFont(dataProvider) else { return nil }
        
        guard let fontName = URL(string: path)?.deletingPathExtension().lastPathComponent else { return nil }
        
        var errorReference: Unmanaged<CFError>?
        CTFontManagerRegisterGraphicsFont(fontReference, &errorReference)
        return UIFont(name: fontName, size: size)
    }

    func setNotNil<T>(_ forVariable: inout T, _ value:T?) {
        if let value = value { forVariable = value }
    }
}
