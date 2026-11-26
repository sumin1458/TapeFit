import '../domain/guide_models.dart';

/// 증상별 필수 단계 수 (TRD 6.2절). tool/validate_content.mjs 의 값과 같아야 한다.
const expectedSteps = {'ankle_instability': 5};

final _versionPattern = RegExp(r'^\d+\.\d+\.\d+$');

/// `연.월.일련번호` 를 앞 칸부터 숫자로 비교한다. 형식 오류는 FormatException.
int compareVersions(String a, String b) {
  List<int> parse(String v) {
    if (!_versionPattern.hasMatch(v)) throw FormatException('잘못된 버전 형식: $v');
    return v.split('.').map(int.parse).toList();
  }

  final x = parse(a), y = parse(b);
  for (var i = 0; i < 3; i++) {
    if (x[i] != y[i]) return x[i].compareTo(y[i]);
  }
  return 0;
}

/// TRD 6.2절 문서 필드 규칙. 오류 메시지 목록을 반환하며 비어 있으면 통과.
List<String> validateSymptom(Symptom s, Set<String> referenceIds) {
  final errors = <String>[];
  void checkSources(String where, List<String> ids) {
    if (ids.toSet().length != ids.length) errors.add('$where: 중복된 출처');
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
  final want = expectedSteps[s.id];
  if (want != null && s.steps.length != want) {
    errors.add('${s.id}: 단계 수 ${s.steps.length} (필요 $want)');
  }
  final orders = s.steps.map((e) => e.order).toList()..sort();
  for (var i = 0; i < orders.length; i++) {
    if (orders[i] != i + 1) {
      errors.add('${s.id}: 단계 order 가 1부터 연속·중복 없음이 아님');
      break;
    }
  }
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

/// 그림 좌표가 유효 범위(x 0~210, y 0~230, 줄당 점 2개 이상)인지. 위반 시 그림만 생략한다.
bool tapeIsValid(TapeStep st) => st.tape.every(
      (line) =>
          line.length >= 2 &&
          line.every((p) => p.length == 2 && p[0] >= 0 && p[0] <= 210 && p[1] >= 0 && p[1] <= 230),
    );

List<String> validateCatalog(GuideCatalog c) {
  final ids = c.references.keys.toSet();
  return [
    if (!_versionPattern.hasMatch(c.contentVersion)) 'meta: contentVersion 형식 오류',
    for (final p in c.bodyParts)
      for (final s in p.symptoms) ...validateSymptom(s, ids),
  ];
}
