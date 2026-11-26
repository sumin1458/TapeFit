/// Firestore 보안 규칙 사본. 원본은 저장소 루트의 `firestore.rules`이며,
/// `test/security_rules_test.dart`(T-41)가 두 내용이 같은지 확인한다.
///
/// ## 규칙 요약
/// - 읽기 전용 콘텐츠(`meta`, `bodyParts`, `references`): 누구나 읽을 수 있고 쓰기는 모두 막는다.
/// - `guides`: `published == true`인 문서만 읽을 수 있고, 쓰기는 모두 막는다.
///   (검수 전 초안이 앱에 노출되지 않게 한다.)
/// - `users/{uid}/favorites/{symptomId}`: 로그인한 본인(익명 로그인 UID)만 읽기·삭제할 수 있다.
///   생성·수정은 본인이면서 문서 ID가 `[a-z0-9_]{1,64}` 형식이고,
///   필드가 `createdAt` 하나뿐이며 값이 서버 시간일 때만 허용한다.
/// - 그 외 모든 경로는 규칙이 없으므로 기본적으로 거부된다.
///
/// 콘텐츠는 Firebase 콘솔에서만 수정하고, 앱은 읽기만 한다. 비밀 값은 포함하지 않는다.
const String firestoreRulesText = r'''
rules_version = '2';
service cloud.firestore {
  match /databases/{db}/documents {
    match /meta/{id}       { allow read: if true; allow write: if false; }
    match /bodyParts/{id}  { allow read: if true; allow write: if false; }
    match /references/{id} { allow read: if true; allow write: if false; }
    match /guides/{id} {
      allow read: if resource.data.published == true;
      allow write: if false;
    }
    match /users/{uid}/favorites/{symptomId} {
      allow read, delete: if request.auth != null && request.auth.uid == uid;
      allow create, update: if request.auth != null && request.auth.uid == uid
        && symptomId.matches('^[a-z0-9_]{1,64}$')
        && request.resource.data.keys().hasOnly(['createdAt'])
        && request.resource.data.createdAt == request.time;
    }
  }
}
''';
