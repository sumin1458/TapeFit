# TapeFit (테이프핏)

초보자를 위한 단계별 테이핑 가이드 앱 (Flutter + Firebase). 요구사항은 `docs/PRD.md`, 설계는 `docs/TRD.md`.

## 실행

```bash
flutter pub get
flutter run -d chrome          # 웹 (Android/iOS는 `flutter create . --platforms=android,ios` 후 `flutter run`)
```

필요 환경: Flutter 3.50.1(Dart 3.14), Node 20+ (콘텐츠 검증용). `web/` 폴더가 포함되어 있어 바로 웹으로 실행됩니다.
Firebase 설정 전에는 번들 데이터(`assets/fallback/guides.json`)와 메모리 즐겨찾기로 동작합니다.

## 폴더 구조

| 경로 | 내용 |
|---|---|
| `lib/domain`, `lib/data`, `lib/application`, `lib/presentation` | 모델·저장소·상태(Riverpod)·화면 |
| `lib/core/validation.dart` | 콘텐츠 검증 (오류 코드 13개) |
| `content/guides.json` | 콘텐츠 원본 (수정 시 `assets/fallback/guides.json`에 복사) |
| `tool/validate_content.mjs` | Node 검증 스크립트 (Dart와 같은 규칙) |
| `test/` | 단위·위젯 테스트와 `fixtures/invalid_cases.json` |
| `docs/PRD.md`, `docs/TRD.md` | 요구사항·기술 설계(실행 결과 포함) |
| `firestore.rules`, `firebase.json` | Firebase 규칙·설정 |

## Firebase 연동

1. Firebase 콘솔에서 프로젝트 생성 (Spark 무료 플랜), Firestore와 익명 로그인(Authentication) 활성화
2. `dart pub global activate flutterfire_cli` → `flutterfire configure` (`lib/firebase_options.dart` 덮어쓰기)
3. `firebase deploy --only firestore:rules`
4. 콘텐츠 업로드 (서비스 계정 키는 저장소 밖에 보관):
   ```bash
   cd tool/seed && npm install && cd ../..
   node tool/validate_content.mjs
   GOOGLE_APPLICATION_CREDENTIALS=<키 경로> GCLOUD_PROJECT=<프로젝트 ID> node tool/seed/seed.mjs
   ```

콘텐츠 원본은 `content/guides.json`이며, 수정하면 `assets/fallback/guides.json`에도 복사하세요.

## 테스트

```bash
flutter pub get
node tool/validate_content.mjs                 # 콘텐츠 검증
node --test tool/validate_content.test.mjs     # Node 검증 테스트 (19건)
flutter analyze                                # 오류 0건 (안내 13건)
flutter test                                   # 27건
```

2026-11-27 실행 결과: 콘텐츠 검증 통과, `flutter test` 27건 통과, Node 테스트 19건 통과, `flutter analyze` 오류 0건. 자세한 기록과 미실행 항목은 `docs/TRD.md` 8.1절, 구현 범위는 1.5절을 참고하세요.
