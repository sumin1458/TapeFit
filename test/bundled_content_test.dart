import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:tapefit/core/validation.dart';
import 'package:tapefit/data/guide_content.dart';

Object? _json(String path) => jsonDecode(File(path).readAsStringSync());

void main() {
  test('T-35 Dart 번들 콘텐츠가 content/guides.json, assets 사본과 같다', () {
    final expected = _json('content/guides.json');
    expect(jsonDecode(jsonEncode(bundledGuideContent)), expected);
    expect(_json('assets/fallback/guides.json'), expected);
  });

  test('T-36 번들 콘텐츠는 5단계이고 각 단계에 출처가 있다', () {
    final guide = (bundledGuideContent['guides'] as List).first as Map;
    final steps = guide['steps'] as List;
    expect(steps.length, 5);
    expect(steps.map((s) => (s as Map)['title']),
        ['피부 준비', '분홍 테이프', '주황 X 테이프', '파랑 감기 테이프', '마무리 확인']);
    for (final s in steps) {
      expect(((s as Map)['sources'] as List), isNotEmpty);
    }
  });

  test('T-37 번들 콘텐츠가 검증 규칙을 통과한다', () {
    final errors = validateBundle(Map<String, dynamic>.from(bundledGuideContent));
    expect(errors, isEmpty);
  });
}
