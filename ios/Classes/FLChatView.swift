//
//  FLChatView.swift
//  infobip_mobilemessaging
//
//  Created by Maksym Svitlovskyi on 16/07/2024.
//  Copyright © 2024 Infobip Ltd. All rights reserved.
//

import UIKit
import Flutter
import MobileMessaging

enum Constants {
    static let resultSuccess = "success"
}

enum ChatErrors {
    case languageCodeDataMissing,
    contextualDataMissing,
    unableToMoveToThreadList,
    unableToSetWidgetTheme,
    attachmentDataInvalid,
    messageOrAttachmentDataMissing,
    draftIsMissing,
    unableToSetExceptionHandler
    
    
    var code: String {
        return "CHAT_VIEW_ERROR"
    }
    
    var message: String {
        switch self {
        case .languageCodeDataMissing:
            "Cannot set ChatView language. Language is null or empty."
        case .contextualDataMissing:
            "Cannot send contextual data. Data or allMultiThreadStrategy is missing."
        case .unableToMoveToThreadList:
            "Cannot show thread list, because view is already in thread list"
        case .unableToSetWidgetTheme:
            "Cannot set ChatView widget theme. Widget theme is null or empty."
        case .attachmentDataInvalid:
            "Cannot send ChatView message. Attachment data is invalid or corrupted."
        case .messageOrAttachmentDataMissing:
            "Cannot send ChatView message. Message or attachment data is missing."
        case .draftIsMissing:
            "Cannot send ChatView draft. Draft is null or empty."
        case .unableToSetExceptionHandler:
            "Cannot set Chat exception handler: chat is not enabled"
        }
    }
}

extension FlutterError {
    convenience init(error: ChatErrors, details: Any? = nil) {
        self.init(code: error.code, message: error.message, details: details)
    }
}

public class FLNativeViewFactory: NSObject, FlutterPlatformViewFactory {
    private var messenger: FlutterBinaryMessenger

    public init(messenger: FlutterBinaryMessenger) {
        self.messenger = messenger
        super.init()
    }

    public func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return FLChatView(
            frame: frame,
            viewIdentifier: viewId,
            arguments: args,
            binaryMessenger: messenger)
    }

    /// Implementing this method is only necessary when the `arguments` in `createWithFrame` is not `nil`.
    public func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
          return FlutterStandardMessageCodec.sharedInstance()
    }
}

internal class EmptyComposer: UIView, MMChatComposer {
    var delegate: MMComposeBarDelegate?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        backgroundColor = .red
    }
}

public class FLChatView: NSObject, FlutterPlatformView {
    private var _view: UIView
    private let _vc: MMChatViewController
    private var _rootVC: MMChatNavigationVC?
    private var _methodChannel: FlutterMethodChannel
    private var _eventChannel: FlutterEventChannel
    private var streamHandler = ChatMobileMessagingEventsManager()

    public init(
        frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?,
        binaryMessenger messenger: FlutterBinaryMessenger
    ) {
        let args = args as? [String: Any]
        let withInput = (args?["withInput"] as? Bool) ?? true
        let withToolbar = (args?["withToolbar"] as? Bool) ?? true

        if withToolbar == false {
            let vc: MMChatViewController = {
                if withInput {
                    return MMChatViewController.makeModalViewController()
                } else {
                    return MMChatViewController.makeCustomViewController(with: EmptyComposer(frame: .zero))
                }
            }()
            self._vc = vc
            _view = vc.view
        } else {
            let navController: MMChatNavigationVC = {
                if withInput {
                    return MMChatViewController.makeRootNavigationViewController()
                } else {
                    return MMChatViewController.makeRootNavigationViewController(with: EmptyComposer(frame: .zero), customTransitionDelegate: false)
                }
            }()
            let chatVC = navController.topViewController! as! MMChatViewController

            self._vc = chatVC
            self._view = navController.view
            self._rootVC = navController
        }
        _methodChannel = FlutterMethodChannel(name: "infobip_mobilemessaging/flutter_chat_view_\(viewId)", binaryMessenger: messenger)
        _eventChannel = FlutterEventChannel(name: "infobip_mobilemessaging/flutter_chat_view_\(viewId)/events", binaryMessenger: messenger)
        _eventChannel.setStreamHandler(streamHandler)
        
        
        super.init()

        _methodChannel.setMethodCallHandler { [weak self] (call, result) in
            self?.onMethodCall(call: call, result: result)
        }
        streamHandler.startObserving()
    }
        
