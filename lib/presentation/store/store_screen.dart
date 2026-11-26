import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../app/nav_bar.dart';

class StoreLink {
  const StoreLink(this.shop, this.query, this.url);
  final String shop;
  final String query;
  final String url;
}

/// 각 쇼핑몰의 검색 결과 페이지로 연결한다(특정 상품·가격을 보증하지 않는다).
const storeSections = <String, List<StoreLink>>{
  '키네시오 테이프(탄성 테이프)': [
    StoreLink('네이버 쇼핑', '키네시오 테이프', 'https://search.shopping.naver.com/search/all?query=%ED%82%A4%EB%84%A4%EC%8B%9C%EC%98%A4%20%ED%85%8C%EC%9D%B4%ED%94%84'),
    StoreLink('쿠팡', '키네시오 테이프', 'https://www.coupang.com/np/search?q=%ED%82%A4%EB%84%A4%EC%8B%9C%EC%98%A4%20%ED%85%8C%EC%9D%B4%ED%94%84'),
    StoreLink('11번가', '키네시오 테이프', 'https://search.11st.co.kr/Search.tmall?kwd=%ED%82%A4%EB%84%A4%EC%8B%9C%EC%98%A4%20%ED%85%8C%EC%9D%B4%ED%94%84'),
  ],
  '비신축(리지드) 테이프': [
    StoreLink('네이버 쇼핑', '스포츠 리지드 테이프', 'https://search.shopping.naver.com/search/all?query=%EC%8A%A4%ED%8F%AC%EC%B8%A0%20%EB%A6%AC%EC%A7%80%EB%93%9C%20%ED%85%8C%EC%9D%B4%ED%94%84'),
    StoreLink('쿠팡', '스포츠 리지드 테이프', 'https://www.coupang.com/np/search?q=%EC%8A%A4%ED%8F%AC%EC%B8%A0%20%EB%A6%AC%EC%A7%80%EB%93%9C%20%ED%85%8C%EC%9D%B4%ED%94%84'),
    StoreLink('G마켓', '스포츠 테이프', 'https://browse.gmarket.co.kr/search?keyword=%EC%8A%A4%ED%8F%AC%EC%B8%A0%20%ED%85%8C%EC%9D%B4%ED%94%84'),
  ],
  '언더랩·보조 용품': [
    StoreLink('네이버 쇼핑', '언더랩 테이프', 'https://search.shopping.naver.com/search/all?query=%EC%96%B8%EB%8D%94%EB%9E%A9%20%ED%85%8C%EC%9D%B4%ED%94%84'),
    StoreLink('쿠팡', '테이핑 가위', 'https://www.coupang.com/np/search?q=%ED%85%8C%EC%9D%B4%ED%95%91%20%EA%B0%80%EC%9C%84'),
    StoreLink('Amazon', 'kinesiology tape', 'https://www.amazon.com/s?k=kinesiology+tape'),
  ],
};

/// 스토어 탭: 테이핑 제품을 살 수 있는 쇼핑몰 링크 모음.
class StoreScreen extends StatelessWidget {
  const StoreScreen({super.key});

  Future<void> _open(String url) =>
      launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('스토어')),
      bottomNavigationBar: const TapeFitNavBar(index: 3),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('테이핑 제품을 찾을 수 있는 쇼핑몰 검색 링크예요. 누르면 외부 사이트가 열려요.'),
          for (final e in storeSections.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 20, bottom: 8),
              child: Text(e.key, style: Theme.of(context).textTheme.titleMedium),
            ),
            for (final l in e.value)
              Card(
                child: ListTile(
                  key: ValueKey('store-${l.shop}-${l.query}'),
                  leading: const Icon(Icons.shopping_bag_outlined),
                  title: Text(l.shop),
                  subtitle: Text('"${l.query}" 검색'),
                  trailing: const Icon(Icons.open_in_new),
                  onTap: () => _open(l.url),
                ),
              ),
          ],
          const SizedBox(height: 12),
          const Text(
            '제품 선택 전 피부 상태와 사용법을 확인하세요. 링크는 검색 결과 페이지이며 특정 제품을 추천하지 않아요.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }
}
