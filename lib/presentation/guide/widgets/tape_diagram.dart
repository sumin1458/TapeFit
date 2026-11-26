import 'package:flutter/material.dart';

import '../../../core/validation.dart';
import '../../../domain/guide_models.dart';

/// 발목 옆면 도식 위에 테이프 줄을 그린다. 좌표계는 PRD 6-1 (약 210 x 230).
/// 이전 단계는 흐리게, 현재 단계는 진하게 표시한다.
class TapeDiagram extends StatelessWidget {
  const TapeDiagram({super.key, required this.steps, required this.currentIndex});
  final List<TapeStep> steps;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 210 / 230,
      child: CustomPaint(
        painter: _TapePainter(steps, currentIndex, Theme.of(context).colorScheme.primary),
      ),
    );
  }
}

class _TapePainter extends CustomPainter {
  _TapePainter(this.steps, this.current, this.accent);
  final List<TapeStep> steps;
  final int current;
  final Color accent;

  static const _w = 210.0, _h = 230.0;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / _w, size.height / _h);

    final skin = Paint()..color = const Color(0xFFF1D3B8);
    final outline = Paint()
      ..color = const Color(0xFFC9A98C)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    final leg = RRect.fromRectAndRadius(const Rect.fromLTWH(68, 10, 74, 150), const Radius.circular(20));
    final foot = RRect.fromRectAndRadius(const Rect.fromLTWH(60, 150, 130, 68), const Radius.circular(32));
    for (final s in [leg, foot]) {
      canvas.drawRRect(s, skin);
      canvas.drawRRect(s, outline);
    }

    for (var i = 0; i <= current && i < steps.length; i++) {
      final isCurrent = i == current;
      final paint = Paint()
        ..color = isCurrent ? accent : accent.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isCurrent ? 7 : 5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      for (final line in steps[i].tape) {
        if (line.length < 2 || !tapeIsValid(steps[i])) continue;
        final path = Path()..moveTo(line.first[0], line.first[1]);
        for (final p in line.skip(1)) {
          path.lineTo(p[0], p[1]);
        }
        canvas.drawPath(path, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_TapePainter old) =>
      old.current != current || old.steps != steps || old.accent != accent;
}
