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
/// flutter analyze                               # 오류 0건 (안내 14건)
/// flutter test                                  # 27건 통과 (2026-11-27, TRD 8.1)
/// ```
///
/// ## 콘텐츠 (`content/guides.json` = `assets/fallback/guides.json`)
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
/// 구현: 홈, 안전 체크, 단계 가이드, 완료, 즐겨찾기(메모리), 출처 링크,
/// 검수 배지, 번들 폴백, 원격 실패 시 폴백.
/// 범위 제외: 즐겨찾기 영구 저장, 시작 초기화 흐름, Analytics, 점검 화면,
/// Firebase 실제 연결(`firebase_options.dart`는 자리표시자), Android/iOS 실행.
/// 자세한 내용은 TRD 1.5절.
library;
