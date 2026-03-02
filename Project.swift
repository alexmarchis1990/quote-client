import ProjectDescription

let project = Project(
    name: "QuoteApp",
    targets: [
        .target(
            name: "QuoteApp",
            destinations: .iOS,
            product: .app,
            bundleId: "com.quote.QuoteApp",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(with: [
                "UILaunchScreen": [:],
                "NSCameraUsageDescription": "Quote uses the camera to capture text from book pages.",
                "NSPhotoLibraryUsageDescription": "Quote uses the photo library to select an image for text recognition.",
                "UISupportedInterfaceOrientations": [
                    "UIInterfaceOrientationPortrait",
                ],
                "UISupportedInterfaceOrientations~ipad": [
                    "UIInterfaceOrientationPortrait",
                    "UIInterfaceOrientationPortraitUpsideDown",
                    "UIInterfaceOrientationLandscapeLeft",
                    "UIInterfaceOrientationLandscapeRight",
                ],
            ]),
            sources: ["QuoteApp/**/*.swift"],
            resources: ["QuoteApp/Assets.xcassets"],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "MARKETING_VERSION": "1.0",
                    "CURRENT_PROJECT_VERSION": "1",
                    "ASSETCATALOG_COMPILER_APPICON_NAME": "AppIcon",
                    "ASSETCATALOG_COMPILER_GLOBAL_ACCENT_COLOR_NAME": "AccentColor",
                    "SWIFT_EMIT_LOC_STRINGS": "YES",
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                ]
            )
        ),
        .target(
            name: "QuoteAppTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.quote.QuoteAppTests",
            deploymentTargets: .iOS("17.0"),
            sources: ["QuoteAppTests/**/*.swift"],
            dependencies: [.target(name: "QuoteApp")],
            settings: .settings(
                base: [
                    "SWIFT_VERSION": "6.0",
                    "SWIFT_STRICT_CONCURRENCY": "complete",
                ]
            )
        ),
    ]
)
