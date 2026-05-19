// swift-tools-version: 5.9
// PointCU iOS SDK — Swift Package Manager 바이너리 배포
//
// 설치: File → Add Package Dependencies
//       https://github.com/adwon24/pointcu-ios
//
// ※ NAMSDK(GFPSDK)는 SPM 미지원 — 메인 앱 Podfile에 별도 추가 필요
//   pod 'NAMSDK'

import PackageDescription

let package = Package(
    name: "PointCU",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "PointCUSDK",
            targets: ["PointCUSDK"]
        )
    ],
    dependencies: [
        // AdPopcornSSP
        .package(
            url: "https://github.com/IGAWorksDev/ap-ssp-sdk-ios-spm-objc",
            from: "2.11.9"
        ),
        // GreenP Offerwall
        .package(
            url: "https://github.com/rnd-adforus/greenpofferwall-ios-sdk-spm",
            from: "4.2.0"
        ),
        // NStation Offerwall — 1.9.8 고정
        .package(
            url: "https://github.com/Nasmedia-Tech/iOS-RWD-SPM",
            .exact("1.9.8")
        ),
    ],
    targets: [
        // PointCU XCFramework 바이너리 — 로컬 경로
        .binaryTarget(
            name: "PointCUSDKBinary",
            path: "xcframework/PointCUSDK.xcframework"
        ),
        // 래퍼 타겟 — PointCU 바이너리 + 의존성을 하나로 묶어 메인 앱에 제공
        .target(
            name: "PointCUSDK",
            dependencies: [
                "PointCUSDKBinary",
                .product(name: "AdPopcornSSPSDK",  package: "ap-ssp-sdk-ios-spm-objc"),
                .product(name: "GreenPOfferWall",   package: "GreenPOfferwall_iOS_Sample"),
                .product(name: "NStationOfferwall", package: "iOS-RWD-SPM"),
            ],
            path: "Sources/PointCUSDK"
        )
    ]
)