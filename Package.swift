// swift-tools-version: 5.9
// PointCU iOS SDK — Swift Package Manager 바이너리 배포
//
// 설치: File → Add Package Dependencies
//       https://github.com/adwon24/pointcu-ios

import PackageDescription

let package = Package(
    name: "PointCU",
    platforms: [
        .iOS(.v15)
    ],
    products: [
        .library(
            name: "PointCUSDK",
            targets: ["PointCUSDK"]
        )
    ],
    dependencies: [
        // APSSPSDK 제거 — 메인앱이 CocoaPods으로 직접 설치
        // GreenP Offerwall
        .package(
            url: "https://github.com/rnd-adforus/greenpofferwall-ios-sdk-spm.git",
            from: "4.2.0"
        ),
        // NStation Offerwall
        .package(
            url: "https://github.com/Nasmedia-Tech/iOS-RWD-SPM",
            .exact("1.9.8")
        ),
    ],
    targets: [
        .binaryTarget(
            name: "PointCUSDKBinary",
            path: "xcframework/PointCUSDK.xcframework"
        ),
        .target(
            name: "PointCUSDK",
            dependencies: [
                "PointCUSDKBinary",
                // APSSPSDK 제거 — 메인앱이 CocoaPods으로 직접 설치
                // internal import APSSPSDK 로 변경하여 .swiftinterface 미노출
                .product(name: "GreenPOfferWall",   package: "greenpofferwall-ios-sdk-spm"),
                .product(name: "NStationOfferwall", package: "iOS-RWD-SPM"),
            ],
            path: "Sources/PointCUSDK"
        )
    ]
)