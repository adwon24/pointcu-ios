# PointCU iOS SDK

ADWON POINT4U 포켓CU 어플리케이션용 iOS SDK입니다.  
Swift Package Manager(SPM)를 통해 배포되며, UIKit / SwiftUI 모두 지원합니다.

---

## 릴리즈 내역

| 버전 | 날짜 | 내용 |
|---|---|---|
| 0.0.5 | 2026.05.22 | 마이너 업데이트 |
| 0.0.4 | 2026.05.21 | 광고 delegate 추가 및 수정 |
| 0.0.3 | 2026.05.20 | 마이너 업데이트 |
| 0.0.2 | 2026.05.19 | 마이너 업데이트 |
| 0.0.1 | 2026.05.19 | 테스트 버전 출시 |

---

## 지원 환경

| 항목 | 내용 |
|---|---|
| 최소 iOS 버전 | iOS 15.0 이상 |
| 개발 언어 | Swift 5.9+ |
| 배포 방식 | Swift Package Manager (SPM) |

---

## 샘플 프로젝트

PointCU 연동을 위한 샘플 프로젝트입니다.  
https://github.com/adwon24/pointcu-ios-sample

---

## 1. SDK 설치

### 1.1 SPM 패키지 추가

Xcode에서 아래 순서로 패키지를 추가합니다.

1. `Xcode → File → Add Package Dependencies`
2. URL 입력: `https://github.com/adwon24/pointcu-ios.git`
3. Dependency Rule: `Range of Versions  0.0.1 ..< 3.0.0`
4. Product: `PointCUSDK` → 메인 앱 타겟에 추가

**PointCUSDK에 포함된 의존성 (자동 설치):**

| 패키지 | 버전 | 용도 |
|---|---|---|
| AdPopcornSSP | 2.11.9+ | SSP 배너 광고 |
| GreenPOfferWall | 4.2.0+ | 그린P 오퍼월 |
| NStationOfferwall | 1.9.8 (고정) | NStation 오퍼월 |

### 1.2 NAMSDK 별도 설치 (필수)

NAMSDK는 SPM 미지원으로 Podfile에 별도 추가가 필요합니다.

```ruby
# Podfile
target 'YourApp' do
  pod 'NAMSDK'
end
```

### 1.3 Info.plist 설정

```xml
<!-- 모션/걸음수 측정 권한 -->
<key>NSMotionUsageDescription</key>
<string>걸음 수 측정을 위해 모션 데이터가 필요합니다.</string>

<!-- 광고 추적 권한 (ATT) -->
<key>NSUserTrackingUsageDescription</key>
<string>맞춤 광고 제공을 위해 광고 추적 허용이 필요합니다.</string>

<!-- ATS (App Transport Security) 설정 -->
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
    <key>NSExceptionDomains</key>
    <dict>
        <key>greenp.kr</key>
        <dict>
            <key>NSExceptionAllowsInsecureHTTPLoads</key>
            <true/>
            <key>NSIncludesSubdomains</key>
            <true/>
        </dict>
    </dict>
</dict>
```

### 1.4 Frameworks 추가

메인 앱 타겟에 아래 프레임워크를 추가합니다.

```
Xcode → Target → General → Frameworks, Libraries, and Embedded Content
→ + 버튼 → 아래 항목 추가
```

| Framework | 용도 |
|---|---|
| `AdSupport.framework` | 광고 ID (IDFA) 접근 |
| `AppTrackingTransparency.framework` | ATT 권한 요청 |

### 1.5 Xcode Build Settings

| 설정 항목 | 값 | 설명 |
|---|---|---|
| User Script Sandboxing | No | KissXML 빌드 오류 방지 (필수) |

---

## 2. NAMAdapter 설정

NAMSDK와 AdPopcornSSP를 연동하기 위한 NAMAdapter 파일이 필요합니다.  
아래 파일들을 프로젝트에 추가해야 합니다.

### 2.1 필요 파일

| 파일 | 설명 |
|---|---|
| `NAMAdapter.h` | NAMAdapter 헤더 파일 |
| `NAMAdapter.m` | NAMAdapter 구현 파일 |
| `GFPNativeSimpleAdView.xib` | NAM 네이티브 광고 뷰 레이아웃 |
| `{YourApp}-Bridging-Header.h` | Swift ↔ Objective-C 브릿지 헤더 |

> ※ 위 파일들은 이 저장소의 `NAMAdapter/` 폴더에 포함되어 있습니다.

### 2.2 프로젝트에 추가하는 방법

1. 위 4개 파일을 Xcode 프로젝트에 드래그하여 추가합니다.
2. `Build Settings → Swift Compiler - General → Objective-C Bridging Header`에 브릿지 헤더 경로를 설정합니다.

```
{YourApp}/{YourApp}-Bridging-Header.h
```

### 2.3 Bridging Header 내용

```objc
//  {YourApp}-Bridging-Header.h
#import "NAMAdapter.h"
```

