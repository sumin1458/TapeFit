# TapeFit (테이프핏)

초보자를 위한 단계별 테이핑 가이드 앱 (Flutter + Firebase). 요구사항은 `docs/PRD.md`, 설계는 `docs/TRD.md`.

## 실행

```bash
flutter create . --platforms=android,ios   # 최초 1회: 플랫폼 폴더 생성 (기존 lib/pubspec은 유지)
flutter pub get
flutter run
```

Firebase 설정 전에는 번들 데이터(`assets/fallback/guides.json`)와 메모리 즐겨찾기로 동작합니다.

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
flutter test
```
