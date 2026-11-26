import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

import '../domain/guide_models.dart';

class FallbackGuideSource {
  Future<GuideCatalog> load() async {
    final raw = await rootBundle.loadString('assets/fallback/guides.json');
    return GuideCatalog.fromBundle(
      Map<String, dynamic>.from(jsonDecode(raw) as Map),
      fromFallback: true,
    );
  }
}