### 2.4 NAMAdapter keyWindow 수정

NAMAdapter.m의 `getSafeBottomAreaHeight` 메서드는 iOS 13 이상에서 deprecated된 `keyWindow` 대신 아래와 같이 수정되어 있습니다.

```objc
- (CGFloat)getSafeBottomAreaHeight
{
    for (UIWindowScene *scene in [UIApplication sharedApplication].connectedScenes) {
        if (scene.activationState == UISceneActivationStateForegroundActive) {
            return scene.windows.firstObject.safeAreaInsets.bottom;
        }
    }
    return 0;
}
```

## 3. SDK 초기화

### AppDelegate 설정 (NAMSDK)

AppDelegate에서 `GFPAdManagerDelegate`를 구현하고 NAMSDK를 초기화합니다.  
`@objc` 키워드가 **반드시** 필요합니다.

```swift
import NAMSDK
import AppTrackingTransparency

class AppDelegate: UIResponder, UIApplicationDelegate, GFPAdManagerDelegate {

    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // NAMSDK 초기화
        let configuration = GFPAdConfiguration()
        DispatchQueue.main.async {
            GFPAdManager.setup(
                withPublisherCd: "N256497692", // ADWON PUBLISHER CD
                target: self, 
                configuration: configuration
            ) { error in
                if let error = error {
                    // NAM SDK 초기화 실패
                }
            }
        }

        return true
    }

    // GFPAdManagerDelegate 필수 구현 — @objc 반드시 필요
    @objc func attStatus() -> GFPATTAuthorizationStatus {
        let status = ATTrackingManager.trackingAuthorizationStatus
        return GFPATTAuthorizationStatus(rawValue: UInt(status.rawValue)) ?? .notDetermined
    }
}
```

> ※ ATT 권한 요청은 SDK 진입 시 모션 권한 획득 후 자동으로 순차 처리됩니다.  

---

## 4. SDK 메인 화면 실행

### 파라미터

| 파라미터 | 타입 | 필수 | 설명 |
|---|---|---|---|
| userId | String | 필수 | 앱 재설치 후에도 동일한 ID 유지 필요 |
| birth | String? | 필수* | 생년월일 (yyyy-MM-dd 또는 yyyyMMdd) |
| age | Int? | 필수* | 나이 — birth 미입력 시 사용 |
| gender | PointCUGender | 필수 | `.male` / `.female` / `.unknown` |
| finishDelegate | PointCUFinishDelegate? | 선택 | 재고조회 이동 이벤트 수신 |

> ※ `birth` 또는 `age` 중 하나는 반드시 입력해야 합니다.  
> ※ `birth` 입력 시 `age`는 자동 계산됩니다.  
> ※ `birth` 형식: `yyyy-MM-dd` 또는 `yyyyMMdd` 허용 (예: `"1990-01-01"` 또는 `"19900101"`)

### UIKit (UIViewController)

```swift
import PointCUSDK

let vc = PointCUSDK.makeMainViewController(
    userId:         "user_id_here",
    birth:          "1990-01-01",   // 또는 age: 35 (둘 중 하나 필수)
    gender:         .male,
    finishDelegate: self            // 재고조회 이동 처리 시
)
vc.modalPresentationStyle = .fullScreen
present(vc, animated: true)
```

### SwiftUI (View)

```swift
import PointCUSDK

let sdkView = PointCUSDK.makeMainView(
    userId:  "user_id_here",
    birth:   "1990-01-01",   // 또는 age: 35 (둘 중 하나 필수)
    gender:  .female
)

.fullScreenCover(isPresented: $showSDK) {
    sdkView
}
```

---

## 5. 콜백 (Delegate)

### PointCUFinishDelegate

재고조회 버튼 클릭 시 SDK가 dismiss된 후 호출됩니다.

```swift
extension YourViewController: PointCUFinishDelegate {
    func onMoveInventory() {
        // SDK가 이미 dismiss된 상태
        let inventoryVC = InventoryViewController()
        navigationController?.pushViewController(inventoryVC, animated: true)
    }
}
```

### PointCUGameDelegate

| 메서드 | 설명 |
|---|---|
| `onGameLoadFail(error: PointCUError)` | 게임 화면 구성 또는 광고 노출 오류 시 호출 |
| `onGameComplete(winPoint: Int)` | 게임 이벤트 처리 후 포인트 확인 시 호출 |
| `onGameClose()` | 모든 게임 화면 종료 시 호출 |

### PointCUAdDelegate

| 메서드 | 호출 시점 |
|---|---|
| `onAdShow(type:)` | 광고가 화면에 표시될 때 |
| `onAdFail(type:error:)` | 모든 광고 로드 실패 시 |
| `onAdClose(type:)` | 광고 팝업 닫힘 시 |
| `onAdEarned(type:)` | 광고 페이지 5초 이상 체류 시 |
| `onAdClick(type:)` | 광고 클릭 시 |

