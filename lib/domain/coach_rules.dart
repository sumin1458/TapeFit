/// AI검사 코치의 점검 규칙. 사진을 분석하는 AI가 아니라, 사용자가 단계별 질문에 답하면
/// 가이드(`content/guides.json`)와 다른 점을 골라 수정할 점을 알려 주는 규칙 기반 코치다.
/// 모든 안내 문구는 가이드 단계 문구와 주의사항(출처 S3·S5·S6)에서 가져왔다.
class CoachItem {
  const CoachItem(this.question, this.fix, {this.urgent = false});

  /// "예"가 가이드대로라는 뜻이 되도록 쓴 질문.
  final String question;

  /// "아니요"일 때 보여 주는 수정·보완 안내.
  final String fix;

  /// 몸에 이상 신호가 있는 항목. 즉시 제거 안내를 함께 보여 준다.
  final bool urgent;
}

/// 가이드 단계 인덱스(0 = 피부 준비 … 4 = 마무리 확인)별 점검 항목.
const coachRules = <int, List<CoachItem>>{
  0: [
    CoachItem('땀과 오염을 씻고 완전히 말렸나요?', '땀과 오염을 씻고 말린 뒤에 붙이세요.'),
    CoachItem('붙일 부위의 체모를 제거했나요?', '체모는 제거하고 붙이세요.'),
    CoachItem('상처가 있다면 거즈로 덮었나요?', '상처는 거즈로 덮으세요. 피부 이상이 있으면 테이핑 대신 진료를 받으세요.'),
    CoachItem('피부 보호용 언더랩을 먼저 감았나요?', '피부 보호를 위해 언더랩을 먼저 감으세요.'),
  ],
  1: [
    CoachItem('테이프가 종아리 근육 바로 아래쪽에 있나요?', '화면의 가이드선처럼 종아리 근육 바로 아래쪽으로 옮겨 붙이세요.'),
    CoachItem('테이프를 2~3줄 둘러 붙였나요?', '2~3줄을 둘러 시작점을 고정하세요.'),
    CoachItem('테이프를 당기지 않고 붙였나요?', '앵커는 당기지 않고 붙여요. 조이면 떼고 다시 붙이세요.'),
    CoachItem('구김 없이 붙어 있나요?', '구김 없이 다시 붙이세요. 붙인 테이프 위에 덧붙이지 마세요.'),
  ],
  2: [
    CoachItem('발 안쪽에서 뒤꿈치 아래를 지나 바깥쪽으로 U자로 붙였나요?', '발 안쪽 → 뒤꿈치 아래 → 바깥쪽 순서로 U자가 되게 다시 붙이세요.'),
    CoachItem('총 3줄을 붙였나요?', '스터럽은 총 3줄을 붙여요. 빠진 줄을 추가하세요.'),
    CoachItem('세게 당기지 않고 약하게 붙였나요?', '약하게 붙여야 해요. 세게 당겼다면 떼고 다시 붙이세요.'),
    CoachItem('줄의 양 끝이 앵커 테이프 위에 닿아 있나요?', '양 끝이 앵커 위에 오도록 위치를 맞추세요.'),
  ],
  3: [
    CoachItem('스터럽을 고정하도록 말발굽 모양으로 붙였나요?', '스터럽 위로 말발굽 모양이 되게 다시 붙이세요.'),
    CoachItem('발목이 좌우로 흔들리지 않나요?', '흔들리면 스터럽을 고정하는 위치인지 확인하고 다시 붙이세요.'),
    CoachItem('약하게 붙였나요?', '약하게 붙여야 해요. 세게 당겼다면 떼고 다시 붙이세요.'),
  ],
  4: [
    CoachItem('조이거나 아픈 곳이 없나요?', '조이거나 아프면 떼고 다시 붙이세요.'),
    CoachItem('피부가 창백하거나 테이프가 파고들지 않나요?', '너무 강하게 붙인 것이에요. 떼고 더 약하게 다시 붙이세요.', urgent: true),
    CoachItem('저림이나 피부 색 변화가 없나요?', '저림·색 변화가 있으면 즉시 제거하세요.', urgent: true),
  ],
};

class CoachReport {
  const CoachReport({required this.fixes, required this.pending});

  /// "아니요"로 답한 항목.
  final List<CoachItem> fixes;

  /// 아직 답하지 않은 항목 수.
  final int pending;

  bool get complete => pending == 0;
  bool get allGood => complete && fixes.isEmpty;
  bool get urgent => fixes.any((f) => f.urgent);
}

/// [answers]: 항목 인덱스 → true(예) / false(아니요). 없으면 미응답.
CoachReport evaluateCoach(int stepIndex, Map<int, bool> answers) {
  final items = coachRules[stepIndex] ?? const <CoachItem>[];
  final fixes = <CoachItem>[];
  var pending = 0;
  for (var i = 0; i < items.length; i++) {
    final a = answers[i];
    if (a == null) {
      pending++;
    } else if (!a) {
      fixes.add(items[i]);
    }
  }
  return CoachReport(fixes: fixes, pending: pending);
}
