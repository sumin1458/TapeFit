import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/nav_bar.dart';

class StoreLink {
  const StoreLink(this.shop, this.url);
  final String shop;
  final String url;
}

enum ProductArt { roll, rigidRoll, wavyRoll, underwrap, scissors }

/// 스토어에 나열하는 테이핑 제품. [style]은 일러스트 종류를 정한다.
class StoreProduct {
  const StoreProduct({
    required this.id,
    required this.name,
    required this.desc,
    required this.query,
    required this.color,
    required this.style,
    required this.links,
  });
  final String id;
  final String name;
  final String desc;
  final String query;
  final Color color;
  final ProductArt style;
  final List<StoreLink> links;
}

/// 각 쇼핑몰의 검색 결과 페이지로 연결한다(특정 상품·가격을 보증하지 않는다).
List<StoreLink> _shops(String q, String amazonQ) {
  final e = Uri.encodeQueryComponent(q);
  return [
    StoreLink('네이버 쇼핑', 'https://search.shopping.naver.com/search/all?query=$e'),
    StoreLink('쿠팡', 'https://www.coupang.com/np/search?q=$e'),
    StoreLink('11번가', 'https://search.11st.co.kr/Search.tmall?kwd=$e'),
    StoreLink('G마켓', 'https://browse.gmarket.co.kr/search?keyword=$e'),
    StoreLink('Amazon', 'https://www.amazon.com/s?k=${Uri.encodeQueryComponent(amazonQ)}'),
  ];
}

final storeProducts = <StoreProduct>[
  StoreProduct(
    id: 'kinesio',
    name: '키네시오 테이프',
    desc: '신축성 있는 탄성 테이프. 일자·Y자·X자·부채꼴로 잘라 써요.',
    query: '키네시오 테이프',
    color: const Color(0xFFF06292),
    style: ProductArt.roll,
    links: _shops('키네시오 테이프', 'kinesiology tape'),
  ),
  StoreProduct(
    id: 'rigid',
    name: '비신축 테이프',
    desc: '늘어나지 않는 리지드(경성) 테이프. 관절을 단단히 고정해요.',
    query: '스포츠 리지드 테이프',
    color: const Color(0xFFEEEEEE),
    style: ProductArt.rigidRoll,
    links: _shops('스포츠 리지드 테이프', 'athletic rigid tape'),
  ),
  StoreProduct(
    id: 'dynamic',
    name: '다이나믹 테이프',
    desc: '여러 방향으로 늘어나는 탄성 테이프. 움직임을 덜 막아요.',
    query: '다이나믹 테이프',
    color: const Color(0xFF42A5F5),
    style: ProductArt.wavyRoll,
    links: _shops('다이나믹 테이프', 'dynamic tape'),
  ),
  StoreProduct(
    id: 'underwrap',
    name: '언더랩(프리랩)',
    desc: '비신축 테이프 아래에 감아 피부를 보호하는 얇은 막이에요.',
    query: '언더랩 테이프',
    color: const Color(0xFFE9E1C9),
    style: ProductArt.underwrap,
    links: _shops('언더랩 테이프', 'pre wrap underwrap'),
  ),
  StoreProduct(
    id: 'scissors',
    name: '테이핑 가위',
    desc: '테이프를 깔끔하게 자르는 둥근 끝 가위예요.',
    query: '테이핑 가위',
    color: const Color(0xFF90A4AE),
    style: ProductArt.scissors,
    links: _shops('테이핑 가위', 'tape scissors'),
  ),
];

/// 제품별 일러스트를 코드로 그린다(외부 이미지 파일 없음).
class ProductArtPainter extends CustomPainter {
  ProductArtPainter(this.style, this.color);
  final ProductArt style;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final c = size.center(Offset.zero);
    final r = size.shortestSide * 0.4;
    final fill = Paint()..color = color;
    final line = Paint()
      ..color = Colors.black54
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final shade = Paint()..color = Colors.black.withValues(alpha: 0.12);

    void roll({double inner = 0.45}) {
      canvas.drawCircle(c + const Offset(0, 3), r, shade);
      canvas.drawCircle(c, r, fill);
      canvas.drawCircle(c, r, line);
      canvas.drawCircle(c, r * inner, Paint()..color = const Color(0xFFFAFAFA));
      canvas.drawCircle(c, r * inner, line);
    }

