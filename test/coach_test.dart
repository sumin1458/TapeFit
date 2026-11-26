import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/app/router.dart';
import 'package:tapefit/application/guide_providers.dart';
import 'package:tapefit/domain/coach_rules.dart';
import 'package:tapefit/domain/guide_models.dart';
import 'package:tapefit/domain/tape_analyzer.dart';
import 'package:tapefit/presentation/ai_check/camera_feed.dart';

void main() {
  RawFrame frame(List<List<List<double>>> guide, {int shiftX = 0}) {
    const w = 120, h = 160;
    final px = Uint8List(w * h * 4);
    for (var i = 0; i < w * h; i++) {
      px.setAll(i * 4, [200, 160, 140, 255]);
    }
    final fit = GuideFit(300, 400);
    for (final line in guide) {
      for (var i = 0; i + 1 < line.length; i++) {
        final a = line[i], b = line[i + 1];
        for (var t = 0.0; t <= 1; t += 0.02) {
          final (bx, by) = fit.toBox(a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t);
          final fx = (bx / 2.5).round() + shiftX, fy = (by / 2.5).round();
          for (var y = fy - 2; y <= fy + 2; y++) {
            for (var x = fx - 2; x <= fx + 2; x++) {
              if (x < 0 || y < 0 || x >= w || y >= h) continue;
              px.setAll((y * w + x) * 4, [30, 90, 220, 255]);
            }
          }
        }
      }
    }
    return RawFrame(w, h, px);
  }

  List<List<List<double>>> guide() {
    final cat = GuideCatalog.fromBundle(
        Map<String, dynamic>.from(jsonDecode(File('content/guides.json').readAsStringSync()) as Map));
    return cat.bodyParts.first.symptoms.first.steps[1].tape;
  }

  // T-54: 가상 AI 코치는 기기 안에서 프레임을 분석해 일치·치우침·미검출을 구분한다
  test('가상 AI 코치가 일치·치우침·미검출을 구분한다 (T-54)', () {
    final g = guide();
    expect(analyzeTape(frame: frame(g), guide: g).level, CoachLevel.good);

    final shifted = analyzeTape(frame: frame(g, shiftX: 12), guide: g);
    expect(shifted.level, isNot(CoachLevel.good));
    expect(shifted.tips.join(), contains('오른쪽'));

    final blank = RawFrame(120, 160, Uint8List.fromList(List.generate(120 * 160 * 4, (i) => i % 4 == 3 ? 255 : 180)));
    expect(analyzeTape(frame: blank, guide: g).level, CoachLevel.noTape);

    final dark = RawFrame(120, 160, Uint8List(120 * 160 * 4));
    expect(analyzeTape(frame: dark, guide: g).level, CoachLevel.dark);
    expect(analyzeTape(frame: blank, guide: const []).level, CoachLevel.unsupported);
  });

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
        cameraFeedBuilderProvider.overrideWithValue((c, g) {
          g.grab = () async => RawFrame(120, 160, Uint8List.fromList(List.generate(120 * 160 * 4, (i) => i % 4 == 3 ? 255 : 180)));
          return const ColoredBox(key: ValueKey('fake-cam'), color: Colors.grey);
        }),
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

    await tester.tap(find.byKey(const ValueKey('ask-ai')));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('ai-result')), findsOneWidget);
    expect(find.text('테이프가 잘 보이지 않아요'), findsOneWidget);

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
