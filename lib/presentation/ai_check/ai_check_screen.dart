import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav_bar.dart';
import '../../application/guide_providers.dart';
import '../../domain/coach_rules.dart';
import '../../domain/guide_models.dart';
import 'camera_feed.dart';

/// AI검사 탭: 카메라 화면 위에 단계별 테이프 가이드선을 겹쳐 보여 주고,
/// 점검 질문에 답하면 가이드와 다른 점의 수정 방법을 알려 주는 코치.
/// 사진을 분석하는 AI가 아니라 규칙 기반 점검이며, 영상은 저장·전송하지 않는다.
class AiCheckScreen extends ConsumerStatefulWidget {
  const AiCheckScreen({super.key});

  @override
  ConsumerState<AiCheckScreen> createState() => _AiCheckScreenState();
}

class _AiCheckScreenState extends ConsumerState<AiCheckScreen> {
  int _step = 1;
  bool _cameraOn = false;
  final Map<int, bool> _answers = {};
  bool _checked = false;

  void _selectStep(int i) => setState(() {
        _step = i;
        _answers.clear();
        _checked = false;
      });

  @override
  Widget build(BuildContext context) {
    final catalog = ref.watch(catalogProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('AI검사')),
      bottomNavigationBar: const TapeFitNavBar(index: 1),
      body: catalog.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('불러오지 못했어요.')),
        data: (c) {
          final symptoms = [for (final p in c.bodyParts) ...p.symptoms];
          if (symptoms.isEmpty) return const Center(child: Text('가이드를 찾을 수 없어요.'));
          return _body(symptoms.first);
        },
      ),
    );
  }

  Widget _body(Symptom s) {
    final step = s.steps[_step.clamp(0, s.steps.length - 1)];
    final items = coachRules[_step] ?? const <CoachItem>[];
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const Card(
          child: Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'AI 코치 (규칙 기반)\n'
              '카메라 화면에 가이드선을 겹쳐 보며 붙인 위치를 맞춰 보고, 아래 점검에 답하면 '
              '가이드와 다른 점을 알려 줘요. 사진을 분석하는 AI는 아니며, 영상은 저장하거나 전송하지 않아요.',
              style: TextStyle(fontSize: 13, height: 1.4),
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text(s.name, style: Theme.of(context).textTheme.labelLarge),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          children: [
            for (var i = 0; i < s.steps.length; i++)
              ChoiceChip(
                label: Text('${i + 1}. ${s.steps[i].title}'),
                selected: _step == i,
                onSelected: (_) => _selectStep(i),
              ),
          ],
        ),
        const SizedBox(height: 12),
        _cameraBox(step),
        const SizedBox(height: 6),
        Text(
          step.tape.isEmpty
              ? '이 단계는 가이드선이 없어요. 아래 점검만 진행하세요.'
              : '화면의 가이드선에 붙인 테이프를 맞춰 보세요. 위치 참고용이에요.',
          style: Theme.of(context).textTheme.bodySmall,
        ),
        const Divider(height: 28),
        Text('${step.title} 점검', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (var i = 0; i < items.length; i++) _question(i, items[i]),
        const SizedBox(height: 8),
        FilledButton(
          onPressed: _answers.length == items.length && items.isNotEmpty
              ? () => setState(() => _checked = true)
              : null,
          child: const Text('코치 점검 받기'),
        ),
        if (_checked) ...[
          const SizedBox(height: 12),
          _report(evaluateCoach(_step, _answers)),
        ],
      ],
    );
  }

  Widget _cameraBox(TapeStep step) {
    return AspectRatio(
      aspectRatio: 3 / 4,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: ColoredBox(
          color: Colors.black87,
          child: !_cameraOn
              ? Center(
                  child: FilledButton.icon(
                    icon: const Icon(Icons.videocam),
                    label: const Text('카메라 켜기'),
                    onPressed: () => setState(() => _cameraOn = true),
                  ),
                )
              : Stack(fit: StackFit.expand, children: [
                  ref.watch(cameraFeedBuilderProvider)(context),
                  IgnorePointer(
                    child: CustomPaint(
                      key: const ValueKey('guide-overlay'),
                      painter: _GuidePainter(step, Theme.of(context).colorScheme.primary),
                    ),
                  ),
                  Positioned(
                    right: 8,
                    top: 8,
                    child: IconButton.filledTonal(
                      tooltip: '카메라 끄기',
                      icon: const Icon(Icons.videocam_off),
                      onPressed: () => setState(() => _cameraOn = false),
                    ),
                  ),
                ]),
        ),
      ),
    );
  }

  Widget _question(int i, CoachItem item) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.question),
        const SizedBox(height: 4),
        SegmentedButton<bool>(
          key: ValueKey('coach-$i'),
          emptySelectionAllowed: true,
          segments: const [
            ButtonSegment(value: true, label: Text('예')),
            ButtonSegment(value: false, label: Text('아니요')),
          ],
          selected: {if (_answers[i] != null) _answers[i]!},
          onSelectionChanged: (v) => setState(() {
            if (v.isEmpty) {
              _answers.remove(i);
            } else {
              _answers[i] = v.first;
            }
            _checked = false;
          }),
        ),
      ]),
    );
  }

  Widget _report(CoachReport r) {
    if (r.allGood) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text('가이드대로 잘 붙였어요! 그래도 불편하거나 아프면 바로 떼고, '
              '통증·붓기가 계속되면 진료를 받으세요.'),
        ),
      );
    }
    return Card(
      color: Theme.of(context).colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('수정할 점 ${r.fixes.length}가지', style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          for (final f in r.fixes)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 3),
              child: Text('• ${f.fix}'),
            ),
          if (r.urgent) ...[
            const SizedBox(height: 8),
            const Text('몸에 이상 신호가 있어요. 지금 테이프를 떼고, 증상이 계속되면 진료를 받으세요.',
                style: TextStyle(fontWeight: FontWeight.w700)),
          ],
        ]),
      ),
    );
  }
}

/// 단계의 테이프 좌표(약 210 x 230)를 카메라 화면에 맞춰 겹쳐 그린다.
class _GuidePainter extends CustomPainter {
  _GuidePainter(this.step, this.color);
  final TapeStep step;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    if (step.tape.isEmpty) return;
    const w = 210.0, h = 230.0;
    final k = size.shortestSide / h * 0.9;
    canvas.translate((size.width - w * k) / 2, (size.height - h * k) / 2);
    canvas.scale(k);
    final halo = Paint()
      ..color = Colors.white.withValues(alpha: 0.85)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 11
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    final line = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 7
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final pts in step.tape) {
      if (pts.length < 2) continue;
      final path = Path()..moveTo(pts.first[0], pts.first[1]);
      for (final p in pts.skip(1)) {
        path.lineTo(p[0], p[1]);
      }
      canvas.drawPath(path, halo);
      canvas.drawPath(path, line);
    }
  }

  @override
  bool shouldRepaint(_GuidePainter old) => old.step != step || old.color != color;
}
