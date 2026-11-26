import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/guide_providers.dart';
import '../guide/widgets/source_badge.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('테이프핏'),
        actions: [
          IconButton(
            tooltip: '즐겨찾기',
            icon: const Icon(Icons.star_outline),
            onPressed: () => context.push('/favorites'),
          ),
        ],
      ),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              const Text('가이드를 불러오지 못했어요.'),
              const SizedBox(height: 12),
              FilledButton(
                onPressed: () => ref.invalidate(catalogProvider),
                child: const Text('다시 시도'),
              ),
            ]),
          ),
        ),
        data: (c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('어디가 불편하세요?', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 4),
            const Text('증상을 고르면 초보자도 따라할 수 있게 단계별로 안내해요.'),
            const SizedBox(height: 12),
            DisclaimerBanner(text: c.disclaimer),
            if (c.fromFallback) ...[
              const SizedBox(height: 8),
              const Text(
                '오프라인 데이터로 표시 중이에요. 최신 내용이 아닐 수 있어요.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
            const SizedBox(height: 16),
            for (final part in c.bodyParts) ...[
              Text(part.name, style: Theme.of(context).textTheme.titleMedium),
              if (!part.available || part.symptoms.isEmpty)
                const Card(
                  child: ListTile(
                    enabled: false,
                    title: Text('준비 중이에요'),
                    leading: Icon(Icons.hourglass_empty),
                  ),
                )
              else
                for (final s in part.symptoms)
                  Card(
                    child: ListTile(
                      leading: const Icon(Icons.healing),
                      title: Text(s.name),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [Text(s.tape), ReviewBadge(review: s.review)],
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () => context.push('/safety/${s.id}'),
                    ),
                  ),
              const SizedBox(height: 8),
            ],
          ],
        ),
      ),
    );
  }
}
