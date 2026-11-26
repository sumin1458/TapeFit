import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/core/validation.dart';
import 'package:tapefit/domain/guide_models.dart';

Map<String, dynamic> loadJson() =>
    Map<String, dynamic>.from(jsonDecode(File('content/guides.json').readAsStringSync()) as Map);

GuideCatalog load() => GuideCatalog.fromBundle(loadJson());

dynamic resolveValue(dynamic v) =>
    v is Map && v.containsKey(r'$repeat') ? (v[r'$repeat'] as String) * (v['count'] as int) : v;

void setPath(Map<String, dynamic> root, String path, dynamic value) {
  final keys = path.split('.');
  dynamic node = root;
  for (final k in keys.take(keys.length - 1)) {
    node = node is List ? node[int.parse(k)] : node[k];
  }
  final last = keys.last;
  if (node is List) {
    node[int.parse(last)] = resolveValue(value);
  } else {
    (node as Map)[last] = resolveValue(value);
  }
}

void main() {
  test('콘텐츠 원본이 검증 규칙을 통과한다', () {
    expect(validateCatalog(load()), isEmpty);
    expect(validateBundle(loadJson()), isEmpty);
  });

  test('발목 가이드는 5단계이고 모든 단계에 출처가 있다', () {
    final s = load().symptom('ankle_instability')!;
    expect(s.steps, hasLength(5));
    expect(s.steps.every((st) => st.sources.isNotEmpty), isTrue);
  });

  test('존재하지 않는 출처를 참조하면 오류가 난다', () {
    final s = load().symptom('ankle_instability')!;
    expect(validateSymptom(s, {'S3'}), isNotEmpty);
  });

  test('published 가 false 인 가이드는 카탈로그에서 제외된다', () {
    final json = loadJson();
    (json['guides'] as List).first['published'] = false;
    expect(GuideCatalog.fromBundle(json).symptom('ankle_instability'), isNull);
  });

  test('버전 비교는 칸별 숫자로 하고 형식 오류는 예외를 던진다', () {
    expect(compareVersions('2026.11.10', '2026.11.9'), greaterThan(0));
    expect(compareVersions('2026.11.1', '2026.11.1'), 0);
    expect(() => compareVersions('v1', '2026.11.1'), throwsFormatException);
  });

  // T-25: Node 쪽은 tool/validate_content.test.mjs 가 같은 파일로 확인한다.
  group('잘못된 데이터 사례를 모두 거부한다 (T-25)', () {
    final cases = (jsonDecode(File('test/fixtures/invalid_cases.json').readAsStringSync()) as List)
        .map((e) => Map<String, dynamic>.from(e as Map))
        .toList();
    for (final c in cases) {
      test('${c['name']} → ${c['code']}', () {
        final json = loadJson();
        (c['set'] as Map).forEach((path, value) => setPath(json, path as String, value));
        final errors = validateBundle(json);
        expect(errors.any((e) => e.startsWith(c['code'] as String)), isTrue, reason: errors.join(' | '));
      });
    }
  });
}
