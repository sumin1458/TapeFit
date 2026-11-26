import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import 'leg_model.dart';

/// 종아리~발 3D 모형 위에 단계별 테이핑 위치를 보여 준다.
/// 드래그로 360도 회전(위아래 포함), 두 손가락·마우스 휠로 확대·축소한다.
/// 외부 3D 패키지 없이 정점을 직접 회전·투영해 그린다.
class Leg3DView extends StatefulWidget {
  const Leg3DView({super.key, required this.stepIndex});
  final int stepIndex;

  @override
  State<Leg3DView> createState() => _Leg3DViewState();
}

class _Leg3DViewState extends State<Leg3DView> {
  static const _initialYaw = 0.8, _initialPitch = 0.2;
  static const _maxPitch = 1.45;

  double _yaw = _initialYaw;
  double _pitch = _initialPitch;
  double _zoom = 1;
  double _startZoom = 1;

  int get _degrees => ((_yaw * 180 / math.pi) % 360 + 360).round() % 360;

  void _set(double yaw, double pitch) => setState(() {
        _yaw = yaw;
        _pitch = pitch.clamp(-_maxPitch, _maxPitch);
      });

  @override
  Widget build(BuildContext context) {
    final accent = Theme.of(context).colorScheme.primary;
    return Column(
      children: [
        SizedBox(
          height: 320,
          child: Listener(
            onPointerSignal: (e) {
              if (e is PointerScrollEvent) {
                setState(() => _zoom = (_zoom - e.scrollDelta.dy * 0.001).clamp(0.7, 2.5));
              }
            },
            child: GestureDetector(
              key: const ValueKey('leg3d'),
              onScaleStart: (_) => _startZoom = _zoom,
              onScaleUpdate: (d) {
                setState(() {
                  _yaw += d.focalPointDelta.dx * 0.012;
                  _pitch = (_pitch + d.focalPointDelta.dy * 0.012).clamp(-_maxPitch, _maxPitch);
                  if (d.pointerCount > 1) _zoom = (_startZoom * d.scale).clamp(0.7, 2.5);
                });
              },
              child: ClipRect(
                child: CustomPaint(
                  size: Size.infinite,
                  painter: _LegPainter(
                    yaw: _yaw,
                    pitch: _pitch,
                    zoom: _zoom,
                    step: widget.stepIndex,
                    accent: accent,
                  ),
                ),
              ),
            ),
          ),
        ),
        Text('회전 $_degrees° · 드래그로 돌리고, 휠·두 손가락으로 확대해요',
            style: Theme.of(context).textTheme.bodySmall),
        const SizedBox(height: 4),
        Wrap(
          spacing: 6,
          alignment: WrapAlignment.center,
          children: [
            for (final (label, yaw, pitch) in const [
              ('앞', 0.0, 0.2),
              ('오른쪽', math.pi / 2, 0.2),
              ('뒤', math.pi, 0.2),
              ('왼쪽', -math.pi / 2, 0.2),
              ('아래', 0.0, -1.2),
            ])
              ActionChip(label: Text(label), onPressed: () => _set(yaw, pitch)),
            ActionChip(
              label: const Text('처음 시점'),
              onPressed: () {
                _set(_initialYaw, _initialPitch);
                setState(() => _zoom = 1);
              },
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          '이해를 돕는 단순 모형이에요. 실제 다리 모양·테이프 위치와 다를 수 있어요.',
          style: Theme.of(context).textTheme.bodySmall,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

class _Quad {
  _Quad(this.points, this.depth, this.color);
  final List<Offset> points;
  final double depth;
  final Color color;
}

class _LegPainter extends CustomPainter {
  _LegPainter({
    required this.yaw,
    required this.pitch,
    required this.zoom,
    required this.step,
    required this.accent,
  });
  final double yaw, pitch, zoom;
  final int step;
  final Color accent;

  static const _centerY = (legTop + soleY) / 2, _centerZ = 6.0;
  static const _skin = Color(0xFFF1D3B8);
  static const _light = Vec3(0.3, 0.5, 0.8);

  late final double _cy = math.cos(yaw), _sy = math.sin(yaw);
  late final double _cp = math.cos(pitch), _sp = math.sin(pitch);

  Vec3 _rotate(Vec3 p) {
    final x1 = p.x * _cy + p.z * _sy;
    final z1 = -p.x * _sy + p.z * _cy;
    return Vec3(x1, p.y * _cp - z1 * _sp, p.y * _sp + z1 * _cp);
  }

  Vec3 _rotateNormal(Vec3 n) => _rotate(n);

  Color _shade(Color base, Vec3 n) {
    final l = _light.unit;
    final d = (n.x * l.x + n.y * l.y + n.z * l.z).clamp(0.0, 1.0);
    final k = 0.55 + 0.45 * d;
    return Color.from(
      alpha: base.a,
      red: (base.r * k).clamp(0.0, 1.0),
      green: (base.g * k).clamp(0.0, 1.0),
      blue: (base.b * k).clamp(0.0, 1.0),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final scale = size.height / (legTop - soleY + 12) * zoom;
    final origin = Offset(size.width / 2, size.height / 2);
    Offset project(Vec3 r) => Offset(origin.dx + r.x * scale, origin.dy - r.y * scale);
    Vec3 toView(Vec3 p) => _rotate(p - const Vec3(0, _centerY, _centerZ));

    final quads = <_Quad>[];

    for (final f in LegMesh.instance.faces) {
      final n = _rotateNormal(f.normal);
      if (n.z < 0) continue;
      final v = [for (final p in f.points) toView(p)];
      quads.add(_Quad(
        [for (final p in v) project(p)],
        v.map((p) => p.z).reduce((a, b) => a + b) / v.length,
        _shade(_skin, n),
      ));
    }

    for (var s = 0; s <= step; s++) {
      final isCurrent = s == step;
      for (final strip in tapeStripsForStep(s)) {
        final base = strip.underwrap ? const Color(0xFFE9E1C9) : accent;
        final color = isCurrent ? base : base.withValues(alpha: 0.4);
        final pts = strip.points;
        for (var i = 0; i < pts.length - 1; i++) {
          final a = pts[i], b = pts[i + 1];
          final tangent = (b.pos - a.pos).unit;
          final nAvg = (a.normal + b.normal).unit;
          final binormal = tangent.cross(nAvg).unit.scale(strip.width / 2);
          final corners = [
            a.pos - binormal, b.pos - binormal, b.pos + binormal, a.pos + binormal,
          ];
          final n = _rotateNormal(nAvg);
          if (n.z < 0.02) continue;
          final v = [for (final p in corners) toView(p)];
          quads.add(_Quad(
            [for (final p in v) project(p)],
            v.map((p) => p.z).reduce((a, b) => a + b) / v.length + 0.5,
            _shade(color, n),
          ));
        }
      }
    }

    quads.sort((a, b) => a.depth.compareTo(b.depth));
    final fill = Paint()..style = PaintingStyle.fill..isAntiAlias = true;
    final edge = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 0.6
      ..isAntiAlias = true;
    for (final q in quads) {
      final path = Path()..addPolygon(q.points, true);
      canvas.drawPath(path, fill..color = q.color);
      canvas.drawPath(path, edge..color = q.color);
    }
  }

  @override
  bool shouldRepaint(_LegPainter old) =>
      old.yaw != yaw ||
      old.pitch != pitch ||
      old.zoom != zoom ||
      old.step != step ||
      old.accent != accent;
}
