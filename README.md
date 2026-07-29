# PointCU iOS SDK

ADWON POINT4U 포켓CU 어플리케이션용 iOS SDK입니다.  
Swift Package Manager(SPM)를 통해 배포되며, UIKit / SwiftUI 모두 지원합니다.

---

## 릴리즈 내역

| 버전    | 날짜         | 내용                                                      |
| ----- | ---------- | ------------------------------------------------------- |
| 2.0.4 | 2026.07.29 | APSSPSDK 3.2.4 UPDATE 적용 |
| 2.0.3 | 2026.07.29 | APSSPSDK 3.2.3 UPDATE 적용 |
| 2.0.2 | 2026.07.24 | Package.swift 버전 변경 및 서비스가이드 버그 수정 |
| 2.0.0 | 2026.06.24 | APSSPSDK 3.x 마이그레이션 (NAMAdapter 제거, AppDelegate 초기화 간소화) |
| 1.0.6 | 2026.06.15 | 걸음 미션 광고 호출 순서 처리 수정                                    |
| 1.0.5 | 2026.06.11 | 앱권한 변경 시 걸음 관련 버그 수정                                    |
| 1.0.4 | 2026.06.10 | 메인 리스트 배너 노출 버그 수정                                      |
| 1.0.3 | 2026.06.09 | 통계 화면 UI 수정                                             |
| 1.0.2 | 2026.06.06 | 로그 처리 일부 수정                                             |
| 1.0.1 | 2026.06.06 | 마이너 버그 수정 (빈 리스트 대응)                                    |
| 1.0.0 | 2026.06.05 | 상용 서비스 대비 수정 버전                                         |
| 0.0.1 | 2026.05.19 | 테스트 버전 출시                                               |

---

## 지원 환경

| 항목        | 내용                          |
| --------- | --------------------------- |
| 최소 iOS 버전 | iOS 15.0 이상                 |
| 개발 언어     | Swift 5.9+                  |
| 배포 방식     | Swift Package Manager (SPM) |

---

## 샘플 프로젝트

PointCU 연동을 위한 샘플 프로젝트입니다.  
https://github.com/adwon24/pointcu-ios-sample

---

## ⚠️ v2.0.0 마이그레이션 안내 (1.x → 2.x)

v2.0.0부터 APSSPSDK가 3.x로 업그레이드되었습니다.  
기존 1.x 버전에서 2.x로 업그레이드 시 아래 변경 사항을 반드시 적용해야 합니다.

### 제거해야 할 것

| 항목 | 설명 |
| --- | --- |
| `NAMAdapter.h` | 프로젝트에서 삭제 |
| `NAMAdapter.m` | 프로젝트에서 삭제 |
| `{YourApp}-Bridging-Header.h` | 삭제 또는 내용 비우기 |
| Build Settings → `Objective-C Bridging Header` | 경로 비우기 |
| `pod 'NAMSDK'` | Podfile에서 제거 |
| `GFPAdManager.setup(...)` | AppDelegate에서 제거 |
| `GFPAdManagerDelegate` | AppDelegate에서 제거 |
| `import NAMSDK` | AppDelegate에서 제거 |


### 추가/교체해야 할 것

| 항목 | 설명 |
| --- | --- |
| `GFPNativeSimpleAdView.xib` | 기존 파일 유지 (변경 없음) |
| `APSSPSDK` Pod | 3.1.7 이상으로 업그레이드 |
| 미디에이션 어댑터 Pod | 아래 버전으로 업그레이드 |
| AppDelegate 초기화 코드 | 아래 3. SDK 초기화 참조 |

### SPM AdPopcornSSP 중복 참조 제거

v2.0.0부터 `AdPopcornSSP`가 SPM dependency에서 제거되었습니다.  
기존에 SPM으로 `AdPopcornSSP`가 추가되어 있던 경우, CocoaPods(`APSSPSDK`)과 중복 참조되므로 반드시 제거해야 합니다.

