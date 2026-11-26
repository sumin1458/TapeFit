/// TapeFit 테스트 실행 기록 (심사·인수인계용 요약, 실행 코드 없음).
///
/// 아래는 2026-11-27에 실제로 실행한 명령과 출력의 끝부분이다.
/// 같은 명령은 GitHub Actions(`.github/workflows/deploy.yml`)가 `main`에 push될 때마다
/// 다시 실행하고, 하나라도 실패하면 웹 시연 배포가 중단된다.
/// 실행 기록은 저장소 Actions 탭에서 볼 수 있다.
///
/// ## 1. 앱 테스트
/// ```text
/// $ flutter test
/// 00:04 +42: All tests passed!
/// ```
/// 42건: 검증 규칙, 콘텐츠 번들(T-35~T-37), 화면(T-31~T-34),
/// 즐겨찾기 저장(T-38, T-39), 하단 탭(T-40), 원격 실패·보안 규칙 사본(T-41~T-48),
/// 전체 흐름(T-49). 번호별 설명은 `docs/TRD.md` 8장 표 참고.
///
/// ## 2. 콘텐츠 검증 테스트 (Node)
/// ```text
/// $ node --test tool/validate_content.test.mjs
/// ✔ 거부: tape 점 1개 → TAPE_RANGE
/// ✔ 거부: 버전 형식 오류 → VERSION_FORMAT
/// ℹ tests 19
/// ℹ pass 19
/// ℹ fail 0
/// ```
///
/// ## 3. 콘텐츠 검증
/// ```text
/// $ node tool/validate_content.mjs
/// 콘텐츠 검증 통과
/// ```
///
/// ## 4. 정적 분석
/// ```text
/// $ flutter analyze
/// 오류 0건, 안내(info) 17건 (모두 package:flutter/material.dart 사용 중단 안내)
/// ```
///
/// ## 미실행
/// Android·iOS 기기 실행, 실제 Firebase 연결 테스트는 하지 않았다.
library;
