/// TapeFit 프로젝트 개요 (심사·인수인계용 요약, 실행 코드 없음).
///
/// 원본은 저장소의 `docs/PRD.md`, `docs/TRD.md`, `content/guides.json`,
/// `firestore.rules`, `pubspec.yaml`이며, 여기에는 그 핵심만 요약한다.
///
/// ## 실행 방법
/// ```text
/// flutter pub get
/// flutter run -d chrome                         # 웹 실행 (Flutter 3.50.1 / Dart 3.14)
/// node tool/validate_content.mjs                # 콘텐츠 검증
/// node --test tool/validate_content.test.mjs    # Node 검증 테스트 19건
/// flutter analyze                               # 오류 0건 (안내 16건, 모두 material.dart 사용 중단 안내)
/// flutter test                                  # 33건 통과 (2026-11-27, TRD 8.1)
/// ```
///
/// ## 콘텐츠 (`lib/data/guide_content.dart` = `content/guides.json` = `assets/fallback/guides.json`)
/// 앱은 `guide_content.dart` 상수를 번들 폴백으로 쓰고, 세 파일의 일치는 T-35가 검사한다.
/// 가이드 `ankle_instability` (발목 불안정감, 리지드 테이프 + 언더랩), 5단계:
/// 1. 피부 준비 (출처 S3) 2. 앵커 (S3, S5) 3. 스터럽 (S3, S5)
/// 4. 호스슈 (S3) 5. 마무리 확인 (S3).
/// 각 단계는 `tape` 좌표(도식)와 `sources`(출처 ID)를 가지며, 주의사항 6개도
/// 각각 출처를 가진다. 검수 상태는 `review.status = pending`(검수 예정)이다.
///
/// 출처 목록: S1·S2 학술 논문, S3·S6 서울대병원 의학정보, S4 콘텐츠 검수(팀원),
/// S5 Athletic Therapy Skills. S4만 URL이 없다.
///
/// ## 보안 규칙 (`firestore.rules`)
/// - `meta`, `bodyParts`, `references`: 누구나 읽기, 쓰기 금지.
/// - `guides`: `published == true`인 문서만 읽기, 쓰기 금지.
/// - `users/{uid}/favorites/{symptomId}`: 본인만 읽기·삭제, 생성·수정은
///   ID 형식 `^[a-z0-9_]{1,64}$`, 필드는 `createdAt`만, 값은 서버 시각이어야 함.
///
/// ## 검증 규칙
/// 콘텐츠 검증 오류 코드 13개를 Dart(`lib/core/validation.dart`)와
/// Node(`tool/validate_content.mjs`)가 같은 규칙으로 구현하고, 두 구현은
/// `test/fixtures/invalid_cases.json`을 함께 사용한다.
///
/// ## 구현 범위
/// 구현: 홈, AI검사(업데이트 예정 안내)/더보기/MY 탭, 안전 체크, 단계 가이드, 완료, 즐겨찾기(기기 저장), 출처 링크,
/// 검수 배지, 번들 폴백, 원격 실패 시 폴백.
/// 범위 제외: 시작 초기화 흐름, Analytics, 점검 화면,
/// Firebase 실제 연결(`firebase_options.dart`는 자리표시자), Android/iOS 실행.
/// 자세한 내용은 TRD 1.5절.
///
/// ## 기술 설계(TRD)와 구현 위치
/// | TRD 절 | 설계 | 구현 파일 |
/// |---|---|---|
/// | 2.1 스택 | Flutter + Riverpod + go_router + Firebase | `pubspec.yaml`, `lib/main.dart` |
/// | 3.1 구성요소 | 화면 / 상태 / 저장소 / 도메인 분리 | 아래 계층 표 |
/// | 3.3 화면 상태 전이 | 홈 → 안전 체크 → 단계 가이드 → 완료 | `lib/app/router.dart`, `lib/presentation/*` |
/// | 5.3 도메인 모델 | 가이드·단계·출처·검수 | `lib/domain/guide_models.dart` |
/// | 5.4 보안 규칙 | 읽기 전용 콘텐츠, 본인 즐겨찾기 | `firestore.rules` |
/// | 5.5 오프라인 정책 | 번들 콘텐츠로 폴백 | `lib/data/fallback_guide_source.dart`, `guide_content.dart` |
/// | 6.1 Repository 계약 | 가이드·즐겨찾기 인터페이스 | `lib/domain/guide_repository.dart`, `lib/data/*` |
/// | 6.2 문서 필드 규칙 | 검증 오류 코드 13개 | `lib/core/validation.dart` |
/// | 7 오류 처리 | 시간 제한(8초), 검증 실패 폴백, 저장 실패 복구 | `lib/data/firestore_guide_repository.dart`(`FirestoreGuideRepository`, `BundledGuideRepository`), `lib/application/guide_providers.dart`(`FavoritesNotifier`) |
///
/// ## 계층 구조 (의존 방향: presentation → application → domain ← data)
/// - `lib/domain`: 모델과 저장소 인터페이스 (Firebase·화면에 의존하지 않음)
/// - `lib/data`: Firestore 저장소, 번들 폴백, 즐겨찾기 저장소(Firestore/기기 저장/메모리)
/// - `lib/application`: Riverpod provider (카탈로그, 선택된 증상, 즐겨찾기)
/// - `lib/presentation`: 홈, 안전 체크, 단계 가이드, 완료, 즐겨찾기 화면
/// - `lib/app`: 라우터, 테마, 하단 탭 / `lib/core`: 검증 규칙
///
/// ## 의존성과 설정 (`pubspec.yaml`, 비밀 값 없음)
/// - 런타임: `flutter_riverpod ^2.5.1`, `go_router ^14.2.0`, `firebase_core ^3.1.0`,
///   `cloud_firestore ^5.0.0`, `firebase_auth ^5.0.0`, `url_launcher ^6.3.3`
/// - 개발: `flutter_test`, `flutter_lints ^4.0.0` (`analysis_options.yaml`)
/// - SDK: Dart `>=3.6.0 <4.0.0`
/// - Firebase: `firebase.json`(규칙·인덱스·에뮬레이터 포트), `firestore.rules`,
///   `firestore.indexes.json`. `lib/firebase_options.dart`는 자리표시자라
///   실제 키가 저장소에 없고, 설정 전에는 오프라인 모드로 동작한다.
library;
