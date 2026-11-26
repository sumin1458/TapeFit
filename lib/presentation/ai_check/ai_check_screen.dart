import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../app/nav_bar.dart';
import '../../application/guide_providers.dart';
import '../../domain/coach_rules.dart';
import '../../domain/guide_models.dart';
import '../../domain/tape_analyzer.dart';
import 'camera_feed.dart';

/// AI검사 탭: 카메라 화면 위에 단계별 테이프 가이드선을 겹쳐 보여 주고,
/// 가상 AI 코치가 화면을 기기 안에서 분석해 붙인 위치가 맞는지 알려 준다.
/// 키·로그인 없이 동작하며 영상은 저장·전송하지 않는다. 구김·당김 세기는 볼 수 없어 직접 점검을 함께 둔다.
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
  final _grabber = FrameGrabber();
  AiCoachResult? _ai;
  bool _analyzing = false;
  String? _aiError;

  void _selectStep(int i) => setState(() {
        _step = i;
        _answers.clear();
        _checked = false;
        _ai = null;
        _aiError = null;
      });

  Future<void> _askAi(TapeStep step) async {
    final grab = _grabber.grab;
    if (grab == null) {
      setState(() => _aiError = '카메라가 아직 준비되지 않았어요. 잠시 후 다시 눌러 주세요.');
      return;
    }
    setState(() {
      _analyzing = true;
      _aiError = null;
    });
    try {
      final frame = await grab();
      if (!mounted) return;
      setState(() {
        _analyzing = false;
        if (frame == null) {
          _aiError = '화면을 가져오지 못했어요. 다시 시도해 주세요.';
        } else {
          _ai = analyzeTape(frame: frame, guide: step.tape);
        }
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _analyzing = false;
          _aiError = '분석 중 문제가 생겼어요. 다시 시도해 주세요.';
        });
      }
    }
  }

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
              'AI 코치 (기기 안 가상 AI)\n'
              '로그인·API 키 없이 기기 안에서만 분석해요. 카메라 화면의 가이드선에 붙인 테이프가 '
              '얼마나 겹치는지 색 차이로 보고 알려 줘요. 구김이나 당기는 세기는 볼 수 없어서 '
              '아래 직접 점검도 함께 해 주세요. 영상은 저장하거나 전송하지 않아요.',
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
        const SizedBox(height: 10),
        FilledButton.icon(
          key: const ValueKey('ask-ai'),
          icon: _analyzing
              ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
              : const Icon(Icons.auto_awesome),
          label: Text(_analyzing ? '분석 중…' : 'AI 코치에게 물어보기'),
          onPressed: _cameraOn && !_analyzing ? () => _askAi(step) : null,
        ),
        if (!_cameraOn)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text('카메라를 켜고 다리를 가이드선에 맞춘 뒤 눌러 주세요.', style: Theme.of(context).textTheme.bodySmall),
          ),
        if (_aiError != null)
          Padding(padding: const EdgeInsets.only(top: 8), child: Text(_aiError!, style: const TextStyle(color: Colors.red))),
        if (_ai != null) ...[const SizedBox(height: 8), _aiCard(_ai!)],
        const Divider(height: 28),
        Text('${step.title} 직접 점검', style: Theme.of(context).textTheme.titleMedium),
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
                  ref.watch(cameraFeedBuilderProvider)(context, _grabber),
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
                      onPressed: () => setState(() {
                        _cameraOn = false;
                        _ai = null;
                      }),
                    ),
                  ),
                ]),
        ),
      ),
    );
  }

  Widget _aiCard(AiCoachResult r) {
    final (color, icon) = switch (r.level) {
      CoachLevel.good => (Colors.green.shade50, Icons.check_circle),
      CoachLevel.partial => (Colors.orange.shade50, Icons.tips_and_updates),
      _ => (Colors.red.shade50, Icons.error_outline),
    };
    return Card(
      key: const ValueKey('ai-result'),
      color: color,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Icon(icon),
            const SizedBox(width: 8),
            Expanded(child: Text(r.headline, style: Theme.of(context).textTheme.titleMedium)),
          ]),
          const SizedBox(height: 8),
          for (final t in r.tips) Padding(padding: const EdgeInsets.symmetric(vertical: 3), child: Text('• $t')),
        ]),
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
    final k = GuideFit(size.width, size.height);
    canvas.translate(k.dx, k.dy);
    canvas.scale(k.k);
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
