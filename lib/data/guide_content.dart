/// ?? ??? ??? (??????? ?? ? ??).
///
/// `content/guides.json`, `assets/fallback/guides.json` ? ??? ??? ??,
/// `test/bundled_content_test.dart` ? ? ??? ??? ????.
/// ??? `ankle_instability` ? 5??(?? ??, ??, ???, ???, ??? ??)??
/// ? ??? `tape` ? ?? ?? ??, `sources` ? ?? ID ??.
const Map<String, dynamic> bundledGuideContent = {
  'meta': {
    'contentVersion': '2026.11.1',
    'schemaVersion': 1,
    'disclaimer': '일반 참고용이며 아직 의료 전문가의 검수를 받지 않았습니다. 의학적 진단·치료를 대체하지 않습니다. 통증·붓기·저림이 심해지거나 걷기 어려우면 중단하고 진료를 받으세요.',
  },
  'bodyParts': [
    {
      'id': 'ankle',
      'name': '발목',
      'available': true,
      'order': 1,
    },
    {
      'id': 'knee',
      'name': '무릎',
      'available': false,
      'order': 2,
    },
    {
      'id': 'wrist',
      'name': '손목',
      'available': false,
      'order': 3,
    },
    {
      'id': 'shoulder',
      'name': '어깨',
      'available': false,
      'order': 4,
    },
    {
      'id': 'back',
      'name': '허리',
      'available': false,
      'order': 5,
    },
  ],
  'guides': [
    {
      'id': 'ankle_instability',
      'bodyPartId': 'ankle',
      'name': '발목 불안정감 (가벼운 염좌 후)',
      'tape': '리지드 테이프 + 언더랩',
      'tapeNeeded': '리지드 테이프, 언더랩, 가위',
      'sources': ['S3', 'S5', 'S6'],
      'published': true,
      'review': {
        'status': 'pending',
        'reviewer': '미정',
        'reviewedAt': null,
      },
      'steps': [
        {
          'order': 1,
          'title': '피부 준비',
          'body': '땀과 오염을 씻고 말리세요. 발목을 90°로 세운 준비 자세를 유지하고, 체모는 제거하세요. 상처는 거즈로 덮으세요.',
          'tension': '없음',
          'sources': ['S3'],
          'tape': [],
        },
        {
          'order': 2,
          'title': '분홍 테이프',
          'body': '5칸 길이 테이프를 가운데를 찢어, 발바닥 쪽에서 시작해 발 양옆과 종아리 옆면을 따라 위로 붙이세요. 양옆으로 당겨 붙입니다.',
          'tension': '약하게',
          'sources': ['S4'],
          'tape': [
            [
              [82, 100],
              [82, 150],
              [86, 190],
              [105, 206],
              [124, 190],
              [128, 150],
              [128, 100],
            ],
          ],
        },
        {
          'order': 3,
          'title': '주황 X 테이프',
          'body': '7칸 길이 테이프를 가운데를 찢어, 복숭아뼈 아래를 지나가게 발등 앞에서 X자로 엇갈려 붙이세요.',
          'tension': '약하게',
          'sources': ['S4'],
          'tape': [
            [
              [74, 185],
              [78, 168],
              [105, 134],
              [132, 100],
            ],
            [
              [136, 185],
              [132, 168],
              [105, 134],
              [78, 100],
            ],
          ],
        },
        {
          'order': 4,
          'title': '파랑 감기 테이프',
          'body': '4칸 길이 테이프를 발목뼈가 움직이는 지점 높이에서 바깥쪽에서 안쪽으로 감아 붙이세요.',
          'tension': '약하게',
          'sources': ['S4'],
          'tape': [
            [
              [132, 140],
              [78, 146],
              [132, 152],
              [78, 158],
            ],
          ],
        },
        {
          'order': 5,
          'title': '마무리 확인',
          'body': '앤드로 끝맺고, 조이거나 아프면 떼고 다시 붙이세요. 피부가 창백하거나 테이프가 파고들면 너무 강한 것입니다.',
          'tension': '당기지 않음',
          'sources': ['S3'],
          'tape': [
            [
              [80, 116],
              [130, 116],
            ],
            [
              [80, 128],
              [130, 128],
            ],
          ],
        },
      ],
      'cautions': [
        {
          'text': '조이거나 아프면 다시 붙이고, 붙인 테이프 위에 덧붙이지 말고, 구김 없이 붙이세요.',
          'sources': ['S3'],
        },
        {
          'text': '매일 반복해 붙인다면 피부 보호를 위해 언더랩을 사용하세요.',
          'sources': ['S3'],
        },
        {
          'text': '골절·탈구가 의심되면 테이핑만 믿고 움직이지 마세요.',
          'sources': ['S3'],
        },
        {
          'text': '붓기·멍이 심하거나 체중을 실을 수 없으면 테이핑 전에 전문의 진료를 받으세요.',
          'sources': ['S6'],
        },
        {
          'text': '붙이기 전 알레르기·피부 상처를 확인하고, 붙인 뒤 저림·색 변화가 있으면 즉시 제거하세요.',
          'sources': ['S5'],
        },
        {
          'text': '붙인 채로 오래 두지 말고, 불편하면 바로 제거하세요.',
          'sources': ['S4'],
        },
      ],
    },
  ],
  'references': [
    {
      'id': 'S1',
      'type': '학술',
      'title': 'Kinesio Taping 급성 발목 염좌 체계적 문헌고찰, Journal of Clinical Medicine 2025, 14(5), 1440',
      'url': 'https://www.mdpi.com/2077-0383/14/5/1440',
    },
    {
      'id': 'S2',
      'type': '학술',
      'title': 'Is Kinesio taping an effective approach for acute ankle sprains? A systematic review and meta-analysis (2026)',
      'url': 'https://www.sciencedirect.com/org/science/article/pii/S2058524126000332',
    },
    {
      'id': 'S3',
      'type': '의료기관',
      'title': '서울대학교병원 의학정보 "테이핑 요법"',
      'url': 'https://www.snuh.org/health/nMedInfo/nView.do?medid=BB000097',
    },
    {
      'id': 'S4',
      'type': '콘텐츠 검수',
      'title': '팀 내부 콘텐츠 검수 (전문가 검수 예정)',
      'url': '',
    },
    {
      'id': 'S5',
      'type': '교육 자료',
      'title': 'Athletic Therapy Skills, "Ankle Inversion and Eversion"',
      'url': 'https://pressbooks.openedmb.ca/athletictherapy/chapter/ankle-inversion-and-eversion/',
    },
    {
      'id': 'S6',
      'type': '의료기관',
      'title': '서울대학교병원 의학정보 "발목염좌"',
      'url': 'https://www.snuh.org/health/nMedInfo/nView.do?medid=AA000550',
    },
  ],
};
