import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/app/router.dart';
import 'package:tapefit/application/guide_providers.dart';
import 'package:tapefit/domain/guide_models.dart';

void main() {
  // T-40: 하단 탭 5개(홈·부위·즐겨찾기·더보기·MY)로 화면이 이동한다
  testWidgets('하단 탭으로 AI검사·더보기·MY 화면에 이동한다 (T-40)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    final catalog = GuideCatalog.fromBundle(
        Map<String, dynamic>.from(jsonDecode(File('content/guides.json').readAsStringSync()) as Map));
    await tester.pumpWidget(ProviderScope(
      overrides: [catalogProvider.overrideWith((ref) async => catalog)],
      child: MaterialApp.router(routerConfig: appRouter),
    ));
    await tester.pumpAndSettle();

    expect(find.byType(NavigationDestination), findsNWidgets(6));

    await tester.tap(find.text('테이핑 소개'));
    await tester.pumpAndSettle();
    expect(find.text('키네시오 테이프 (탄성 테이프)'), findsOneWidget);
    expect(find.text('Y자 테이프'), findsOneWidget);
    await tester.tap(find.text('AI검사'));
    await tester.pumpAndSettle();
    expect(find.text('추후 업데이트 예정'), findsOneWidget);

    await tester.tap(find.text('더보기'));
    await tester.pumpAndSettle();
    expect(find.text('이용 안내'), findsOneWidget);

    await tester.tap(find.text('MY'));
    await tester.pumpAndSettle();
    expect(find.text('업데이트 예정'), findsOneWidget);
    expect(find.text('MY 기능은 곧 만나볼 수 있어요.'), findsOneWidget);
  });
}
