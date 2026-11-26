import '../domain/guide_models.dart';

/// 증상별 필수 단계 수 (TRD 6.2절). tool/validate_content.mjs 의 값과 같아야 한다.
const expectedSteps = {'ankle_instability': 5};

/// 오류는 `코드: 위치` 형식의 문자열이다. 코드 정의는 TRD 6.2.2절,
/// 길이 상한·허용값은 6.2.1절이며 tool/validate_content.mjs 와 같아야 한다.
const tensionValues = {'없음', '당기지 않음', '약하게'};
const referenceTypes = {'학술', '의료기관', '교육 자료', '콘텐츠 검수'};

final _versionPattern = RegExp(r'^\d+\.\d+\.\d+$');
final _datePattern = RegExp(r'^\d{4}-\d{2}-\d{2}$');

/// `연.월.일련번호` 를 세 칸으로 나눠 숫자로 비교한다. 형식 오류는 FormatException.
int compareVersions(String a, String b) {
  List<int> parse(String v) {
    if (!_versionPattern.hasMatch(v)) throw FormatException('VERSION_FORMAT: $v');
    return v.split('.').map(int.parse).toList();
  }

  final x = parse(a), y = parse(b);
  for (var i = 0; i < 3; i++) {
    if (x[i] != y[i]) return x[i].compareTo(y[i]);
  }
  return 0;
}

int _len(String s) => s.runes.length;

void _text(List<String> errors, String where, String value, int max) {
  if (value.trim().isEmpty) {
    errors.add('FIELD_EMPTY: $where');
  } else if (_len(value) > max) {
    errors.add('FIELD_LENGTH: $where');
  }
}

/// 그림 좌표가 유효 범위(x 0~210, y 0~230, 줄당 점 2개 이상)인지. 위반 시 그림만 생략한다.
bool tapeIsValid(TapeStep st) => st.tape.every(
      (line) =>
          line.length >= 2 &&
          line.every((p) => p.length == 2 && p[0] >= 0 && p[0] <= 210 && p[1] >= 0 && p[1] <= 230),
    );

/// TRD 6.2절 문서 필드 규칙. 오류 목록을 반환하며 비어 있으면 통과.
List<String> validateSymptom(Symptom s, Set<String> referenceIds, {Set<String>? bodyPartIds}) {
  final errors = <String>[];
  void checkSources(String where, List<String> ids, {required bool required}) {
    if (required && ids.isEmpty) errors.add('SOURCE_MISSING: $where');
    if (ids.length > 10) errors.add('FIELD_LENGTH: $where sources');
    if (ids.toSet().length != ids.length) errors.add('SOURCE_DUPLICATE: $where');
    for (final id in ids) {
      if (!referenceIds.contains(id)) errors.add('REF_BROKEN: $where $id');
    }
  }

  if (bodyPartIds != null && !bodyPartIds.contains(s.bodyPartId)) {
    errors.add('REF_BROKEN: ${s.id} bodyPartId');
  }
  _text(errors, '${s.id} name', s.name, 60);
  _text(errors, '${s.id} tape', s.tape, 60);
  _text(errors, '${s.id} tapeNeeded', s.tapeNeeded, 60);
  checkSources(s.id, s.sources, required: true);

  if (s.review.status != 'pending' && s.review.status != 'verified') {
    errors.add('REVIEW_INVALID: ${s.id}');
  }
  if (s.review.verified && !_datePattern.hasMatch(s.review.reviewedAt ?? '')) {
    errors.add('REVIEW_DATE_MISSING: ${s.id}');
  }
  _text(errors, '${s.id} review.reviewer', s.review.reviewer, 30);

  final want = expectedSteps[s.id];
  if (s.steps.isEmpty || (want != null && s.steps.length != want)) {
    errors.add('STEP_COUNT: ${s.id}');
  }
  final orders = s.steps.map((e) => e.order).toList()..sort();
  for (var i = 0; i < orders.length; i++) {
    if (orders[i] != i + 1) {
      errors.add('STEP_ORDER: ${s.id}');
      break;
    }
  }
  for (final st in s.steps) {
    final w = '${s.id} step ${st.order}';
    _text(errors, '$w title', st.title, 20);
    _text(errors, '$w body', st.body, 200);
    if (st.tension.trim().isEmpty) {
      errors.add('FIELD_EMPTY: $w tension');
    } else if (!tensionValues.contains(st.tension)) {
      errors.add('ENUM_INVALID: $w tension');
    }
    checkSources(w, st.sources, required: true);
    if (st.tape.length > 10) errors.add('FIELD_LENGTH: $w tape');
    if (!tapeIsValid(st)) errors.add('TAPE_RANGE: $w');
  }

  if (s.cautions.isEmpty) errors.add('CAUTION_MISSING: ${s.id}');
  if (s.cautions.length > 10) errors.add('FIELD_LENGTH: ${s.id} cautions');
  for (final c in s.cautions) {
    _text(errors, '${s.id} caution', c.text, 120);
    checkSources('${s.id} caution', c.sources, required: false);
  }
  return errors;
}

/// content/guides.json 형식의 원본 전체(미게시 포함)를 검증한다. 업로드 전 검증 스크립트와 같은 규칙이다.
List<String> validateBundle(Map<String, dynamic> json) {
  final errors = <String>[];
  final meta = Map<String, dynamic>.from(json['meta'] as Map? ?? const {});
  if (!_versionPattern.hasMatch(meta['contentVersion'] as String? ?? '')) {
    errors.add('VERSION_FORMAT: meta.contentVersion');
  }
  _text(errors, 'meta.disclaimer', meta['disclaimer'] as String? ?? '', 200);

  final refs = <String, Reference>{
    for (final e in json['references'] as List? ?? const [])
      (e as Map)['id'] as String: Reference.fromMap(e['id'] as String, Map<String, dynamic>.from(e)),
  };
  for (final r in refs.values) {
    if (!referenceTypes.contains(r.type)) errors.add('ENUM_INVALID: ${r.id} type');
    _text(errors, '${r.id} title', r.title, 200);
    if (r.url.isNotEmpty && (_len(r.url) > 500 || !r.url.startsWith('https://'))) {
      errors.add('FIELD_LENGTH: ${r.id} url');
    }
  }

  final partIds = {for (final p in json['bodyParts'] as List? ?? const []) (p as Map)['id'] as String};
  for (final g in json['guides'] as List? ?? const []) {
    final m = Map<String, dynamic>.from(g as Map);
    final s = Symptom.fromMap(m['id'] as String, m);
    errors.addAll(validateSymptom(s, refs.keys.toSet(), bodyPartIds: partIds));
  }
  return errors;
}

/// 앱이 읽어 온 카탈로그 검증. TAPE_RANGE 는 그림만 생략하므로 증상 제외 사유에서 뺀다.
List<String> validateCatalog(GuideCatalog c) {
  final ids = c.references.keys.toSet();
  return [
    if (!_versionPattern.hasMatch(c.contentVersion)) 'VERSION_FORMAT: meta.contentVersion',
    for (final p in c.bodyParts)
      for (final s in p.symptoms)
        ...validateSymptom(s, ids).where((e) => !e.startsWith('TAPE_RANGE')),
  ];
}
