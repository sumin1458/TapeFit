import 'package:firebase_core/firebase_core.dart';

/// 자리표시 파일입니다. Firebase 프로젝트를 만든 뒤 아래 명령으로 덮어쓰세요.
///   dart pub global activate flutterfire_cli
///   flutterfire configure
/// 덮어쓰기 전에는 initializeApp 이 실패하고, 앱은 번들 데이터(오프라인 모드)로 동작합니다.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    throw UnsupportedError('Firebase가 아직 설정되지 않았습니다. `flutterfire configure`를 실행하세요.');
  }
}
