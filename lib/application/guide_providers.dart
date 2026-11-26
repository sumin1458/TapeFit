import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/fallback_guide_source.dart';
import '../data/favorite_repository.dart';
import '../data/firestore_guide_repository.dart';
import '../domain/guide_models.dart';
import '../domain/guide_repository.dart';

/// main.dart 에서 Firebase 초기화 결과에 따라 override 한다.
final guideRepositoryProvider = Provider<GuideRepository>(
  (ref) => BundledGuideRepository(FallbackGuideSource()),
);

final favoriteRepositoryProvider = Provider<FavoriteRepository>(
  (ref) => LocalFavoriteRepository(),
);

final catalogProvider = FutureProvider<GuideCatalog>(
  (ref) => ref.watch(guideRepositoryProvider).loadCatalog(),
);

final symptomProvider = Provider.family<AsyncValue<Symptom?>, String>(
  (ref, id) => ref.watch(catalogProvider).whenData((c) => c.symptom(id)),
);

class FavoritesNotifier extends AsyncNotifier<Set<String>> {
  @override
  Future<Set<String>> build() async {
    try {
      return await ref.read(favoriteRepositoryProvider).loadFavorites();
    } catch (_) {
      return <String>{};
    }
  }

  Future<void> toggle(String symptomId) async {
    final current = {...(state.value ?? <String>{})};
    final add = !current.contains(symptomId);
    add ? current.add(symptomId) : current.remove(symptomId);
    state = AsyncData(current); // 낙관적 반영
    try {
      await ref.read(favoriteRepositoryProvider).setFavorite(symptomId, add);
    } catch (_) {
      add ? current.remove(symptomId) : current.add(symptomId);
      state = AsyncData(current);
    }
  }
}

final favoritesProvider =
    AsyncNotifierProvider<FavoritesNotifier, Set<String>>(FavoritesNotifier.new);
