import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/guide_providers.dart';

class FavoritesScreen extends ConsumerWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider).value;
    final favs = ref.watch(favoritesProvider).value ?? const <String>{};
    final items = [
      for (final id in favs)
        if (catalog?.symptom(id) != null) catalog!.symptom(id)!,
    ];
    return Scaffold(
      appBar: AppBar(title: const Text('즐겨찾기')),
      body: items.isEmpty
          ? const Center(child: Text('아직 즐겨찾기한 가이드가 없어요.'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final s in items)
                  Card(
                    child: ListTile(
                      title: Text(s.name),
                      subtitle: Text(s.tape),
                      trailing: IconButton(
                        tooltip: '해제',
                        icon: const Icon(Icons.star),
                        onPressed: () => ref.read(favoritesProvider.notifier).toggle(s.id),
                      ),
                      onTap: () => context.push('/safety/${s.id}'),
                    ),
                  ),
              ],
            ),
    );
  }
}
