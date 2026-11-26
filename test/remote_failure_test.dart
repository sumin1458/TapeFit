import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/application/guide_providers.dart';
import 'package:tapefit/data/fallback_guide_source.dart';
import 'package:tapefit/data/firestore_guide_repository.dart';
import 'package:tapefit/data/firestore_rules.dart';
import 'package:tapefit/domain/guide_models.dart';
import 'package:tapefit/domain/guide_repository.dart';

GuideCatalog validRemote() => GuideCatalog.fromBundle(
    Map<String, dynamic>.from(jsonDecode(File('content/guides.json').readAsStringSync()) as Map));

class _FailingFavorites implements FavoriteRepository {
  @override
  Future<Set<String>> loadFavorites() async => throw Exception('load failed');
  @override
  Future<void> setFavorite(String symptomId, bool value) async => throw Exception('save failed');
}

class _SaveFailsFavorites implements FavoriteRepository {
  @override
  Future<Set<String>> loadFavorites() async => {};
  @override
  Future<void> setFavorite(String symptomId, bool value) async => throw Exception('save failed');
}

void main() {
  final fallback = FallbackGuideSource();

  // T-41: 앱의 보안 규칙 사본이 firestore.rules 원본과 같다
  test('보안 규칙 Dart 사본이 firestore.rules와 같다 (T-41)', () {
    String norm(String s) => s.replaceAll('\r\n', '\n').trim();
    expect(norm(firestoreRulesText), norm(File('firestore.rules').readAsStringSync()));
    expect(firestoreRulesText, contains('allow write: if false'));
    expect(firestoreRulesText, contains('published == true'));
  });

  // T-42: 원격 조회가 예외로 실패하면 번들 폴백을 쓴다
  test('원격 조회 예외 시 번들 폴백을 반환한다 (T-42)', () async {
    final repo = RemoteFirstGuideRepository(() async => throw Exception('network'), fallback);
    final c = await repo.loadCatalog();
    expect(c.fromFallback, isTrue);
    expect(c.symptom('ankle_instability'), isNotNull);
  });

  // T-43: 원격 응답이 시간 제한을 넘기면 번들 폴백을 쓴다
  test('원격 시간 초과 시 번들 폴백을 반환한다 (T-43)', () async {
    final repo = RemoteFirstGuideRepository(
      () => Completer<GuideCatalog>().future,
      fallback,
      timeout: const Duration(milliseconds: 50),
    );
    expect((await repo.loadCatalog()).fromFallback, isTrue);
  });

  // T-44: 가이드가 없는 원격 응답은 거부하고 폴백을 쓴다
  test('가이드가 비어 있는 원격 응답은 폴백으로 대체한다 (T-44)', () async {
    final empty = GuideCatalog.fromBundle(const {
      'meta': {'contentVersion': 'x', 'schemaVersion': 1, 'disclaimer': 'd'},
      'bodyParts': <dynamic>[],
      'guides': <dynamic>[],
      'references': <dynamic>[],
    });
    final repo = RemoteFirstGuideRepository(() async => empty, fallback);
    expect((await repo.loadCatalog()).fromFallback, isTrue);
  });

  // T-45: 검증을 통과한 원격 응답은 그대로 쓴다
  test('검증을 통과한 원격 응답은 폴백 없이 반환한다 (T-45)', () async {
    final remote = validRemote();
    final repo = RemoteFirstGuideRepository(() async => remote, fallback);
    expect((await repo.loadCatalog()).fromFallback, isFalse);
  });

  // T-46: 즐겨찾기 저장이 실패하면 화면 상태를 원래대로 되돌린다
  test('즐겨찾기 저장 실패 시 상태를 되돌린다 (T-46)', () async {
    final container = ProviderContainer(overrides: [
      favoriteRepositoryProvider.overrideWithValue(_SaveFailsFavorites()),
    ]);
    addTearDown(container.dispose);
    await container.read(favoritesProvider.future);
    await container.read(favoritesProvider.notifier).toggle('ankle_instability');
    expect(container.read(favoritesProvider).value, isEmpty);
  });

  // T-47: 즐겨찾기 불러오기가 실패해도 빈 목록으로 계속 동작한다
  test('즐겨찾기 불러오기 실패 시 빈 목록을 쓴다 (T-47)', () async {
    final container = ProviderContainer(overrides: [
      favoriteRepositoryProvider.overrideWithValue(_FailingFavorites()),
    ]);
    addTearDown(container.dispose);
    expect(await container.read(favoritesProvider.future), isEmpty);
  });

  // T-48: 검수 전 콘텐츠임을 안내 문구와 검수 상태로 분명히 알린다
  test('검수 전 안내와 중단 기준이 안내 문구에 들어 있다 (T-48)', () {
    final c = validRemote();
    expect(c.disclaimer, contains('검수를 받지 않았습니다'));
    expect(c.disclaimer, contains('진료'));
    expect(c.symptom('ankle_instability')!.review.verified, isFalse);
  });
}
