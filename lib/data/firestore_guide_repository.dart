import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/validation.dart';
import '../domain/guide_models.dart';
import '../domain/guide_repository.dart';
import 'fallback_guide_source.dart';

/// 원격 우선 조회. 실패·시간 초과·검증 실패 시 번들 폴백을 반환한다.
class RemoteFirstGuideRepository implements GuideRepository {
  RemoteFirstGuideRepository(
    this._fetch,
    this._fallback, {
    this.timeout = const Duration(seconds: 8),
  });

  final Future<GuideCatalog> Function() _fetch;
  final FallbackGuideSource _fallback;
  final Duration timeout;

  @override
  Future<GuideCatalog> loadCatalog() async {
    try {
      final catalog = await _fetch().timeout(timeout);
      final hasGuide = catalog.bodyParts.any((p) => p.symptoms.isNotEmpty);
      if (!hasGuide || validateCatalog(catalog).isNotEmpty) {
        throw StateError('invalid remote content');
      }
      return catalog;
    } catch (_) {
      return _fallback.load();
    }
  }
}

/// Firestore에서 읽어 온다.
class FirestoreGuideRepository extends RemoteFirstGuideRepository {
  FirestoreGuideRepository(FirebaseFirestore db, FallbackGuideSource fallback)
      : super(() => _fetchFrom(db), fallback);

  static Future<GuideCatalog> _fetchFrom(FirebaseFirestore db) async {
    final results = await Future.wait([
      db.collection('meta').doc('app').get(),
      db.collection('bodyParts').get(),
      db.collection('guides').where('published', isEqualTo: true).get(),
      db.collection('references').get(),
    ]);
    final meta = (results[0] as DocumentSnapshot<Map<String, dynamic>>).data();
    if (meta == null) throw StateError('meta/app missing');
    final parts = results[1] as QuerySnapshot<Map<String, dynamic>>;
    final guides = results[2] as QuerySnapshot<Map<String, dynamic>>;
    final refs = results[3] as QuerySnapshot<Map<String, dynamic>>;

    return GuideCatalog.fromBundle({
      'meta': meta,
      'bodyParts': [for (final d in parts.docs) {...d.data(), 'id': d.id}],
      'guides': [for (final d in guides.docs) {...d.data(), 'id': d.id}],
      'references': [for (final d in refs.docs) {...d.data(), 'id': d.id}],
    });
  }
}

/// Firebase를 쓸 수 없을 때(미설정·오프라인) 번들 데이터만 사용한다.
class BundledGuideRepository implements GuideRepository {
  BundledGuideRepository(this._fallback);
  final FallbackGuideSource _fallback;

  @override
  Future<GuideCatalog> loadCatalog() => _fallback.load();
}
