import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/app/router.dart';
import 'package:tapefit/application/guide_providers.dart';
import 'package:tapefit/domain/guide_models.dart';

void main() {
  // T-49: 안전 체크 → 5단계 → 완료 → 처음으로 전체 흐름 (FR-01~FR-04)
  testWidgets('안전 체크부터 완료까지 전체 흐름이 동작한다 (T-49)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    final catalog = GuideCatalog.fromBundle(
        Map<String, dynamic>.from(jsonDecode(File('content/guides.json').readAsStringSync()) as Map));
    await tester.pumpWidget(ProviderScope(
      overrides: [catalogProvider.overrideWith((ref) async => catalog)],
      child: MaterialApp.router(routerConfig: appRouter),
    ));
    appRouter.go('/safety/ankle_instability');
    await tester.pumpAndSettle();

    // FR-02: 위험 신호를 체크하면 진행 버튼이 사라지고 진료 권고가 나온다
    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    expect(find.text('해당 없어요, 시작할게요'), findsNothing);
    expect(find.textContaining('전문의 진료를 받으세요'), findsOneWidget);

    await tester.tap(find.byType(CheckboxListTile).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('해당 없어요, 시작할게요'));
    await tester.pumpAndSettle();

    // FR-03: 5단계를 다음 버튼으로 끝까지 이동한다
    for (var i = 1; i <= 4; i++) {
      expect(find.text('$i / 5 단계'), findsOneWidget);
      await tester.tap(find.text('다음'));
      await tester.pumpAndSettle();
    }
    expect(find.text('5 / 5 단계'), findsOneWidget);

    // FR-04: 마지막 단계 뒤 완료 화면, 처음으로 돌아간다
    await tester.tap(find.text('완료'));
    await tester.pumpAndSettle();
    expect(find.text('테이핑을 마쳤어요!'), findsOneWidget);
    await tester.tap(find.text('처음으로'));
    await tester.pumpAndSettle();
    expect(find.text('어디가 불편하세요?'), findsOneWidget);
  });
}