1. **기존 `AdPopcornSSP` SPM 패키지 삭제**  
   Xcode 좌측 `Package Dependencies`에서 `AdPopcornSSP` 선택 후 제거

2. **PointCU 패키지 업데이트**  
   `File → Packages → Update to Latest Package Versions`

3. **빌드 확인**  
   `Package Dependencies`에 `AdPopcornSSP`가 나타나지 않으면 정상

---

## 1. SDK 설치

### 1.1 SPM 패키지 추가

Xcode에서 아래 순서로 패키지를 추가합니다.

1. `Xcode → File → Add Package Dependencies`
2. URL 입력: `https://github.com/adwon24/pointcu-ios.git`
3. Dependency Rule: `Range of Versions  2.0.0 ..< 3.0.0`
4. Product: `PointCUSDK` → 메인 앱 타겟에 추가

**PointCUSDK에 포함된 의존성 (자동 설치):**

| 패키지               | 버전         | 용도           |
| ----------------- | ---------- | ------------ |
| GreenPOfferWall   | 4.2.0+     | 그린P 오퍼월      |
| NStationOfferwall | 1.9.8 (고정) | NStation 오퍼월 |

> ※ v2.0.0부터 `AdPopcornSSP`(구버전) 의존성이 제거되었습니다.  
> `APSSPSDK` 및 미디에이션 어댑터는 아래 1.2에서 CocoaPods으로 별도 설치합니다.

### 1.2 APSSPSDK 및 미디에이션 어댑터 설치 (필수)

v2.0.0부터 `APSSPSDK` 및 모든 미디에이션 어댑터를 CocoaPods으로 설치합니다.  
기존의 `NAMSDK` Pod은 더 이상 필요하지 않습니다.

```ruby
# Podfile
target 'YourApp' do
  use_frameworks! :linkage => :static

  # APSSPSDK 코어
  pod 'APSSPSDK', '3.1.10'

  # 미디에이션 어댑터
  pod 'APSSPMediationAppLovin',  '13.6.2.8'
  pod 'APSSPMediationFyber',     '8.4.6.10'
  pod 'APSSPMediationNAM',       '8.20.0.9'
  pod 'APSSPMediationPangle',    '8.0.0.10'
  pod 'APSSPMediationUnityAds',  '4.17.0.10'
  pod 'APSSPMediationVungle',    '7.7.2.11'
  pod 'APSSPMediationAdMob',     '13.2.0.8'
  # Your code
end

post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = '15.0'
    end
  end
end
```

> ※ 기존 `pod 'NAMSDK'`는 반드시 제거해야 합니다.

### 1.3 GFPNativeSimpleAdView.xib 추가

NAM 네이티브 배너 광고 렌더링에 필요한 xib 파일입니다.  
기존 1.x 버전에서 사용하던 파일을 그대로 유지합니다.

