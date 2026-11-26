import 'dart:math' as math;

/// 종아리~발 3D 모형의 기하 데이터. 단위는 cm에 가까운 임의 단위이며 해부학적으로
/// 정확한 모형이 아니라 테이핑 위치를 보여 주는 단순 도식이다.
///
/// 좌표계: y가 위(발목 중심이 0, 발바닥 -9, 종아리 윗면 [legTop]),
/// +z가 발끝 방향, +x가 오른쪽이다.
class Vec3 {
  const Vec3(this.x, this.y, this.z);
  final double x, y, z;

  Vec3 operator +(Vec3 o) => Vec3(x + o.x, y + o.y, z + o.z);
  Vec3 operator -(Vec3 o) => Vec3(x - o.x, y - o.y, z - o.z);
  Vec3 scale(double k) => Vec3(x * k, y * k, z * k);
  double get length => math.sqrt(x * x + y * y + z * z);
  Vec3 get unit {
    final l = length;
    return l == 0 ? this : Vec3(x / l, y / l, z / l);
  }

  Vec3 cross(Vec3 o) => Vec3(y * o.z - z * o.y, z * o.x - x * o.z, x * o.y - y * o.x);
}

/// 표면 위의 한 점과 바깥쪽 법선.
class SurfacePoint {
  const SurfacePoint(this.pos, this.normal);
  final Vec3 pos;
  final Vec3 normal;
}

class Face {
  const Face(this.points, this.normal);
  final List<Vec3> points;
  final Vec3 normal;
}

/// 표면에 붙은 테이프 한 줄 (폭 [width]).
class TapeStrip {
  const TapeStrip(this.points, this.width, {this.underwrap = false});
  final List<SurfacePoint> points;
  final double width;
  final bool underwrap;
}

const double legTop = 24;
const double soleY = -9;

const _legRadius = <List<double>>[
  [-2, 3.4], [3, 3.3], [10, 3.7], [17, 4.4], [legTop, 4.9],
];

// t: 0 = 뒤꿈치 뒤쪽, 1 = 발끝. [t, 반폭, 윗면 높이]
const _foot = <List<double>>[
  [-0.04, 0.8, -2.0], [0, 2.8, 0], [0.15, 3.3, -1.2], [0.4, 3.8, -3.6],
  [0.7, 4.6, -5.8], [0.9, 4.2, -6.8], [1, 2.6, -7.3], [1.03, 1.0, -7.8],
];

double _interp(List<List<double>> table, double key, int col) {
  if (key <= table.first[0]) return table.first[col];
  for (var i = 1; i < table.length; i++) {
    if (key <= table[i][0]) {
      final a = table[i - 1], b = table[i];
      final f = (key - a[0]) / (b[0] - a[0]);
      return a[col] + (b[col] - a[col]) * f;
    }
  }
  return table.last[col];
}

double legRadius(double y) => _interp(_legRadius, y, 1);

double footZ(double t) => -6.5 + 26 * t;
double footHalfWidth(double t) => _interp(_foot, t, 1);
double _footTop(double t) => _interp(_foot, t, 2);
double footCenterY(double t) => (_footTop(t) + soleY) / 2;
double footHalfHeight(double t) => (_footTop(t) - soleY) / 2;

/// 종아리 표면의 점. [theta]는 y축 둘레 각도(0 = 정강이 쪽 +z, π/2 = +x).
SurfacePoint legPoint(double y, double theta, {double off = 0}) {
  final n = Vec3(math.sin(theta), 0, math.cos(theta));
  return SurfacePoint(Vec3(0, y, 0) + n.scale(legRadius(y) + off), n);
}

/// 발 단면 타원 위의 점. [phi] 0 = +x 옆면, π/2 = 윗면, -π/2 = 발바닥.
SurfacePoint footPoint(double t, double phi, {double off = 0}) {
  final w = footHalfWidth(t), h = footHalfHeight(t), yc = footCenterY(t);
  final n = Vec3(math.cos(phi) / w, math.sin(phi) / h, 0).unit;
  final p = Vec3(w * math.cos(phi), yc + h * math.sin(phi), footZ(t));
  return SurfacePoint(p + n.scale(off), n);
}

class LegMesh {
  LegMesh._(this.faces);
  final List<Face> faces;

  static final LegMesh instance = _build();

