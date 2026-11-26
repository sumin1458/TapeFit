import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/app/router.dart';
import 'package:tapefit/application/guide_providers.dart';
import 'package:tapefit/domain/guide_models.dart';
import 'package:tapefit/presentation/guide/widgets/leg_model.dart';

void main() {
  // T-50: 3D 모형 기하 데이터
  test('3D 모형은 종아리~발 면을 갖고, 단계별 테이프 줄이 표면 위에 있다 (T-50)', () {
    final faces = LegMesh.instance.faces;
    expect(faces.length, greaterThan(500));
    final ys = faces.expand((f) => f.points).map((p) => p.y);
    expect(ys.reduce((a, b) => a < b ? a : b), closeTo(soleY, 0.5));
    expect(ys.reduce((a, b) => a > b ? a : b), closeTo(legTop, 0.01));

    for (var i = 0; i < 5; i++) {
      final strips = tapeStripsForStep(i);
      expect(strips, isNotEmpty, reason: '단계 ${i + 1}');
      for (final s in strips) {
        expect(s.points.length, greaterThan(2));
        for (final p in s.points) {
          expect(p.normal.length, closeTo(1, 1e-6));
        }
      }
    }
    expect(tapeStripsForStep(5), isEmpty);
  });

  // T-51: 360도 회전·시점 전환
  testWidgets('3D 보기에서 드래그와 시점 버튼으로 회전하고 2D로 바꿀 수 있다 (T-51)', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(800, 2400);
    addTearDown(tester.view.reset);
    final catalog = GuideCatalog.fromBundle(Map<String, dynamic>.from(
        jsonDecode(File('content/guides.json').readAsStringSync()) as Map));
    await tester.pumpWidget(ProviderScope(
      overrides: [catalogProvider.overrideWith((ref) async => catalog)],
      child: MaterialApp.router(routerConfig: appRouter),
    ));
    appRouter.go('/guide/ankle_instability');
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('leg3d')), findsOneWidget);
    expect(find.textContaining('회전 46°'), findsOneWidget);

    await tester.drag(find.byKey(const ValueKey('leg3d')), const Offset(100, 0));
    await tester.pumpAndSettle();
    expect(find.textContaining('회전 46°'), findsNothing);

    await tester.tap(find.text('뒤'));
    await tester.pumpAndSettle();
    expect(find.textContaining('회전 180°'), findsOneWidget);

    await tester.tap(find.text('다음'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('leg3d')), findsOneWidget);

    await tester.tap(find.text('2D 도식'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('leg3d')), findsNothing);
  });
}
