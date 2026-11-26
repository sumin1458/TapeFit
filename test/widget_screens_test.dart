import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/application/guide_providers.dart';
import 'package:tapefit/domain/guide_models.dart';
import 'package:tapefit/presentation/guide/step_guide_screen.dart';
import 'package:tapefit/presentation/home/home_screen.dart';

GuideCatalog loadCatalog() => GuideCatalog.fromBundle(
    Map<String, dynamic>.from(jsonDecode(File('content/guides.json').readAsStringSync()) as Map));

Widget app(Widget home, List<Override> overrides) =>
    ProviderScope(overrides: overrides, child: MaterialApp(home: home));

void main() {
  // T-31: 단계 화면에 출처 링크와 검수 상태가 보인다 (FR-05, FR-08)
  testWidgets('단계 가이드에 출처와 검수 상태가 표시된다 (T-31)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    final catalog = loadCatalog();
    await tester.pumpWidget(app(
      const StepGuideScreen(symptomId: 'ankle_instability'),
      [catalogProvider.overrideWith((ref) async => catalog)],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('출처 ·'), findsWidgets);
    expect(find.textContaining('서울대학교병원'), findsWidgets);
    expect(find.text('검수 예정'), findsOneWidget);
    expect(find.text('1 / 5 단계'), findsOneWidget);
  });

  // T-32: 원본 로드 실패 시 안내와 다시 시도 버튼이 나온다 (오류 처리)
  testWidgets('가이드 로드 실패 시 안내와 다시 시도 버튼을 보여 준다 (T-32)', (tester) async {
    await tester.pumpWidget(app(
      const HomeScreen(),
      [catalogProvider.overrideWith((ref) async => throw Exception('load failed'))],
    ));
    await tester.pumpAndSettle();

    expect(find.text('가이드를 불러오지 못했어요.'), findsOneWidget);
    expect(find.text('다시 시도'), findsOneWidget);
  });

  // T-33: 없는 증상 ID로 들어오면 안내 문구가 나온다
  testWidgets('없는 가이드 ID는 찾을 수 없다는 안내를 보여 준다 (T-33)', (tester) async {
    final catalog = loadCatalog();
    await tester.pumpWidget(app(
      const StepGuideScreen(symptomId: 'no_such_guide'),
      [catalogProvider.overrideWith((ref) async => catalog)],
    ));
    await tester.pumpAndSettle();

    expect(find.text('가이드를 찾을 수 없어요.'), findsOneWidget);
  });

  // T-34: 홈에 면책 문구가 항상 보이고 준비 중 부위는 비활성이다 (FR-07)
  testWidgets('홈에 면책 문구가 보이고 준비 중 부위가 표시된다 (T-34)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    final catalog = loadCatalog();
    await tester.pumpWidget(app(
      const HomeScreen(),
      [catalogProvider.overrideWith((ref) async => catalog)],
    ));
    await tester.pumpAndSettle();

    expect(find.textContaining('의학적 진단·치료를 대체하지 않습니다'), findsOneWidget);
    expect(find.text('준비 중이에요'), findsWidgets);
  });
}
