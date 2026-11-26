import 'package:flutter/material.dart';

import '../../app/theme.dart';

/// 해당 관절을 강조해 보여 주는 인체 아이콘. 지원: knee, shoulder.
class BodyIcon extends StatelessWidget {
  const BodyIcon({super.key, required this.partId, required this.bodyColor, this.size = 28});
  final String partId;
  final Color bodyColor;
  final double size;

  static bool supports(String id) => id == 'knee' || id == 'shoulder';

  @override
  Widget build(BuildContext context) =>
      CustomPaint(size: Size.square(size), painter: _BodyPainter(partId, bodyColor));
}

class _BodyPainter extends CustomPainter {
  _BodyPainter(this.partId, this.bodyColor);
  final String partId;
  final Color bodyColor;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.width / 40;
    Offset p(double x, double y) => Offset(x * s, y * s);

    final body = Paint()
      ..color = bodyColor
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..strokeWidth = 3 * s;

    canvas.drawCircle(p(20, 5), 3.6 * s, Paint()..color = bodyColor);
    final path = Path()
      ..moveTo(p(13, 12).dx, p(13, 12).dy)
      ..lineTo(p(27, 12).dx, p(27, 12).dy)
      ..moveTo(p(20, 10).dx, p(20, 10).dy)
      ..lineTo(p(20, 24).dx, p(20, 24).dy)
      ..moveTo(p(13, 12).dx, p(13, 12).dy)
      ..lineTo(p(10, 25).dx, p(10, 25).dy)
      ..moveTo(p(27, 12).dx, p(27, 12).dy)
      ..lineTo(p(30, 25).dx, p(30, 25).dy)
      ..moveTo(p(17, 24).dx, p(17, 24).dy)
      ..lineTo(p(16, 31).dx, p(16, 31).dy)
      ..lineTo(p(16, 39).dx, p(16, 39).dy)
      ..moveTo(p(23, 24).dx, p(23, 24).dy)
      ..lineTo(p(24, 31).dx, p(24, 31).dy)
      ..lineTo(p(24, 39).dx, p(24, 39).dy);
    canvas.drawPath(path, body);

    final joints = partId == 'knee' ? [p(16, 31), p(24, 31)] : [p(13, 12), p(27, 12)];
    for (final j in joints) {
      canvas.drawCircle(j, 5.5 * s, Paint()..color = brandBlue.withValues(alpha: 0.25));
      canvas.drawCircle(j, 3 * s, Paint()..color = brandBlue);
    }
  }

  @override
  bool shouldRepaint(_BodyPainter old) => old.partId != partId || old.bodyColor != bodyColor;
}
