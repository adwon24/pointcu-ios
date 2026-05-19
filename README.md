# PointCU iOS SDK

CU 걷기 적립 서비스를 메인앱에 통합하기 위한 iOS SDK입니다.  
Swift Package Manager(SPM)를 통해 배포되며, UIKit / SwiftUI 모두 지원합니다.

---

## 릴리즈 내역

| 버전 | 날짜 | 내용 |
|---|---|---|
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
https://github.com/adwon24/pointCu-sample

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

### 1.3 Info.plist 권한 설정

```xml
<!-- 모션/걸음수 측정 권한 -->
<key>NSMotionUsageDescription</key>
<string>걸음 수 측정을 위해 모션 데이터가 필요합니다.</string>

<!-- 광고 추적 권한 (ATT) -->
<key>NSUserTrackingUsageDescription</key>
<string>맞춤 광고 제공을 위해 광고 추적 허용이 필요합니다.</string>
```

### 1.4 Xcode Build Settings

| 설정 항목 | 값 | 설명 |
|---|---|---|
| User Script Sandboxing | No | KissXML 빌드 오류 방지 (필수) |

---

## 2. SDK 초기화

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
        GFPAdManager.setup(withPublisherCd: "ADWON_PUBLISHER_CD", target: self)
        PointCUSDK.setNAMInitialized()
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
> ※ NAMSDK 초기화 후 반드시 `PointCUSDK.setNAMInitialized()`를 호출해야 합니다.

---

## 3. SDK 메인 화면 실행

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

## 4. 콜백 (Delegate)

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

| 메서드 | 설명 |
|---|---|
| `onAdShow(type:)` | 광고 노출 시 호출 |
| `onAdFail(type:error:)` | 광고 로딩 실패 시 호출 |
| `onAdClose(type:)` | 광고 종료 시 호출 |
| `onAdEarned(type:)` | 광고 리워드 적립 시 호출 |
| `onAdClick(type:)` | 광고 클릭 시 호출 |

---

## 5. 주요 기능 API

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
PointCUSDK.startPoint4uAdvertise(
    type:       .eat,
    delegate:   self,        // PointCUAdDelegate (선택)
    onComplete: { print("완료") },
    onFail:     { print("실패") }
)
```

### 사용자 등록 여부 확인

```swift
// true: 등록된 사용자, false: 미등록 사용자
if PointCUSDK.isRegistered() {
    // 게임 또는 광고 실행
}
```

### 사용자 데이터 삭제

로그아웃 또는 계정 전환 시 호출합니다.

```swift
// 기기 로컬에 저장된 사용자 관련 데이터 삭제
PointCUSDK.clearUserData()
```

---

## 6. 타입 정의

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

## 7. 에러 코드

| 코드 | 값 | 설명 |
|---|---|---|
| `invalidBirthFormat` | 1002 | birth 형식 오류 — yyyy-MM-dd 또는 yyyyMMdd만 허용 |
| `missingRequiredField` | 1003 | 필수 항목 누락 (userId, birth/age, gender) |
| `notInitialized` | 1004 | SDK 초기화 전 함수 호출 |
| `notRegistered` | 1005 | 미등록 사용자 |
| `noAdAvailable` | 2001 | 광고 없음 |
| `unknown` | 9999 | 알 수 없는 오류 |

---

## 8. 주의사항

- SDK 메인 화면은 `fullScreen` 방식으로 present 합니다.
- `userId`는 앱 재설치 후에도 동일한 값을 유지해야 합니다.
- `birth` 또는 `age` 중 하나는 반드시 입력해야 합니다.
- NAMSDK는 반드시 AppDelegate에서 초기화 후 `PointCUSDK.setNAMInitialized()`를 호출해야 합니다.
- ATT 권한 요청은 SDK 진입 시 모션 권한 획득 후 자동으로 순차 처리됩니다. 메인앱에서 별도 요청이 불필요합니다.
- `User Script Sandboxing`을 `No`로 설정하지 않으면 KissXML 관련 빌드 오류가 발생합니다.
- `clearUserData()` 호출 시 로컬의 모든 사용자 데이터가 삭제됩니다.
- 미등록 사용자(`isRegistered() = false`)는 게임 및 광고 기능을 사용할 수 없습니다.

---

## 문의

SDK 연동 관련 문의: point4udevelop@adwon.co