    switch (style) {
      case ProductArt.roll:
        roll();
        final tail = Path()
          ..moveTo(c.dx + r * 0.2, c.dy + r)
          ..lineTo(c.dx + r * 1.0, c.dy + r)
          ..lineTo(c.dx + r * 1.0, c.dy + r * 0.82)
          ..lineTo(c.dx + r * 0.2, c.dy + r * 0.82)
          ..close();
        canvas.drawPath(tail, fill);
        canvas.drawPath(tail, line);
      case ProductArt.rigidRoll:
        roll(inner: 0.5);
        final thin = Paint()
          ..color = Colors.black38
          ..style = PaintingStyle.stroke
          ..strokeWidth = 0.8;
        for (var i = 1; i <= 2; i++) {
          canvas.drawCircle(c, r * (0.5 + 0.18 * i), thin);
        }
        canvas.drawRect(
          Rect.fromCenter(center: c + Offset(0, r * 1.02), width: r * 0.8, height: r * 0.12),
          Paint()..color = const Color(0xFF455A64),
        );
      case ProductArt.wavyRoll:
        roll();
        final wave = Path()..moveTo(c.dx - r * 0.85, c.dy);
        for (var i = 0; i < 4; i++) {
          final up = i.isEven ? -r * 0.25 : r * 0.25;
          wave.relativeQuadraticBezierTo(r * 0.21, up, r * 0.425, 0);
        }
        canvas.drawPath(
          wave,
          Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
      case ProductArt.underwrap:
        final body = RRect.fromRectAndRadius(
          Rect.fromCenter(center: c, width: r * 1.7, height: r * 1.2),
          const Radius.circular(8),
        );
        canvas.drawRRect(body, fill);
        canvas.drawRRect(body, line);
        final fold = Paint()
          ..color = Colors.black26
          ..strokeWidth = 1;
        for (var i = 1; i < 4; i++) {
          final x = body.left + body.width * i / 4;
          canvas.drawLine(Offset(x, body.top + 4), Offset(x, body.bottom - 4), fold);
        }
      case ProductArt.scissors:
        final blade = Paint()
          ..color = color
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5
          ..strokeCap = StrokeCap.round;
        canvas.drawLine(c + Offset(-r * 0.2, r * 0.1), c + Offset(r * 0.9, -r * 0.8), blade);
        canvas.drawLine(c + Offset(-r * 0.2, -r * 0.1), c + Offset(r * 0.9, r * 0.8), blade);
        final ring = Paint()
          ..color = const Color(0xFFE53935)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5;
        canvas.drawCircle(c + Offset(-r * 0.6, -r * 0.35), r * 0.28, ring);
        canvas.drawCircle(c + Offset(-r * 0.6, r * 0.35), r * 0.28, ring);
    }
  }

  @override
  bool shouldRepaint(ProductArtPainter old) => old.style != style || old.color != color;
}

/// 스토어 탭: 테이핑 제품 목록. 제품을 누르면 구매 링크가 나온다.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  void _showLinks(BuildContext context, StoreProduct p) {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          children: [
            Text('${p.name} 구매 링크', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 4),
            Text('"${p.query}" 검색 결과로 이동해요.', style: const TextStyle(fontSize: 12)),
            for (final l in p.links)
              ListTile(
                key: ValueKey('link-${p.id}-${l.shop}'),
                leading: const Icon(Icons.shopping_bag_outlined),
                title: Text(l.shop),
                trailing: const Icon(Icons.open_in_new),
                onTap: () => _open(l.url),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스토어')),
      bottomNavigationBar: const TapeFitNavBar(index: 3),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('테이핑 제품을 누르면 구매할 수 있는 쇼핑몰 링크가 나와요.'),
          const SizedBox(height: 8),
          for (final p in storeProducts)
            Card(
              child: InkWell(
                key: ValueKey('product-${p.id}'),
                borderRadius: BorderRadius.circular(12),
                onTap: () => _showLinks(context, p),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 88,
                        height: 88,
                        decoration: BoxDecoration(
                          color: const Color(0xFFF3F6FB),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: CustomPaint(painter: ProductArtPainter(p.style, p.color)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name, style: Theme.of(context).textTheme.titleMedium),
                            const SizedBox(height: 4),
                            Text(p.desc),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
              ),
            ),
          const SizedBox(height: 12),
          const Text(
            '링크는 쇼핑몰 검색 결과 페이지이며 특정 제품을 추천하지 않아요. 구매 전 피부 상태와 사용법을 확인하세요.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
