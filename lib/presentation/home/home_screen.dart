import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../app/nav_bar.dart';
import '../../app/theme.dart';
import '../../application/guide_providers.dart';
import '../../domain/guide_models.dart';
import '../guide/widgets/source_badge.dart';
import '../safety/safety_check_screen.dart' show redFlags;
import 'body_icon.dart';

const _partIcons = <String, IconData>{
  'ankle': Icons.directions_walk,
  'knee': Icons.accessibility_new,
  'wrist': Icons.back_hand_outlined,
  'shoulder': Icons.sports_gymnastics,
  'back': Icons.airline_seat_recline_normal,
};

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('TapeFit')),
      bottomNavigationBar: const TapeFitNavBar(index: 0),
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
        data: (c) {
          final symptoms = [for (final p in c.bodyParts) ...p.symptoms];
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              if (symptoms.isNotEmpty) _HeroCard(symptom: symptoms.first),
              const SizedBox(height: 12),
              DisclaimerBanner(text: c.disclaimer),
              if (c.fromFallback) ...[
                const SizedBox(height: 8),
                const Text(
                  '오프라인 데이터로 표시 중이에요. 최신 내용이 아닐 수 있어요.',
                  style: TextStyle(fontSize: 12, color: Colors.black54),
                ),
              ],
              const SizedBox(height: 20),
              Text('어디가 불편하세요?', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 10),
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.35,
                children: [
                  for (final p in c.bodyParts) _PartTile(part: p),
                  for (final k in _concerns) _ConcernTile(emoji: k.$1, label: k.$2),
                ],
              ),
              const SizedBox(height: 20),
              const _InfoCard(
                icon: Icons.fact_check_outlined,
                title: '테이핑 전 확인사항',
                subtitle: '하나라도 해당하면 테이핑 대신 진료를 먼저 받으세요.',
                items: redFlags,
              ),
              if (symptoms.isNotEmpty) ...[
                const SizedBox(height: 12),
                _InfoCard(
                  icon: Icons.warning_amber_rounded,
                  title: '주의사항',
                  subtitle: '${symptoms.first.name} 가이드 기준이에요.',
                  items: [for (final c in symptoms.first.cautions) c.text],
                ),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.items,
  });
  final IconData icon;
  final String title, subtitle;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon, color: brandBlue),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ]),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.black54)),
          const SizedBox(height: 8),
          for (final t in items)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('• '),
                Expanded(child: Text(t)),
              ]),
            ),
        ]),
      ),
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.symptom});
  final Symptom symptom;

  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(24),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.push('/safety/${symptom.id}'),
        child: Ink(
          padding: const EdgeInsets.all(20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [brandBlueDark, brandBlue],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('지금 바로 시작해보세요',
                    style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('${symptom.name}\n${symptom.steps.length}단계로 따라 해요',
                    style: const TextStyle(color: Colors.white70, height: 1.4)),
              ]),
            ),
            const CircleAvatar(
              radius: 26,
              backgroundColor: Colors.white,
              child: Icon(Icons.play_arrow_rounded, color: brandBlue, size: 32),
            ),
          ]),
        ),
      ),
    );
  }
}

const _concerns = [('💧', '부종'), ('🫧', '림프'), ('🧵', '근막')];

/// 증상별 항목. 아직 가이드가 없어 준비 중으로 표시한다.
class _ConcernTile extends StatelessWidget {
  const _ConcernTile({required this.emoji, required this.label});
  final String emoji;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CircleAvatar(backgroundColor: Colors.grey.shade200, child: Text(emoji, style: const TextStyle(fontSize: 22))),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
          const Text('준비 중이에요', style: TextStyle(fontSize: 12, color: Colors.black54)),
        ]),
      ),
    );
  }
}

class _PartTile extends StatelessWidget {
  const _PartTile({required this.part});
  final BodyPart part;

  @override
  Widget build(BuildContext context) {
    final enabled = part.available && part.symptoms.isNotEmpty;
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: enabled ? () => context.push('/safety/${part.symptoms.first.id}') : null,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            CircleAvatar(
              backgroundColor: enabled ? surfaceTint : Colors.grey.shade200,
              child: BodyIcon.supports(part.id)
                  ? BodyIcon(partId: part.id, bodyColor: enabled ? brandBlueDark : Colors.grey.shade600)
                  : Icon(_partIcons[part.id] ?? Icons.healing, color: enabled ? brandBlue : Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(part.name, style: const TextStyle(fontWeight: FontWeight.w700)),
            Text(enabled ? '가이드 보기' : '준비 중이에요',
                style: const TextStyle(fontSize: 12, color: Colors.black54)),
          ]),
        ),
      ),
    );
  }
}
