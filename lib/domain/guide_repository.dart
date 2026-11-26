import 'guide_models.dart';

abstract class GuideRepository {
  Future<GuideCatalog> loadCatalog();
}

abstract class FavoriteRepository {
  Future<Set<String>> loadFavorites();
  Future<void> setFavorite(String symptomId, bool value);
}