> ※ 신규 연동 시 샘플 프로젝트(https://github.com/adwon24/pointcu-ios-sample)에서 `GFPNativeSimpleAdView.xib`를 복사하여 추가합니다.

### 1.4 Info.plist 설정

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

### 1.5 Frameworks 추가

메인 앱 타겟에 아래 프레임워크를 추가합니다.

```
Xcode → Target → General → Frameworks, Libraries, and Embedded Content
→ + 버튼 → 아래 항목 추가
```

| Framework                           | 용도              |
| ----------------------------------- | --------------- |
| `AdSupport.framework`               | 광고 ID (IDFA) 접근 |
| `AppTrackingTransparency.framework` | ATT 권한 요청       |

### 1.6 Xcode Build Settings

| 설정 항목                  | 값   | 설명                    |
| ---------------------- | --- | --------------------- |
| User Script Sandboxing | No  | KissXML 빌드 오류 방지 (필수) |

---

## 2. 제거 항목 (v1.x에서 마이그레이션 시)

### 2.1 NAMAdapter 파일 제거

v2.0.0부터 NAMAdapter가 APSSPSDK 3.x 내부에 통합되었습니다.  
아래 파일들을 프로젝트에서 삭제합니다.

| 파일 | 처리 |
| --- | --- |
| `NAMAdapter.h` | 프로젝트에서 삭제 |
| `NAMAdapter.m` | 프로젝트에서 삭제 |
| `{YourApp}-Bridging-Header.h` | 삭제 또는 내용 비우기 |

`Build Settings → Swift Compiler - General → Objective-C Bridging Header` 경로를 비웁니다.

### 2.2 AppDelegate 정리

v1.x에서 필요했던 NAMSDK 초기화 코드를 제거합니다.

**제거할 코드:**

```swift
// ❌ v1.x — 아래 코드 전부 제거
import NAMSDK

class AppDelegate: UIResponder, UIApplicationDelegate, GFPAdManagerDelegate {
    func application(...) -> Bool {
        let configuration = GFPAdConfiguration()
        DispatchQueue.main.async {
            GFPAdManager.setup(
                withPublisherCd: "N256497692",
                target: self,
                configuration: configuration
            ) { error in ... }
        }
        return true
    }

    @objc func attStatus() -> GFPATTAuthorizationStatus { ... }
}
```

---

## 3. SDK 초기화

v2.0.0부터 NAMSDK 초기화가 APSSPSDK 3.x 내부에서 자동으로 처리됩니다.  
AppDelegate에서 `APSSPAds.initializeSDK()`만 호출하면 됩니다.

```swift
import APSSPSDK
import AppTrackingTransparency

class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(_ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        // APSSPSDK 초기화 (NAM 포함 모든 미디에이션 자동 초기화)
        let settings = APSSPInitializationSettings(appKey: "329767435")
        APSSPAds.initializeSDK(with: settings) {
            // 초기화 완료 => 이 후 광고 요청 가능
        }

        return true
    }
}
```

> ※ v1.x에서 사용하던 `GFPAdManager.setup(...)` 및 `GFPAdManagerDelegate` 코드는 완전히 제거해야 합니다.  
> ※ ATT 권한 요청은 SDK 진입 시 자동 처리됩니다. 메인앱에서 별도 요청이 불필요합니다.

---

## 4. SDK 메인 화면 실행

### 파라미터

| 파라미터           | 타입                     | 필수   | 설명                               |
| -------------- | ---------------------- | ---- | -------------------------------- |
| userId         | String                 | 필수   | 앱 재설치 후에도 동일한 ID 유지 필요           |
| birth          | String?                | 필수\* | 생년월일 (yyyy-MM-dd 또는 yyyyMMdd)    |
| age            | Int?                   | 필수\* | 나이 — birth 미입력 시 사용              |
| gender         | PointCUGender          | 필수   | `.male` / `.female` / `.unknown` |
| finishDelegate | PointCUFinishDelegate? | 선택   | 재고조회 이동 이벤트 수신                   |

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

| 메서드                                   | 설명                        |
| ------------------------------------- | ------------------------- |
| `onGameLoadFail(error: PointCUError)` | 게임 화면 구성 또는 광고 노출 오류 시 호출 |
| `onGameComplete(winPoint: Int)`       | 게임 이벤트 처리 후 포인트 확인 시 호출   |
| `onGameClose()`                       | 모든 게임 화면 종료 시 호출          |

### PointCUAdDelegate

`startPoint4uAdvertise` 사용 시 콜백입니다.

| 메서드                     | 호출 시점             |
| ----------------------- | ----------------- |
| `onAdShow(type:)`       | 광고가 화면에 표시될 때     |
| `onAdFail(type:error:)` | 모든 광고 로드 실패 시     |
| `onAdClose(type:)`      | 광고 팝업 닫힘 시        |
| `onAdEarned(type:)`     | 광고 페이지 5초 이상 체류 시 |
| `onAdClick(type:)`      | 광고 클릭 시           |

### PointCUAdViewDelegate

`makeAdViewController` 사용 시 콜백입니다.

| 메서드                  | 호출 시점              |
| -------------------- | ------------------ |
| `onAdLoaded()`       | 광고 로드 성공 시         |
| `onAdFailed(error:)` | 모든 광고 로드 실패 시      |
| `onAdClicked()`      | 광고 클릭 — Safari로 이동 |
| `onAdEarned()`       | 광고 페이지 5초 이상 체류 시  |
| `onAdReturned()`     | 5초 미만 복귀           |

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

```swift
let adVC = PointCUSDK.makeAdViewController(
    type:     .inventory,
    adSize:   CGSize(width: 300, height: 250),
    delegate: self
)
```

**방식 1: addChild (권장)**

```swift
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

**방식 2: present (pageSheet)**

```swift
let adVC = PointCUSDK.makeAdViewController(type: .newProduct, delegate: self)
adVC.modalPresentationStyle = .pageSheet
if let sheet = adVC.sheetPresentationController {
    sheet.detents = [.medium()]
    sheet.prefersGrabberVisible = true
}
present(adVC, animated: true)
```

**방식 3: UIView 직접 삽입**

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

### 서버 환경 설정

```swift
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

| 값          | 설명  |
| ---------- | --- |
| `.male`    | 남성  |
| `.female`  | 여성  |
| `.unknown` | 미지정 |

### Point4uAd

| 값             | 설명             | startPoint4uAdvertise | makeAdViewController |
| ------------- | -------------- | --------------------- | -------------------- |
| `.eat`        | CU 광고 - 오늘 뭐먹지 | ✅                     | ❌                    |
| `.inventory`  | CU 광고 - 재고 조회  | ✅                     | ✅                    |
| `.newProduct` | CU 광고 - 신상품    | ✅                     | ✅                    |
| `.preOrder`   | CU 광고 - 예약 구매  | ✅                     | ✅                    |

### PointCUServerType

| 값       | 서버                              | 설명            |
| ------- | ------------------------------- | ------------- |
| `.stg`  | https://stg.api.point4u.co.kr   | 개발 서버 1       |
| `.aws`  | https://aws.api.point4u.co.kr   | 개발 서버 2 (기본값) |
| `.prod` | https://api.point4u.co.kr       | 상용 서버         |

---

## 8. 에러 코드

| 코드                     | 값    | 설명              |
| ---------------------- | ---- | --------------- |
| `invalidBirthFormat`   | 1002 | birth 형식 오류     |
| `missingRequiredField` | 1003 | 필수 항목 누락        |
| `notInitialized`       | 1004 | SDK 초기화 전 함수 호출 |
| `notRegistered`        | 1005 | 미등록 사용자         |
| `noAdAvailable`        | 2001 | 광고 없음           |
| `unknown`              | 9999 | 알 수 없는 오류       |

---

## 9. 주의사항

- SDK 메인 화면은 `fullScreen` 방식으로 present 합니다.
- `makeAdViewController`의 `addChild`는 반드시 `viewDidAppear` 이후에 호출해야 합니다.
- ATT 권한 요청은 SDK 진입 시 자동 처리됩니다. 메인앱에서 별도 요청이 불필요합니다.
- `clearUserData()` 호출 시 SDK가 보관 중인 사용자 데이터만 삭제됩니다. 메인앱 데이터에는 영향을 주지 않습니다.
- `User Script Sandboxing`을 `No`로 설정하지 않으면 KissXML 관련 빌드 오류가 발생합니다.
- v2.0.0부터 `NAMAdapter` 파일 및 `NAMSDK` Pod이 더 이상 필요하지 않습니다.

---

## 문의

SDK 연동 관련 문의: point4udevelop@adwon.co