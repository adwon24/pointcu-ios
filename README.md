# PointCU iOS SDK

ADWON POINT4U 포켓CU 어플리케이션용 iOS SDK입니다.  
Swift Package Manager(SPM)를 통해 배포되며, UIKit / SwiftUI 모두 지원합니다.

---

## 릴리즈 내역

| 버전 | 날짜 | 내용 |
|---|---|---|
| 0.3.0 | 2026.06.04 | 광고 뷰 단독 제공 API 추가 (makeAdViewController), 서버 환경 상용 추가 등 |
| 0.2.0 | 2026.06.01 | 배포 오류 수정 |
| 0.1.9 | 2026.06.01 | 그린피, 나스미디어 연동 아이디 수정 처리 |
| 0.1.8 | 2026.05.30 | 공지 팝업 처리 수정 |
| 0.1.7 | 2026.05.30 | 공지 및 점검 안내 팝업 처리 추가 |
| 0.1.6 | 2026.05.29 | 걸음수 연동 API 추가 |
| 0.1.5 | 2026.05.28 | TEST SERVER 적용 처리 버그 수정 |
| 0.1.4 | 2026.05.27 | 신규 TEST SERVER 적용 가능 처리 |
| 0.1.3 | 2026.05.27 | 걸음수 관련 버그 수정 |
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

---

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
                withPublisherCd: "N256497692",
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

### UIKit (UIViewController)

```swift
import PointCUSDK

let vc = PointCUSDK.makeMainViewController(
    userId:         "user_id_here",
    birth:          "1990-01-01",   // 또는 age: 35 (둘 중 하나 필수)
    gender:         .male,
    finishDelegate: self
)
vc.modalPresentationStyle = .fullScreen
present(vc, animated: true)
```

### SwiftUI (View)

