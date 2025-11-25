//
//  CustomizationUtils.swift
//  MobileMessagingFlutter
//
//  Copyright (c) 2016-2025 Infobip Limited
//  Licensed under the Apache License, Version 2.0
//

import Foundation
import MobileMessaging
import Flutter
import UIKit

struct ToolbarCustomization: Decodable {
    var titleTextAppearance: String?
    var titleTextColor: String?
    var titleText: String?
    var backgroundColor: String?
    var navigationIcon: String?
    var navigationIconTint: String?
}

struct ChatCustomization: Decodable {
    var chatStatusBarBackgroundColor: String?
    var chatStatusBarIconsColorMode: String?
    var chatToolbar: ToolbarCustomization?
    var attachmentPreviewToolbar: ToolbarCustomization?
    var attachmentPreviewToolbarMenuItemsIconTint: String?
    var attachmentPreviewToolbarSaveMenuItemIcon: String?
    var chatBackgroundColor: String?
    var chatProgressBarColor: String?
    var chatInputTextAppearance: String?
    var chatInputTextColor: String?
    var chatInputBackgroundColor: String?
    var chatInputHintText: String?
    var chatInputHintTextColor: String?
    var chatInputAttachmentIcon: String?
    var chatInputAttachmentIconTint: String?
    var chatInputAttachmentBackgroundDrawable: String?
    var chatInputAttachmentBackgroundColor: String?
    var chatInputSendIcon: String?
    var chatInputSendIconTint: String?
    var chatInputSendBackgroundDrawable: String?
    var chatInputSendBackgroundColor: String?
    var chatInputSeparatorLineColor: String?
    var chatInputSeparatorLineVisible: Bool?
    var chatInputCursorColor: String?
    var networkErrorTextColor: String?
    var networkErrorLabelBackgroundColor: String?
    var shouldHandleKeyboardAppearance: Bool?
}

// Deprecated, to be replaced entirely by ChatCustomization
struct Customization: Decodable {
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
    var widgetTheme: String?
    var sendButtonIcon: String?
    var attachmentButtonIcon: String?
    var chatInputSeparatorVisible: Bool?

    var ios: IOSSpecificCustomization?
}

// Deprecated, to be replaced entirely by ChatCustomization
struct IOSSpecificCustomization: Decodable { 
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

class CustomizationUtils { 
    func setup(customization: ChatCustomization, with registrar: FlutterPluginRegistrar, in settings: MMChatSettings) {
        setNotNil(&settings.navBarColor, customization.chatToolbar?.backgroundColor?.toColor())
        setNotNil(&settings.navBarTitleColor, customization.chatToolbar?.titleTextColor?.toColor())
        setNotNil(&settings.navBarItemsTintColor, customization.chatToolbar?.navigationIconTint?.toColor()) 
        setNotNil(&settings.title, customization.chatToolbar?.titleText)
        setNotNil(&settings.attachmentPreviewBarsColor, customization.attachmentPreviewToolbar?.backgroundColor?.toColor())
        setNotNil(&settings.attachmentPreviewItemsColor, customization.attachmentPreviewToolbar?.navigationIconTint?.toColor())

        setNotNil(&settings.backgroundColor, customization.chatBackgroundColor?.toColor())
        setNotNil(&settings.advancedSettings.mainTextColor, customization.chatInputTextColor?.toColor())
        setNotNil(&settings.advancedSettings.textInputBackgroundColor, customization.chatInputBackgroundColor?.toColor())
        setNotNil(&settings.advancedSettings.attachmentButtonIcon, getImage(with: customization.chatInputAttachmentIcon, with: registrar))
        setNotNil(&settings.advancedSettings.sendButtonIcon, getImage(with: customization.chatInputSendIcon, with: registrar))
        setNotNil(&settings.sendButtonTintColor, customization.chatInputSendIconTint?.toColor())
        setNotNil(&settings.chatInputSeparatorLineColor, customization.chatInputSeparatorLineColor?.toColor())
        setNotNil(&settings.advancedSettings.isLineSeparatorHidden, customization.chatInputSeparatorLineVisible)
        setNotNil(&settings.advancedSettings.typingIndicatorColor, customization.chatInputCursorColor?.toColor())
        setNotNil(&settings.errorLabelTextColor, customization.networkErrorTextColor?.toColor())
        setNotNil(&settings.errorLabelBackgroundColor, customization.networkErrorLabelBackgroundColor?.toColor()) 
        setNotNil(&settings.advancedSettings.mainPlaceholderTextColor, customization.chatInputHintTextColor?.toColor())
        setNotNil(&settings.shouldHandleKeyboardAppearance, customization.shouldHandleKeyboardAppearance)
    }

