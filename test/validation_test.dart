import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/core/validation.dart';
import 'package:tapefit/domain/guide_models.dart';

GuideCatalog load() => GuideCatalog.fromBundle(
      Map<String, dynamic>.from(jsonDecode(File('content/guides.json').readAsStringSync()) as Map),
    );

void main() {
  test('콘텐츠 원본이 검증 규칙을 통과한다', () {
    expect(validateCatalog(load()), isEmpty);
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
    final json = Map<String, dynamic>.from(
      jsonDecode(File('content/guides.json').readAsStringSync()) as Map,
    );
    (json['guides'] as List).first['published'] = false;
    expect(GuideCatalog.fromBundle(json).symptom('ankle_instability'), isNull);
  });
}
