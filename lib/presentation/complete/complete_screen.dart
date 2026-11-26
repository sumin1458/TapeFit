import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/guide_providers.dart';

class CompleteScreen extends ConsumerWidget {
  const CompleteScreen({super.key, required this.symptomId});
  final String symptomId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fav = ref.watch(favoritesProvider).value ?? const <String>{};
    final isFav = fav.contains(symptomId);
    return Scaffold(
      appBar: AppBar(title: const Text('완료'), automaticallyImplyLeading: false),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Icon(Icons.check_circle, size: 72, color: Theme.of(context).colorScheme.primary),
            const SizedBox(height: 16),
            Text('테이핑을 마쳤어요!',
                textAlign: TextAlign.center, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            const Text(
              '조이거나 아프거나, 저림·색 변화가 있으면 바로 제거하세요. '
              '붙인 채로 오래 두지 말고, 불편하면 바로 떼세요. 증상이 계속되면 진료를 받으세요.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
              icon: Icon(isFav ? Icons.star : Icons.star_outline),
              label: Text(isFav ? '즐겨찾기 해제' : '즐겨찾기에 추가'),
              onPressed: () => ref.read(favoritesProvider.notifier).toggle(symptomId),
            ),
            const SizedBox(height: 12),
            FilledButton(onPressed: () => context.go('/'), child: const Text('처음으로')),
          ],
        ),
      ),
    );
  }
}
