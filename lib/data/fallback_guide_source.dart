import '../domain/guide_models.dart';
import 'guide_content.dart';

class FallbackGuideSource {
  Future<GuideCatalog> load() async {
    return GuideCatalog.fromBundle(
      Map<String, dynamic>.from(bundledGuideContent),
      fromFallback: true,
    );
  }
}
