import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/nav_bar.dart';
import '../../app/theme.dart';
import '../../application/guide_providers.dart';
import '../home/body_icon.dart';

/// 부위 탭: 부위별로 증상 가이드를 모아서 보여준다.
class PartsScreen extends ConsumerWidget {
  const PartsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('부위')),
      bottomNavigationBar: const TapeFitNavBar(index: 1),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => const Center(child: Text('가이드를 불러오지 못했어요.')),
        data: (c) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            for (final p in c.bodyParts)
              Card(
                child: ExpansionTile(
                  leading: CircleAvatar(
                    backgroundColor: surfaceTint,
                    child: BodyIcon.supports(p.id)
                        ? BodyIcon(partId: p.id, bodyColor: brandBlueDark)
                        : const Icon(Icons.healing, color: brandBlue),
                  ),
                  title: Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                  subtitle: Text(p.available && p.symptoms.isNotEmpty ? '가이드 ${p.symptoms.length}개' : '준비 중이에요'),
                  children: [
                    for (final s in p.symptoms)
                      ListTile(
                        title: Text(s.name),
                        subtitle: Text(s.tape),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () => context.push('/safety/${s.id}'),
                      ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
