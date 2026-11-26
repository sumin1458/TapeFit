import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/nav_bar.dart';
import '../../application/guide_providers.dart';

/// MY 탭: 내 즐겨찾기 요약. 로그인 없이 기기에 저장된 값만 보여준다.
class MyScreen extends ConsumerWidget {
  const MyScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final count = (ref.watch(favoritesProvider).value ?? const <String>{}).length;
    return Scaffold(
      appBar: AppBar(title: const Text('MY')),
      bottomNavigationBar: const TapeFitNavBar(index: 4),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.star),
              title: const Text('내 즐겨찾기'),
              subtitle: Text('$count개 · 이 기기에 저장돼요'),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.go('/favorites'),
            ),
          ),
        ],
      ),
    );
  }
}
