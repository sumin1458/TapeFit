import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/app/router.dart';
import 'package:tapefit/application/guide_providers.dart';
import 'package:tapefit/data/tape_knowledge.dart';
import 'package:tapefit/domain/guide_models.dart';

void main() {
  // T-55: 모든 지식 항목은 등록된 출처만 인용한다
  test('소개·사전 항목의 출처 ID가 모두 출처 목록에 있다 (T-55)', () {
    final ids = knowledgeSources.map((s) => s.id).toSet();
    final all = [
      for (final t in tapeTypes) ...t.sources,
      for (final s in stripShapes) ...s.sources,
      for (final g in glossaryTerms) ...g.sources,
    ];
    expect(all, isNotEmpty);
    expect(all.every(ids.contains), isTrue);
    expect(glossaryTerms.every((g) => g.sources.isNotEmpty), isTrue);
    expect(stripShapes.map((s) => s.id), containsAll(['i', 'y', 'x', 'fan']));
  });

  // T-56: 더보기에서 용어 사전을 열고 검색한다
  testWidgets('용어 사전을 열어 검색하면 결과가 걸러진다 (T-56)', (tester) async {
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
    await tester.tap(find.text('더보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('open-glossary')));
    await tester.pumpAndSettle();
    expect(find.textContaining('앵커'), findsWidgets);

    await tester.enterText(find.byKey(const ValueKey('glossary-search')), 'heel lock');
    await tester.pumpAndSettle();
    expect(find.textContaining('힐락'), findsOneWidget);
    expect(find.textContaining('스터럽  (stirrup)'), findsNothing);

    await tester.enterText(find.byKey(const ValueKey('glossary-search')), 'zzzz');
    await tester.pumpAndSettle();
    expect(find.text('검색 결과가 없어요.'), findsOneWidget);
  });
}
