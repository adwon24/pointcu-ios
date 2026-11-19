// swift-tools-version: 5.9
// PointCU iOS SDK — Swift Package Manager 바이너리 배포
//
// 설치: File → Add Package Dependencies
//       https://github.com/adwon24/pointcu-ios

import PackageDescription

let package = Package(
    name: "PointCU",
    platforms: [
        // 최초 시작부터 메인앱(포켓CU)과 동일하게 iOS 15.0을 최소 타겟으로 사용
        // .v16으로 잘못 선언되어 있던 것을 원래 값인 .v15로 수정
        // (iOS 16 전용 API를 사용하는 코드가 없음을 소스 전체 검색으로 확인)
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
        // 나스미디어 nap reward (구 NStation Offerwall)
        // v1.9.8 → v2.x 마이그레이션
        //   NStation.shared.initialize(...)   → NapRewardConfigBuilder + NapReward.initialize(config:)
        //   NStation.shared.presentNStation() → NapReward.start(from:)
        //
        // exact가 아닌 범위로 지정 — 2.0.x 패치는 받고 2.1.0 이상은 막는다.
        // (2.0.2~2.0.7이 한 달 사이에 쏟아졌고 2.0.7에 alert panel 크래시 수정이 포함됨.
        //  반면 v2는 마이너에서도 기본 동작이 바뀐 전례가 있어 2.1.0은 수동 검증 후 올린다.)
        .package(
            url: "https://github.com/Nasmedia-Tech/iOS-RWD-SPM",
            "2.0.7"..<"2.1.0"
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