```swift
import PointCUSDK

let sdkView = PointCUSDK.makeMainView(
    userId:  "user_id_here",
    birth:   "1990-01-01",
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

`startPoint4uAdvertise` 사용 시 콜백입니다.

| 메서드 | 호출 시점 |
|---|---|
| `onAdShow(type:)` | 광고가 화면에 표시될 때 |
| `onAdFail(type:error:)` | 모든 광고 로드 실패 시 |
| `onAdClose(type:)` | 광고 팝업 닫힘 시 |
| `onAdEarned(type:)` | 광고 페이지 5초 이상 체류 시 |
| `onAdClick(type:)` | 광고 클릭 시 |

### PointCUAdViewDelegate

`makeAdViewController` 사용 시 콜백입니다.

| 메서드 | 호출 시점 |
|---|---|
| `onAdLoaded()` | 광고 로드 성공 시 |
| `onAdFailed(error:)` | 모든 광고 로드 실패 시 |
| `onAdClicked()` | 광고 클릭 — Safari로 이동 |
| `onAdEarned()` | 광고 페이지 5초 이상 체류 시 |
| `onAdReturned()` | 5초 미만 복귀 |

> ※ 닫기 버튼 등 컨테이너 UI 동작은 메인앱에서 직접 처리합니다.

---

## 6. 주요 기능 API

### 게임 단독 실행

```swift
PointCUSDK.startGameRoulette(delegate: self)
PointCUSDK.startGameLottery(delegate: self)
```

### 걸음 수 확인

```swift
PointCUSDK.getStepCount { steps in
    if steps == -1 {
        // 모션 권한 없음
    } else {
        print("오늘 걸음수: \(steps)보")
    }
}
```

### CU 자체 광고 — 팝업 방식 (startPoint4uAdvertise)

SDK 내부에서 팝업을 직접 표시합니다.

```swift
PointCUSDK.startPoint4uAdvertise(
    type:     .eat,
    delegate: self   // PointCUAdDelegate
)
```

### CU 자체 광고 — 뷰 단독 제공 방식 (makeAdViewController)

SDK는 **300×250 광고 뷰만** 제공하며, 테두리·닫기 버튼 등 컨테이너 UI는 메인앱에서 직접 구성합니다.  
재고조회 / 신상품 / 예약구매에 사용합니다.

```swift
let adVC = PointCUSDK.makeAdViewController(
    type:     .inventory,                        // 광고 타입
    adSize:   CGSize(width: 300, height: 250),   // 생략 시 300×250 기본값
    delegate: self                               // PointCUAdViewDelegate
)
```

**사용 방식 3가지 예시:**

#### 방식 1: addChild (권장 — 커스텀 팝업)

메인앱에서 원하는 팝업 UI를 구성하고 SDK 광고 뷰를 내부에 삽입합니다.

```swift
// 컨테이너 ViewController에서
let adVC = PointCUSDK.makeAdViewController(type: .inventory, delegate: self)
addChild(adVC)
adVC.view.translatesAutoresizingMaskIntoConstraints = false
myContainerView.addSubview(adVC.view)
NSLayoutConstraint.activate([
    adVC.view.topAnchor.constraint(equalTo: myContainerView.topAnchor),
    adVC.view.bottomAnchor.constraint(equalTo: myContainerView.bottomAnchor),
    adVC.view.leadingAnchor.constraint(equalTo: myContainerView.leadingAnchor),
    adVC.view.trailingAnchor.constraint(equalTo: myContainerView.trailingAnchor),
])
adVC.didMove(toParent: self)
```

> ※ addChild는 `viewDidAppear` 이후에 호출해야 광고 로드가 정상 동작합니다.

#### 방식 2: present (pageSheet)

시트 형태로 간단하게 표시합니다.

```swift
let adVC = PointCUSDK.makeAdViewController(type: .newProduct, delegate: self)
adVC.modalPresentationStyle = .pageSheet
if let sheet = adVC.sheetPresentationController {
    sheet.detents = [.medium()]
    sheet.prefersGrabberVisible = true
}
present(adVC, animated: true)
```

#### 방식 3: UIView 직접 삽입 (인라인)

현재 화면 뷰 계층에 직접 삽입합니다.

```swift
let adVC = PointCUSDK.makeAdViewController(type: .preOrder, delegate: self)
addChild(adVC)
let adView = adVC.view!
adView.translatesAutoresizingMaskIntoConstraints = false
view.addSubview(adView)
NSLayoutConstraint.activate([
    adView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
    adView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
    adView.widthAnchor.constraint(equalToConstant: 300),
    adView.heightAnchor.constraint(equalToConstant: 250),
])
adVC.didMove(toParent: self)
```

**PointCUAdViewDelegate 구현:**

```swift
extension YourViewController: PointCUAdViewDelegate {
    func onAdLoaded() {
        // 광고 로드 성공 — 인디케이터 자동 제거됨
    }
    func onAdFailed(error: PointCUError) {
        // 모든 광고 로드 실패 — 컨테이너 닫기 처리
    }
    func onAdClicked() {
        // 광고 클릭 — Safari로 이동
    }
    func onAdEarned() {
        // Safari 5초 이상 체류 후 복귀 — 리워드 지급 처리
    }
    func onAdDismissed() {
        // Safari 5초 미만 복귀
    }
}
```

### 서버 환경 설정

```swift
// STG / AWS / 상용
PointCUSDK.setServerType(.stg)   // 개발 서버 1
PointCUSDK.setServerType(.aws)   // 개발 서버 2 (기본값)
PointCUSDK.setServerType(.prod)  // 상용 서버
```

### 사용자 등록 여부 확인

```swift
if PointCUSDK.isRegistered() {
    // 게임 또는 광고 실행
}
```

### 사용자 데이터 삭제

```swift
PointCUSDK.clearUserData()
```

---

## 7. 타입 정의

### PointCUGender

| 값 | 설명 |
|---|---|
| `.male` | 남성 |
| `.female` | 여성 |
| `.unknown` | 미지정 |

### Point4uAd

| 값 | 설명 | startPoint4uAdvertise | makeAdViewController |
|---|---|---|---|
| `.eat` | CU 광고 - 오늘 뭐먹지 | ✅ | ❌ |
| `.inventory` | CU 광고 - 재고 조회 | ✅ | ✅ |
| `.newProduct` | CU 광고 - 신상품 | ✅ | ✅ |
| `.preOrder` | CU 광고 - 예약 구매 | ✅ | ✅ |

### PointCUServerType

| 값 | 서버 | 설명 |
|---|---|---|
| `.stg` | https://stg.api.point4u.co.kr | 개발 서버 1 |
| `.aws` | https://aws.api.point4u.co.kr | 개발 서버 2 (기본값) |
| `.prod` | https://api.point4u.co.kr | 상용 서버 |

---

## 8. 에러 코드

| 코드 | 값 | 설명 |
|---|---|---|
| `invalidBirthFormat` | 1002 | birth 형식 오류 |
| `missingRequiredField` | 1003 | 필수 항목 누락 |
| `notInitialized` | 1004 | SDK 초기화 전 함수 호출 |
| `notRegistered` | 1005 | 미등록 사용자 |
| `noAdAvailable` | 2001 | 광고 없음 |
| `unknown` | 9999 | 알 수 없는 오류 |

---

## 9. 주의사항

- SDK 메인 화면은 `fullScreen` 방식으로 present 합니다.
- `makeAdViewController`의 `addChild`는 반드시 `viewDidAppear` 이후에 호출해야 합니다.
- `makeAdViewController`로 제공되는 광고 뷰의 내부 광고 소재 UI는 SDK에서 제어합니다. 컨테이너는 메인앱에서 자유롭게 구성할 수 있습니다.
- ATT 권한 요청은 SDK 진입 시 자동 처리됩니다. 메인앱에서 별도 요청이 불필요합니다.
- `clearUserData()` 호출 시 SDK가 보관 중인 사용자 데이터만 삭제됩니다. 메인앱 데이터에는 영향을 주지 않습니다.
- `User Script Sandboxing`을 `No`로 설정하지 않으면 KissXML 관련 빌드 오류가 발생합니다.

---

## 문의

SDK 연동 관련 문의: point4udevelop@adwon.co