    func setup(customization: Customization, with registrar: FlutterPluginRegistrar, in settings: MMChatSettings) {
        setNotNil(&settings.title, customization.toolbarTitle)
        setNotNil(&settings.sendButtonTintColor, customization.sendButtonTintColor?.toColor())
        setNotNil(&settings.navBarItemsTintColor, customization.toolbarTintColor?.toColor())
        setNotNil(&settings.navBarColor, customization.toolbarBackgroundColor?.toColor())
        setNotNil(&settings.navBarTitleColor, customization.toolbarTitleColor?.toColor())
        setNotNil(&settings.backgroundColor, customization.chatBackgroundColor?.toColor())
        setNotNil(&settings.widgetTheme, customization.widgetTheme)
        setNotNil(&settings.errorLabelTextColor, customization.noConnectionAlertTextColor?.toColor())
        setNotNil(&settings.errorLabelBackgroundColor, customization.noConnectionAlertBackgroundColor?.toColor())
        setNotNil(&settings.advancedSettings.mainPlaceholderTextColor, customization.chatInputPlaceholderTextColor?.toColor())
        setNotNil(&settings.advancedSettings.typingIndicatorColor, customization.chatInputCursorColor?.toColor())
        setNotNil(&settings.attachmentPreviewBarsColor, customization.ios?.attachmentPreviewBarsColor?.toColor())
        setNotNil(&settings.attachmentPreviewItemsColor, customization.ios?.attachmentPreviewItemsColor?.toColor())
        
        setNotNil(&settings.advancedSettings.sendButtonIcon, getImage(with: customization.sendButtonIcon, with: registrar))
        setNotNil(&settings.advancedSettings.attachmentButtonIcon, getImage(with: customization.attachmentButtonIcon, with: registrar))
        
        if let chatInputSeparatorVisible = customization.chatInputSeparatorVisible {
            settings.advancedSettings.isLineSeparatorHidden = !chatInputSeparatorVisible
        }
        
        setNotNil(&settings.advancedSettings.textContainerTopMargin, customization.ios?.textContainerTopMargin)
        setNotNil(&settings.advancedSettings.textContainerLeftPadding, customization.ios?.textContainerLeftPadding)
        setNotNil(&settings.advancedSettings.textContainerCornerRadius, customization.ios?.textContainerCornerRadius)
        setNotNil(&settings.advancedSettings.textViewTopMargin, customization.ios?.textViewTopMargin)
        setNotNil(&settings.advancedSettings.placeholderHeight, customization.ios?.placeholderHeight)
        setNotNil(&settings.advancedSettings.placeholderSideMargin, customization.ios?.placeholderSideMargin)
        setNotNil(&settings.advancedSettings.buttonHeight, customization.ios?.buttonHeight)
        setNotNil(&settings.advancedSettings.buttonTouchableOverlap, customization.ios?.buttonTouchableOverlap)
        setNotNil(&settings.advancedSettings.buttonRightMargin, customization.ios?.buttonRightMargin)
        setNotNil(&settings.advancedSettings.utilityButtonWidth, customization.ios?.utilityButtonWidth)
        setNotNil(&settings.advancedSettings.utilityButtonBottomMargin, customization.ios?.utilityButtonBottomMargin)
        setNotNil(&settings.advancedSettings.initialHeight, customization.ios?.initialHeight)

        if let mainFontSize = settings.advancedSettings.mainFont?.pointSize,
           let newFontPath = customization.ios?.mainFont,
           let font = getFont(with: newFontPath, with: registrar, size: mainFontSize) {
            settings.advancedSettings.mainFont = font
        }
 
        if let mainFontSize = settings.advancedSettings.charCounterFont?.pointSize,
           let newFontPath = customization.ios?.charCountFont,
           let font = getFont(with: newFontPath, with: registrar, size: mainFontSize) {
            settings.advancedSettings.charCounterFont = font
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
