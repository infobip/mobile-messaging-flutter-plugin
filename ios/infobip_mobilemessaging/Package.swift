// swift-tools-version: 5.9
// The swift-tools-version declares the minimum version of Swift required to build this package.
//

import PackageDescription

let mmSdkVersion: Version = "15.7.1"

let webRTCUIEnabled = ["1", "true"].contains(
    (Context.environment["INFOBIP_WEBRTCUI_ENABLED"] ?? "").lowercased()
)

var targetDependencies: [Target.Dependency] = [
    .product(name: "FlutterFramework", package: "FlutterFramework"),
    .product(name: "MobileMessaging", package: "mobile-messaging-sdk-ios"),
    .product(name: "MobileMessagingInbox", package: "mobile-messaging-sdk-ios"),
    .product(name: "InAppChat", package: "mobile-messaging-sdk-ios"),
]

var targetSwiftSettings: [SwiftSetting] = []

if webRTCUIEnabled {
    targetDependencies.append(.product(name: "WebRTCUI", package: "mobile-messaging-sdk-ios"))
    targetSwiftSettings.append(.define("WEBRTCUI_ENABLED"))
}

let package = Package(
    name: "infobip_mobilemessaging",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(name: "infobip-mobilemessaging", targets: ["infobip_mobilemessaging"])
    ],
    dependencies: [
        .package(name: "FlutterFramework", path: "../FlutterFramework"),
        .package(url: "https://github.com/infobip/mobile-messaging-sdk-ios", exact: mmSdkVersion),
    ],
    targets: [
        .target(
            name: "infobip_mobilemessaging",
            dependencies: targetDependencies,
            resources: [],
            swiftSettings: targetSwiftSettings
        )
    ]
)
