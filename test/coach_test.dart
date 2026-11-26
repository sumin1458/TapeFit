import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/app/router.dart';
import 'package:tapefit/application/guide_providers.dart';
import 'package:tapefit/domain/coach_rules.dart';
import 'package:tapefit/domain/guide_models.dart';
import 'package:tapefit/presentation/ai_check/camera_feed.dart';

void main() {
  // T-52: 코치 규칙은 답변에서 수정할 점·미응답·긴급 여부를 계산한다
  test('코치 규칙이 아니요 답변만 수정할 점으로 모은다 (T-52)', () {
    final n = coachRules[1]!.length;
    expect(evaluateCoach(1, {}).pending, n);
    final good = evaluateCoach(1, {for (var i = 0; i < n; i++) i: true});
    expect(good.allGood, isTrue);
    final bad = evaluateCoach(1, {for (var i = 0; i < n; i++) i: i != 2});
    expect(bad.fixes.single, coachRules[1]![2]);
    expect(bad.urgent, isFalse);
    expect(evaluateCoach(4, {0: true, 1: false, 2: true}).urgent, isTrue);
    expect(evaluateCoach(99, {}).allGood, isTrue);
  });

  // T-53: AI검사 화면은 가짜 카메라 위에 가이드선을 겹치고 코치 결과를 보여 준다
  testWidgets('AI검사: 카메라 오버레이와 코치 점검 결과 (T-53)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 3000);
    addTearDown(tester.view.reset);
    final catalog = GuideCatalog.fromBundle(
        Map<String, dynamic>.from(jsonDecode(File('content/guides.json').readAsStringSync()) as Map));
    await tester.pumpWidget(ProviderScope(
      overrides: [
        catalogProvider.overrideWith((ref) async => catalog),
        cameraFeedBuilderProvider.overrideWithValue((c) => const ColoredBox(key: ValueKey('fake-cam'), color: Colors.grey)),
      ],
      child: MaterialApp.router(routerConfig: appRouter),
    ));
    await tester.pumpAndSettle();
    appRouter.go('/ai');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('fake-cam')), findsNothing);
    await tester.tap(find.text('카메라 켜기'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('fake-cam')), findsOneWidget);
    expect(find.byKey(const ValueKey('guide-overlay')), findsOneWidget);

    final n = coachRules[1]!.length;
    for (var i = 0; i < n; i++) {
      final seg = find.descendant(of: find.byKey(ValueKey('coach-$i')), matching: find.text(i == 2 ? '아니요' : '예'));
      await tester.ensureVisible(seg);
      await tester.tap(seg);
      await tester.pumpAndSettle();
    }
    final btn = find.text('코치 점검 받기');
    await tester.ensureVisible(btn);
    await tester.tap(btn);
    await tester.pumpAndSettle();
    expect(find.text('수정할 점 1가지'), findsOneWidget);
    expect(find.textContaining(coachRules[1]![2].fix), findsOneWidget);
  });
}