  static LegMesh _build() {
    final faces = <Face>[];
    const seg = 28;

    void ringsToFaces(List<List<Vec3>> rings, List<Vec3> centers) {
      for (var i = 0; i < rings.length - 1; i++) {
        for (var j = 0; j < seg; j++) {
          final k = (j + 1) % seg;
          final pts = [rings[i][j], rings[i][k], rings[i + 1][k], rings[i + 1][j]];
          var n = (pts[1] - pts[0]).cross(pts[3] - pts[0]).unit;
          final mid = (pts[0] + pts[2]).scale(0.5);
          final c = (centers[i] + centers[i + 1]).scale(0.5);
          if (n.x * (mid.x - c.x) + n.y * (mid.y - c.y) + n.z * (mid.z - c.z) < 0) {
            n = n.scale(-1);
          }
          faces.add(Face(pts, n));
        }
      }
    }

    // 종아리 (아래에서 위로)
    final legRings = <List<Vec3>>[], legCenters = <Vec3>[];
    const legSteps = 24;
    for (var i = 0; i <= legSteps; i++) {
      final y = -2 + (legTop + 2) * i / legSteps;
      final r = legRadius(y);
      legRings.add([
        for (var j = 0; j < seg; j++)
          Vec3(r * math.sin(2 * math.pi * j / seg), y, r * math.cos(2 * math.pi * j / seg)),
      ]);
      legCenters.add(Vec3(0, y, 0));
    }
    ringsToFaces(legRings, legCenters);
    // 종아리 윗면 마개
    const top = Vec3(0, legTop, 0);
    for (var j = 0; j < seg; j++) {
      final k = (j + 1) % seg;
      faces.add(Face([top, legRings.last[k], legRings.last[j]], const Vec3(0, 1, 0)));
    }

    // 발 (뒤꿈치에서 발끝으로)
    final footRings = <List<Vec3>>[], footCenters = <Vec3>[];
    for (final row in _foot) {
      final t = row[0];
      footRings.add([
        for (var j = 0; j < seg; j++) footPoint(t, 2 * math.pi * j / seg).pos,
      ]);
      footCenters.add(Vec3(0, footCenterY(t), footZ(t)));
    }
    ringsToFaces(footRings, footCenters);
    for (final (ring, center, dir) in [
      (footRings.first, footCenters.first, -1.0),
      (footRings.last, footCenters.last, 1.0),
    ]) {
      for (var j = 0; j < seg; j++) {
        faces.add(Face([center, ring[j], ring[(j + 1) % seg]], Vec3(0, 0, dir)));
      }
    }
    return LegMesh._(faces);
  }
}

/// 단계별 테이프 줄. 인덱스 0 = 피부 준비(언더랩), 1 = 분홍 테이프(U자, 발 양옆),
/// 2 = 주황 X 테이프(복숭아뼈 아래), 3 = 파랑 감기 테이프, 4 = 마무리 고정.
/// 5단계가 아닌 가이드는 줄이 없다.
List<TapeStrip> tapeStripsForStep(int index) {
  switch (index) {
    case 0:
      return [_underwrap()];
    case 1:
      return [_stirrup()];
    case 2:
      return _orangeX();
    case 3:
      return [_blueWrap()];
    case 4:
      return [_ring(13, 2.4)];
    default:
      return const [];
  }
}

const _off = 0.3;

TapeStrip _ring(double y, double width) {
  const n = 36;
  return TapeStrip([
    for (var i = 0; i <= n; i++) legPoint(y, 2 * math.pi * i / n, off: _off),
  ], width);
}

TapeStrip _underwrap() {
  const turns = 3, perTurn = 24;
  const n = turns * perTurn;
  return TapeStrip([
    for (var i = 0; i <= n; i++)
      legPoint(1 + 11 * i / n, 2 * math.pi * i / perTurn, off: 0.15),
  ], 3.2, underwrap: true);
}

TapeStrip _stirrup() {
  const t0 = 0.19;
  final pts = <SurfacePoint>[];
  for (var y = 14.0; y >= 0; y -= 2) {
    pts.add(legPoint(y, math.pi / 2, off: _off));
  }
  const arc = 14;
  const phiStart = 0.3, phiEnd = -math.pi - 0.3;
  for (var i = 0; i <= arc; i++) {
    pts.add(footPoint(t0, phiStart + (phiEnd - phiStart) * i / arc, off: _off));
  }
  for (var y = 0.0; y <= 14; y += 2) {
    pts.add(legPoint(y, -math.pi / 2, off: _off));
  }
  return TapeStrip(pts, 2.6);
}

/// 발 아래를 지나 복숭아뼈 아래에서 발등 앞으로 X자로 엇갈리는 두 줄.
List<TapeStrip> _orangeX() {
  TapeStrip strip(double side) {
    // side = +1 : 바깥(+x)에서 시작해 안쪽 위로, -1 : 반대
    final phi = side > 0 ? 0.0 : math.pi;
    final soleAdj = side > 0 ? -math.pi / 2 : -math.pi / 2;
    final pts = <SurfacePoint>[
      footPoint(0.08, soleAdj, off: _off),
      footPoint(0.08, side > 0 ? -0.9 : -math.pi + 0.9, off: _off),
      footPoint(0.08, phi, off: _off),
      legPoint(-0.5, side * math.pi / 2, off: _off),
    ];
    const n = 8;
    for (var i = 1; i <= n; i++) {
      final f = i / n;
      pts.add(legPoint(-0.5 + 9 * f, side * (math.pi / 2) * (1 - 2 * f), off: _off));
    }
    return TapeStrip(pts, 2.4);
  }

  return [strip(1), strip(-1)];
}

/// 발목뼈가 움직이는 높이에서 바깥(+x)에서 안쪽으로 한 바퀴 반 감는 줄.
TapeStrip _blueWrap() {
  const n = 40;
  return TapeStrip([
    for (var i = 0; i <= n; i++)
      legPoint(0.5 + 5.5 * i / n, math.pi / 2 + 2 * math.pi * 1.5 * i / n, off: _off),
  ], 2.6);
}
