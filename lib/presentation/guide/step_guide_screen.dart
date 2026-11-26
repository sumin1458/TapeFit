import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/guide_providers.dart';
import '../../domain/guide_models.dart';
import 'widgets/leg_3d_view.dart';
import 'widgets/source_badge.dart';
import 'widgets/tape_diagram.dart';

class StepGuideScreen extends ConsumerStatefulWidget {
  const StepGuideScreen({super.key, required this.symptomId});
  final String symptomId;

  @override
  ConsumerState<StepGuideScreen> createState() => _StepGuideScreenState();
}

class _StepGuideScreenState extends ConsumerState<StepGuideScreen> {
  int _index = 0;
  bool _view3d = true;

  @override
  Widget build(BuildContext context) {
    final symptom = ref.watch(symptomProvider(widget.symptomId));
    final refs = ref.watch(catalogProvider).value?.references ?? const <String, Reference>{};
    final fav = ref.watch(favoritesProvider).value ?? const <String>{};

    return Scaffold(
      appBar: AppBar(
        title: const Text('따라하기'),
        actions: [
          IconButton(
            tooltip: '즐겨찾기',
            icon: Icon(fav.contains(widget.symptomId) ? Icons.star : Icons.star_outline),
            onPressed: () => ref.read(favoritesProvider.notifier).toggle(widget.symptomId),
          ),
        ],
      ),
      body: symptom.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('불러오지 못했어요.')),
        data: (s) => s == null ? const Center(child: Text('가이드를 찾을 수 없어요.')) : _body(s, refs),
      ),
    );
  }

  Widget _body(Symptom s, Map<String, Reference> refs) {
    final step = s.steps[_index];
    final last = _index == s.steps.length - 1;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(s.name, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        LinearProgressIndicator(value: (_index + 1) / s.steps.length),
        const SizedBox(height: 4),
        Text('${_index + 1} / ${s.steps.length} 단계'),
        const SizedBox(height: 12),
        Center(
          child: SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('3D 보기')),
              ButtonSegment(value: false, label: Text('2D 도식')),
            ],
            selected: {_view3d},
            onSelectionChanged: (v) => setState(() => _view3d = v.first),
          ),
        ),
        const SizedBox(height: 8),
        if (_view3d)
          Leg3DView(stepIndex: _index)
        else if (step.tape.isNotEmpty)
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 260),
              child: TapeDiagram(steps: s.steps, currentIndex: _index),
            ),
          ),
        const SizedBox(height: 12),
        Text(step.title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 8),
        Text(step.body, style: Theme.of(context).textTheme.bodyLarge),
        const SizedBox(height: 8),
        Chip(label: Text('당김 강도: ${step.tension}')),
        const SizedBox(height: 4),
        SourceLine(sources: step.sources, references: refs),
        const SizedBox(height: 4),
        ReviewBadge(review: s.review),
        const Divider(height: 32),
        ExpansionTile(
          leading: const Icon(Icons.warning_amber_rounded),
          title: const Text('주의사항'),
          initiallyExpanded: _index == 0,
          children: [
            for (final c in s.cautions)
              ListTile(
                dense: true,
                title: Text(c.text),
                subtitle: SourceLine(sources: c.sources, references: refs),
              ),
          ],
        ),
        const SizedBox(height: 16),
        Row(children: [
          if (_index > 0)
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(52)),
                onPressed: () => setState(() => _index--),
                child: const Text('이전'),
              ),
            ),
          if (_index > 0) const SizedBox(width: 12),
          Expanded(
            child: FilledButton(
              onPressed: () {
                if (last) {
                  context.pushReplacement('/complete/${s.id}');
                } else {
                  setState(() => _index++);
                }
              },
              child: Text(last ? '완료' : '다음'),
            ),
          ),
        ]),
      ],
    );
  }
}
