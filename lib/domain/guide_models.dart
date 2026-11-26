import 'package:flutter/foundation.dart';

@immutable
class Reference {
  const Reference({required this.id, required this.type, required this.title, required this.url});
  final String id;
  final String type;
  final String title;
  final String url;

  factory Reference.fromMap(String id, Map<String, dynamic> m) => Reference(
        id: id,
        type: m['type'] as String? ?? '',
        title: m['title'] as String? ?? '',
        url: m['url'] as String? ?? '',
      );
}

@immutable
class Review {
  const Review({required this.status, required this.reviewer, this.reviewedAt});
  final String status; // pending | verified
  final String reviewer;
  final String? reviewedAt;

  bool get verified => status == 'verified';

  factory Review.fromMap(Map<String, dynamic> m) {
    final at = m['reviewedAt'];
    return Review(
      status: m['status'] as String? ?? 'pending',
      reviewer: m['reviewer'] as String? ?? '',
      reviewedAt: at == null ? null : at.toString(),
    );
  }

  String get label => verified ? '검수 완료 ($reviewedAt)' : '$reviewer 검수 전';
}

List<String> _strings(dynamic v) => (v as List? ?? const []).map((e) => e.toString()).toList();

@immutable
class Caution {
  const Caution({required this.text, required this.sources});
  final String text;
  final List<String> sources;

  factory Caution.fromMap(Map<String, dynamic> m) =>
      Caution(text: m['text'] as String? ?? '', sources: _strings(m['sources']));
}

@immutable
class TapeStep {
  const TapeStep({
    required this.order,
    required this.title,
    required this.body,
    required this.tension,
    required this.sources,
    required this.tape,
  });
  final int order;
  final String title;
  final String body;
  final String tension;
  final List<String> sources;

  /// 테이프 줄(polyline) 목록. 각 줄은 [x, y] 점의 목록.
  final List<List<List<double>>> tape;

  factory TapeStep.fromMap(Map<String, dynamic> m) => TapeStep(
        order: (m['order'] as num?)?.toInt() ?? 0,
        title: m['title'] as String? ?? '',
        body: m['body'] as String? ?? '',
        tension: m['tension'] as String? ?? '',
        sources: _strings(m['sources']),
        tape: (m['tape'] as List? ?? const [])
            .map((line) => (line as List)
                .map((p) => (p as List).map((n) => (n as num).toDouble()).toList())
                .toList())
            .toList(),
      );
}

@immutable
class Symptom {
  const Symptom({
    required this.id,
    required this.bodyPartId,
    required this.name,
    required this.tape,
    required this.tapeNeeded,
    required this.sources,
    required this.review,
    required this.steps,
    required this.cautions,
  });
  final String id;
  final String bodyPartId;
  final String name;
  final String tape;
  final String tapeNeeded;
  final List<String> sources;
  final Review review;
  final List<TapeStep> steps;
  final List<Caution> cautions;

  factory Symptom.fromMap(String id, Map<String, dynamic> m) {
    final steps = (m['steps'] as List? ?? const [])
        .map((e) => TapeStep.fromMap(Map<String, dynamic>.from(e as Map)))
        .toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    return Symptom(
      id: id,
      bodyPartId: m['bodyPartId'] as String? ?? '',
      name: m['name'] as String? ?? '',
      tape: m['tape'] as String? ?? '',
      tapeNeeded: m['tapeNeeded'] as String? ?? '',
      sources: _strings(m['sources']),
      review: Review.fromMap(Map<String, dynamic>.from(m['review'] as Map? ?? const {})),
      steps: steps,
      cautions: (m['cautions'] as List? ?? const [])
          .map((e) => Caution.fromMap(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

@immutable
class BodyPart {
  const BodyPart({
    required this.id,
    required this.name,
    required this.available,
    required this.order,
    required this.symptoms,
  });
  final String id;
  final String name;
  final bool available;
  final int order;
  final List<Symptom> symptoms;
}

@immutable
class GuideCatalog {
  const GuideCatalog({
    required this.contentVersion,
    required this.disclaimer,
    required this.bodyParts,
    required this.references,
    this.fromFallback = false,
  });
  final String contentVersion;
  final String disclaimer;
  final List<BodyPart> bodyParts;
  final Map<String, Reference> references;

  /// 번들 폴백 데이터로 만든 카탈로그인지 (오프라인 안내 배너에 사용)
  final bool fromFallback;

  Symptom? symptom(String id) {
    for (final p in bodyParts) {
      for (final s in p.symptoms) {
        if (s.id == id) return s;
      }
    }
    return null;
  }

  /// content/guides.json 과 같은 형식의 맵으로 카탈로그를 만든다.
  /// published 가 true 인 가이드만 포함한다.
  factory GuideCatalog.fromBundle(Map<String, dynamic> json, {bool fromFallback = false}) {
    final meta = Map<String, dynamic>.from(json['meta'] as Map);
    final guides = (json['guides'] as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .where((g) => g['published'] == true)
        .map((g) => Symptom.fromMap(g['id'] as String, g))
        .toList();
    final parts = (json['bodyParts'] as List).map((e) {
      final m = Map<String, dynamic>.from(e as Map);
      final id = m['id'] as String;
      return BodyPart(
        id: id,
        name: m['name'] as String? ?? '',
        available: m['available'] == true,
        order: (m['order'] as num?)?.toInt() ?? 0,
        symptoms: guides.where((g) => g.bodyPartId == id).toList(),
      );
    }).toList()
      ..sort((a, b) => a.order.compareTo(b.order));
    final refs = <String, Reference>{
      for (final e in json['references'] as List)
        (e as Map)['id'] as String: Reference.fromMap(e['id'] as String, Map<String, dynamic>.from(e)),
    };
    return GuideCatalog(
      contentVersion: meta['contentVersion'] as String? ?? '',
      disclaimer: meta['disclaimer'] as String? ?? '',
      bodyParts: parts,
      references: refs,
      fromFallback: fromFallback,
    );
  }
}
