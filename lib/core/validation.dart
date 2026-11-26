import '../domain/guide_models.dart';

/// TRD 6.2절 문서 필드 규칙. 오류 메시지 목록을 반환하며 비어 있으면 통과.
List<String> validateSymptom(Symptom s, Set<String> referenceIds) {
  final errors = <String>[];
  void checkSources(String where, List<String> ids) {
    for (final id in ids) {
      if (!referenceIds.contains(id)) errors.add('$where: 존재하지 않는 출처 $id');
    }
  }

  if (s.name.isEmpty) errors.add('${s.id}: 이름이 비어 있음');
  if (s.sources.isEmpty) errors.add('${s.id}: 출처가 없음');
  checkSources(s.id, s.sources);
  if (s.review.status != 'pending' && s.review.status != 'verified') {
    errors.add('${s.id}: review.status 값 오류');
  }
  if (s.review.verified && (s.review.reviewedAt == null || s.review.reviewedAt!.isEmpty)) {
    errors.add('${s.id}: 검수 완료인데 검수 일자가 없음');
  }
  if (s.steps.isEmpty) errors.add('${s.id}: 단계가 없음');
  for (final st in s.steps) {
    final w = '${s.id} 단계 ${st.order}';
    if (st.title.isEmpty || st.body.isEmpty) errors.add('$w: 제목/본문이 비어 있음');
    if (st.tension.isEmpty) errors.add('$w: 당김 강도가 없음');
    if (st.sources.isEmpty) errors.add('$w: 출처가 없음');
    checkSources(w, st.sources);
  }
  if (s.cautions.isEmpty) errors.add('${s.id}: 주의사항이 없음');
  for (final c in s.cautions) {
    if (c.text.isEmpty) errors.add('${s.id}: 비어 있는 주의사항');
    checkSources('${s.id} 주의사항', c.sources);
  }
  return errors;
}

List<String> validateCatalog(GuideCatalog c) {
  final ids = c.references.keys.toSet();
  return [
    for (final p in c.bodyParts)
      for (final s in p.symptoms) ...validateSymptom(s, ids),
  ];
}
