import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav_bar.dart';
import '../../application/guide_providers.dart';

/// 더보기 탭: 안내 문구와 앱 정보.
class MoreScreen extends ConsumerWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    return Scaffold(
      appBar: AppBar(title: const Text('더보기')),
      bottomNavigationBar: const TapeFitNavBar(index: 3),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.health_and_safety_outlined),
              title: const Text('이용 안내'),
              subtitle: Text(catalog?.disclaimer ?? '이 앱은 의료 행위를 대체하지 않아요.'),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(catalog?.fromFallback == true ? Icons.cloud_off : Icons.cloud_done_outlined),
              title: const Text('콘텐츠 상태'),
              subtitle: Text(catalog?.fromFallback == true ? '오프라인 데이터를 사용 중이에요.' : '최신 데이터를 사용 중이에요.'),
            ),
          ),
          const Card(
            child: ListTile(
              leading: Icon(Icons.info_outline),
              title: Text('TapeFit'),
              subtitle: Text('테이핑 가이드 앱 · 2026 마산대 해커톤'),
            ),
          ),
        ],
      ),
    );
  }
}
