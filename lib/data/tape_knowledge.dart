/// 테이핑 소개·용어 사전의 근거 자료. 각 항목은 아래 출처에서 확인한 내용만 담았다.
/// 논문 전문을 직접 확인한 것은 K1·K2·K4·K5(오픈액세스 전문)이고, K3은 제조사 설명, K6은 초록이다.
class KnowledgeSource {
  const KnowledgeSource(this.id, this.type, this.title, this.url);
  final String id;
  final String type;
  final String title;
  final String url;
}

const knowledgeSources = <KnowledgeSource>[
  KnowledgeSource('K1', '학술 논문',
      'Liu K 외, "Short-Term Effect of Different Taping Methods on Local Skin Temperature in Healthy Adults", Front Physiol 2020;11:488',
      'https://doi.org/10.3389/fphys.2020.00488'),
  KnowledgeSource('K2', '학술 논문',
      'Naugle KE 외, "Effect of different Kinesio tape tensions on experimentally-induced thermal and muscle pain in healthy adults", PLoS One 2021;16(11):e0259433',
      'https://doi.org/10.1371/journal.pone.0259433'),
  KnowledgeSource('K3', '제조사 자료', 'Kinesio Taping, "What is Kinesio Tape?" (제조사 설명)',
      'https://kinesiotaping.com/about/what-is-kinesio-tape/'),
  KnowledgeSource('K4', '학술 논문',
      'Ankle bracing and taping과 테니스 선수 수행력 무작위대조시험, BMC Sports Sci Med Rehabil 2026 (PMC12990392)',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC12990392/'),
  KnowledgeSource('K5', '학술 논문',
      'Effects of Dynamic Taping on Dynamic Balance and Proprioception in Recreational Athletes with Chronic Ankle Instability, Int J Sports Phys Ther 2026 (PMC13327846)',
      'https://pmc.ncbi.nlm.nih.gov/articles/PMC13327846/'),
  KnowledgeSource('K6', '체계적 문헌고찰',
      '"The Effects of Rigid and Elastic Adhesive Tape on Pain in Musculoskeletal and Sports Conditions: A Systematic Review With Meta-Analysis of RCTs" (초록 확인)',
      'https://researchportal.scu.edu.au/esploro/outputs/journalArticle/The-Effects-of-Rigid-and-Elastic/991013332428602368'),
  KnowledgeSource('S5', '교육 자료', 'Athletic Therapy Skills, "Ankle Inversion and Eversion"',
      'https://pressbooks.openedmb.ca/athletictherapy/chapter/ankle-inversion-and-eversion/'),
];

class TapeType {
  const TapeType({required this.name, required this.kind, required this.points, required this.sources});
  final String name;
  final String kind;
  final List<String> points;
  final List<String> sources;
}

const tapeTypes = <TapeType>[
  TapeType(
    name: '키네시오 테이프 (탄성 테이프)',
    kind: '신축성 있음',
    points: [
      '탄성이 있는 접착 테이프로, 피부와 비슷한 두께이고 원래 길이의 최대 약 40%까지 늘어나요.',
      '1970년대 초 Kenzo Kase 박사가 개발한 최초의 탄성 접착 테이프로 알려져 있어요(제조사 설명).',
      '제조사는 면 소재·아크릴 접착제·라텍스 프리·방수이며 여러 날 붙여 둘 수 있다고 설명해요.',
      '한 방향으로만 늘어나는 점이 다이나믹 테이프와 달라요.',
    ],
    sources: ['K1', 'K2', 'K3', 'K5'],
  ),
  TapeType(
    name: '비신축 테이프 (경성·리지드·애슬레틱 테이프)',
    kind: '신축성 없음',
    points: [
      '늘어나지 않는 접착 테이프로, 관절을 고정해 보호하는 데 쓰여요.',
      '발목에서는 비신축 테이프로 앵커·스터럽·말발굽·힐락을 만들고, 피부 보호용 막을 먼저 대요.',
      '전통적인 비신축 발목 테이핑은 발바닥쪽 굽힘(저측굴곡)과 안쪽 뒤집힘(내번) 가동범위를 줄이는 것으로 보고돼요.',
    ],
    sources: ['K1', 'K4'],
  ),
  TapeType(
    name: '다이나믹 테이프 (탄성 테이프)',
    kind: '여러 방향 신축',
    points: [
      '여러 방향으로 늘어나고 고무줄처럼 탄성이 커서, 움직임을 막지 않으면서 지지하도록 설계된 탄성 테이프예요.',
      '연구에서는 앵커를 만든 뒤 말발굽·스터럽·8자·힐락 같은 방법으로 붙였어요.',
    ],
    sources: ['K5'],
  ),
];

/// 탄성 테이프와 비신축 테이프를 비교한 메타분석 요약(무테이프 대비).
const tapeComparisonNote =
    '메타분석에서 탄성 테이프는 붙인 직후·아주 단기의 통증 감소에서, 비신축 테이프는 중기 통증 감소에서 '
    '테이프를 붙이지 않은 경우보다 효과적이었어요. 두 테이프의 우열을 정한 결과가 아니고, 연구마다 방법이 달라 '
    '결과 해석에 한계가 있어요.';

/// 키네시오 테이프를 자르는 모양.
class StripShape {
  const StripShape({required this.id, required this.name, required this.cut, required this.use, required this.sources});
  final String id; // i, o, x, y, fan
  final String name;
  final String cut;
  final String use;
  final List<String> sources;
}

const stripShapes = <StripShape>[
  StripShape(
    id: 'i',
    name: '일자(I자) 테이프',
    cut: '자르지 않은 한 줄 테이프',
    use: '근육과 근막을 안정시키도록 지지할 때 문헌에서 흔히 쓰여요. 가장 기본 모양이에요.',
    sources: ['K1'],
  ),
  StripShape(
    id: 'o',
    name: 'O자 테이프',
    cut: '고리 모양',
    use: 'I자와 함께 근육·근막의 안정을 돕는 용도로 쓰여요.',
    sources: ['K1'],
  ),
  StripShape(
    id: 'x',
    name: 'X자 테이프',
    cut: '가운데에서 네 갈래로 퍼지는 모양',
    use: '피부를 들어 올리는 효과로 통증을 줄이려는 목적에 문헌에서 쓰여요.',
    sources: ['K1'],
  ),
  StripShape(
    id: 'y',
    name: 'Y자 테이프',
    cut: '한 끝을 길게 잘라 꼬리 2개를 만든 모양',
    use: '꼬리 덕분에 붓기를 줄이고 림프 순환을 돕는 목적에 쓰여요. 연구에서는 꼬리를 같은 너비로 나눴어요.',
    sources: ['K1'],
  ),
  StripShape(
    id: 'fan',
    name: '부채꼴(팬) 테이프',
    cut: '한 끝을 여러 갈래(연구에서는 꼬리 4개)로 잘라 부채처럼 펼친 모양',
    use: '꼬리가 많아 붓기 완화와 림프 순환을 돕는 목적에 쓰여요. 연구에서는 허리 피부 온도를 올렸어요.',
    sources: ['K1'],
  ),
];

const stripNote =
    '위 쓰임새는 논문에서 일반적으로 설명하는 내용이에요. 어떤 모양을 어디에 얼마나 당겨 붙일지는 '
    '사람과 부위에 따라 달라서, 실제 적용은 전문가의 평가를 받으세요.';

class GlossaryTerm {
  const GlossaryTerm(this.term, this.english, this.meaning, this.sources);
  final String term;
  final String english;
  final String meaning;
  final List<String> sources;
}

const glossaryTerms = <GlossaryTerm>[
  GlossaryTerm('앵커', 'anchor', '테이프를 고정하는 시작·끝 지점이에요. 탄성 테이프의 앵커는 당기지 않고(장력 없이) 붙인 연구가 있어요.', ['K2', 'K4']),
  GlossaryTerm('스터럽', 'stirrup', '발 안쪽에서 뒤꿈치 아래를 지나 바깥쪽으로 U자로 붙여 발목 좌우 움직임을 잡는 방법이에요. 등자(말 탈 때 발 거는 도구)에서 온 이름이에요.', ['K4', 'K5']),
  GlossaryTerm('말발굽', 'horseshoe', '말발굽(U) 모양으로 붙여 스터럽 등을 고정하는 방법이에요.', ['K4', 'K5']),
  GlossaryTerm('힐락', 'heel lock', '뒤꿈치를 감싸 발목과 뒤꿈치를 고정하는 방법이에요.', ['K4', 'K5']),
  GlossaryTerm('8자 감기', 'figure-of-eight', '숫자 8처럼 발등과 발목을 엇갈려 감는 방법이에요.', ['K4', 'K5']),
  GlossaryTerm('바스켓 위브', 'basket-weave', '발목 비신축 테이핑의 전통적인 엮어 붙이는 방식이에요.', ['K4']),
  GlossaryTerm('언더랩(프리랩)', 'underwrap', '테이프를 붙이기 전에 피부를 보호하려고 먼저 감는 얇은 막이에요. 논문에서는 피부 보호막(protective skin barrier)으로 표현해요.', ['K4']),
  GlossaryTerm('장력(텐션)', 'tension', '테이프를 피부에 붙일 때 늘린 정도예요.', ['K2']),
  GlossaryTerm('페이퍼 오프 텐션', 'paper-off tension', '보호지를 떼어낸 상태 그대로, 늘리지 않고 붙이는 장력이에요.', ['K2']),
  GlossaryTerm('탄성 테이프', 'elastic tape', '늘어나는 접착 테이프예요. 키네시오·다이나믹 테이프가 해당해요.', ['K1', 'K5']),
  GlossaryTerm('비신축(비탄성) 테이프', 'non-elastic tape', '늘어나지 않아 관절을 고정해 보호하는 테이프예요.', ['K1', 'K4']),
  GlossaryTerm('꼬리(테일)', 'tail', '테이프를 갈라 만든 갈래예요. Y자는 2개, 부채꼴은 연구에서 4개로 나눴어요.', ['K1']),
  GlossaryTerm('근막', 'fascia', '근육을 감싸는 얇은 막 조직이에요. I·O자 테이프가 근육·근막 안정에 쓰여요.', ['K1']),
  GlossaryTerm('부종', 'edema (swelling)', '조직에 물이 차서 붓는 것이에요. Y·부채꼴 테이프가 붓기 완화 목적으로 쓰여요.', ['K1']),
  GlossaryTerm('림프 순환', 'lymphatic circulation', '림프액이 흘러 조직의 노폐물과 수분을 나르는 흐름이에요.', ['K1']),
  GlossaryTerm('가동범위', 'range of motion (ROM)', '관절이 움직일 수 있는 범위예요.', ['K4']),
  GlossaryTerm('저측굴곡', 'plantarflexion', '발끝을 아래로 뻗듯 발바닥쪽으로 굽히는 움직임이에요.', ['K4']),
  GlossaryTerm('내번 / 외번', 'inversion / eversion', '내번은 발바닥이 안쪽을 향하게 뒤집히는 움직임, 외번은 바깥쪽으로 뒤집히는 움직임이에요. 발목 염좌는 흔히 내번 손상이에요.', ['K4', 'S5']),
  GlossaryTerm('고유수용감각', 'proprioception', '관절이 어떤 위치에 있는지 스스로 느끼는 감각이에요. 테이핑이 이 감각을 높인다는 보고가 있어요.', ['K1', 'K4']),
];

KnowledgeSource sourceById(String id) => knowledgeSources.firstWhere((s) => s.id == id);