    public func view() -> UIView {
        return _view
    }

    func onMethodCall(call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "setLanguage":
            setLanguage(call: call, result: result)
        case "sendContextualData":
            sendContextualData(call: call, result: result)
        case "showThreadsList":
            showThreadList(call: call, result: result)
        case "setWidgetTheme":
            setWidgetTheme(call: call, result: result)
        case "sendChatMessage":
            sendChatMessage(call: call, result: result)
        case "setExceptionHandler":
            setExceptionHandler(call: call, result: result)
        case "isMultithread":
            isMultithread(call: call, result: result)
            
        default:
            result(FlutterMethodNotImplemented)
        }
    }

    private func setLanguage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let language = call.arguments as? String, !language.isEmpty {
            _vc.setLanguage(MMLanguage.mapLanguage(from: language)) { error in
                if let error = error {
                    result(FlutterError(code: String(error.code), message: error.description, details: error))
                    return
                }
                result(Constants.resultSuccess)
            }
        } else {
            result(FlutterError(error: .languageCodeDataMissing))
        }
    }
    
    private func sendContextualData(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any],
           let data = args["data"] as? String, !data.isEmpty,
           let allMultiThreadStrategy = args["allMultiThreadStrategy"] as? Bool {
            _vc.sendContextualData(data, multiThreadStrategy: allMultiThreadStrategy ? .ALL : .ACTIVE) { error in
                if let error = error {
                    result(FlutterError(code: String(error.code), message: error.description, details: error))
                    return
                }
                result(Constants.resultSuccess)
            }
        } else {
            result(FlutterError(error: .contextualDataMissing))
        }
    }
    
    private func showThreadList(call: FlutterMethodCall, result: @escaping FlutterResult) {
        let showedMultithread = !_vc.onCustomBackPressed()
        if showedMultithread {
            result(Constants.resultSuccess)
        } else {
            result(FlutterError(error: .unableToMoveToThreadList))
        }
    }
    
    private func setWidgetTheme(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let widgetTheme = call.arguments as? String, !widgetTheme.isEmpty {
            _vc.setWidgetTheme(widgetTheme) { error in
                if let error = error {
                    result(FlutterError(code: String(error.code), message: error.description, details: error))
                    return
                }
                result(Constants.resultSuccess)
            }
        } else {
            result(FlutterError(error: .unableToSetWidgetTheme))
        }
    }
    
    
    private func sendChatMessage(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let args = call.arguments as? [String: Any] {
            if let message = args["message"] as? String {
                _vc.send(message.livechatBasicPayload) { error in
                    if let error = error {
                        result(FlutterError(code: String(error.code), message: error.description, details: error))
                        return
                    }
                    result(Constants.resultSuccess)
                }
            } else if let dataBase64 = args["dataBase64"] as? String,
                let mimeType = args["mimeType"] as? String,
                let fileName = args["fileName"] as? String {
                
                guard let base64WithoutPrefix = dataBase64.split(separator: ",").last,
                      let data = Data(base64Encoded: String(base64WithoutPrefix))
                else {
                    result(FlutterError(error: .attachmentDataInvalid))
                    return
                }
                
                _vc.send(MMLivechatBasicPayload(fileName: "\(fileName).\(mimeType)", data: data)) { error in
                    if let error = error {
                        result(FlutterError(code: String(error.code), message: error.description, details: error))
                        return
                    }
                    result(Constants.resultSuccess)
                }
            } else {
                result(FlutterError(error: .messageOrAttachmentDataMissing))
            }
        } else {
            result(FlutterError(error: .messageOrAttachmentDataMissing))
        }
    }
    
    private func sendChatMessageDraft(call: FlutterMethodCall, result: @escaping FlutterResult) {
        if let draft = call.arguments as? String, !draft.isEmpty {
            _vc.send(draft.livechatDraftPayload) { error in
                if let error = error {
                    result(FlutterError(code: String(error.code), message: error.description, details: error))
                    return
                }
                result(Constants.resultSuccess)
            }
        } else {
            result(FlutterError(error: .draftIsMissing))
        }
    }
    
    private func isMultithread(call: FlutterMethodCall, result: @escaping FlutterResult) {
        result(_vc.isChattingInMultithread)
    }
    
    func setExceptionHandler(call: FlutterMethodCall, result: @escaping FlutterResult) {
        return SwiftInfobipMobilemessagingPlugin.digestChatExceptionHandler(call, result)
    }
}