---

## 6. 주요 기능 API

### 게임 단독 실행

SDK 메인 화면 없이 게임만 단독으로 실행합니다.  
`makeMainViewController` 호출 이력이 없는 미등록 사용자는 사용할 수 없습니다.

```swift
// 룰렛 게임
PointCUSDK.startGameRoulette(delegate: self)

// 복권 게임
PointCUSDK.startGameLottery(delegate: self)
```

> ※ `isRegistered()`로 등록 여부를 사전 확인 후 실행하는 것을 권장합니다.

### CU 자체 광고 노출

| 타입 | 설명 |
|---|---|
| `.eat` | 오늘 뭐먹지 |
| `.inventory` | 재고 조회 |
| `.newProduct` | 신상품 |
| `.preOrder` | 예약 구매 |

```swift
// delegate 방식 (권장)
PointCUSDK.startPoint4uAdvertise(
    type:     .eat,
    delegate: self   // PointCUAdDelegate
)

// 클로저 방식 (delegate 미사용 시)
PointCUSDK.startPoint4uAdvertise(
    type:       .eat,
    onComplete: { print("완료") },
    onFail:     { print("실패") }
)
```

```swift
// PointCUAdDelegate 구현
extension YourViewController: PointCUAdDelegate {
    func onAdShow(type: Point4uAd?) { 
        // 광고 로드 완료
    }
    func onAdFail(type: Point4uAd?, error: PointCUError) {
        // 모든 광고 로드 실패
    }
    func onAdClose(type: Point4uAd?) { 
        // 광고 팝업 닫힘
    }
    func onAdEarned(type: Point4uAd?) {
        // 5초 이상 체류 완료
    }
    func onAdClick(type: Point4uAd?) { 
        // 광고 배너 클릭
    }
}
```

### 사용자 등록 여부 확인

```swift
// true: 등록된 사용자, false: 미등록 사용자
if PointCUSDK.isRegistered() {
    // 게임 또는 광고 실행
}
```

### 사용자 데이터 삭제

SDK 내부에서 보관 중인 사용자 데이터(토큰, userId, 걸음 기록 등)를 삭제합니다.  
**메인앱의 데이터에는 영향을 주지 않습니다.**  
메인앱에서 로그아웃 또는 계정 전환 시 호출합니다.

```swift
// SDK가 보관 중인 사용자 데이터만 삭제 (메인앱 데이터 무관)
PointCUSDK.clearUserData()
```

---

## 7. 타입 정의

### PointCUGender

| 값 | 서버 전송값 | 설명 |
|---|---|---|
| `.male` | `"1"` | 남성 |
| `.female` | `"0"` | 여성 |
| `.unknown` | `""` | 미지정 |

### Point4uAd

| 값 | 설명 |
|---|---|
| `.eat` | CU 광고 - 오늘 뭐먹지 |
| `.inventory` | CU 광고 - 재고 조회 |
| `.newProduct` | CU 광고 - 신상품 |
| `.preOrder` | CU 광고 - 예약 구매 |

---

## 8. 에러 코드

| 코드 | 값 | 설명 |
|---|---|---|
| `invalidBirthFormat` | 1002 | birth 형식 오류 — yyyy-MM-dd 또는 yyyyMMdd만 허용 |
| `missingRequiredField` | 1003 | 필수 항목 누락 (userId, birth/age, gender) |
| `notInitialized` | 1004 | SDK 초기화 전 함수 호출 |
| `notRegistered` | 1005 | 미등록 사용자 |
| `noAdAvailable` | 2001 | 광고 없음 |
| `unknown` | 9999 | 알 수 없는 오류 |

---

## 9. 주의사항

- SDK 메인 화면은 `fullScreen` 방식으로 present 합니다.
- `NAMAdapter.h`, `NAMAdapter.m`, `GFPNativeSimpleAdView.xib`를 반드시 프로젝트에 추가해야 합니다.
- Bridging Header에 `#import "NAMAdapter.h"`를 추가해야 합니다.
- `userId`는 포켓CU 사용자 아이디 값입니다.
- `birth` 또는 `age` 중 하나는 반드시 입력해야 합니다.
- ATT 권한 요청은 SDK 진입 시 모션 권한 획득 후 자동으로 순차 처리됩니다. 메인앱에서 별도 요청이 불필요합니다.
- `User Script Sandboxing`을 `No`로 설정하지 않으면 KissXML 관련 빌드 오류가 발생합니다.
- `clearUserData()` 호출 시 SDK가 보관 중인 사용자 데이터(토큰, userId, 걸음 기록 등)만 삭제됩니다. 메인앱의 데이터에는 영향을 주지 않습니다.
- 미등록 사용자(`isRegistered() = false`)는 게임 및 광고 기능을 사용할 수 없습니다.

---

## 문의

SDK 연동 관련 문의: point4udevelop@adwon.co
