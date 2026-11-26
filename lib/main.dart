import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/router.dart';
import 'app/theme.dart';
import 'application/guide_providers.dart';
import 'data/fallback_guide_source.dart';
import 'data/favorite_repository.dart';
import 'data/firestore_guide_repository.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final overrides = <Override>[];
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
    final db = FirebaseFirestore.instance;
    db.settings = const Settings(persistenceEnabled: true);
    overrides.addAll([
      guideRepositoryProvider.overrideWithValue(
        FirestoreGuideRepository(db, FallbackGuideSource()),
      ),
      favoriteRepositoryProvider.overrideWithValue(
        FirestoreFavoriteRepository(db, FirebaseAuth.instance),
      ),
    ]);
  } catch (e) {
    // Firebase 미설정/초기화 실패: 번들 데이터 + 메모리 즐겨찾기로 계속 동작한다.
    debugPrint('Firebase 사용 불가, 오프라인 모드로 실행: $e');
  }

  runApp(ProviderScope(overrides: overrides, child: const TapeFitApp()));
}

class TapeFitApp extends StatelessWidget {
  const TapeFitApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: '테이프핏',
      debugShowCheckedModeBanner: false,
      theme: buildTheme(),
      routerConfig: appRouter,
      builder: (context, child) => ColoredBox(
        color: const Color(0xFFE9EEFA),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 480),
            child: child,
          ),
        ),
      ),
    );
  }
}
