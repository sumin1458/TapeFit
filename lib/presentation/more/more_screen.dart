import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
      bottomNavigationBar: const TapeFitNavBar(index: 4),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              key: const ValueKey('open-glossary'),
              leading: const Icon(Icons.search),
              title: const Text('테이핑 용어 사전'),
              subtitle: const Text('앵커·스터럽·장력 같은 용어를 출처와 함께 찾아봐요.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/glossary'),
            ),
          ),
          Card(
            child: ListTile(
              key: const ValueKey('open-intro'),
              leading: const Icon(Icons.menu_book_outlined),
              title: const Text('테이핑 소개'),
              subtitle: const Text('테이프 종류와 모양별 쓰임새를 알아봐요.'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push('/intro'),
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.health_and_safety_outlined),
              title: const Text('이용 안내'),
              subtitle: Text(catalog?.disclaimer ?? '이 앱은 의료 행위를 대체하지 않아요.'),
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
