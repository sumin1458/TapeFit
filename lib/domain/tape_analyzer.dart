import 'dart:math' as math;
import 'dart:typed_data';

/// 카메라에서 얻은 한 장의 화면(RGBA).
class RawFrame {
  const RawFrame(this.width, this.height, this.rgba);
  final int width;
  final int height;
  final Uint8List rgba;
}

/// 가이드 좌표(210 x 230)를 화면 상자(box)에 맞추는 방법. 화면 오버레이와 분석이 같은 값을 쓴다.
class GuideFit {
  GuideFit(double w, double h)
      : k = math.min(w, h) / 230 * 0.9,
        dx = (w - 210 * (math.min(w, h) / 230 * 0.9)) / 2,
        dy = (h - 230 * (math.min(w, h) / 230 * 0.9)) / 2;
  final double k;
  final double dx;
  final double dy;
  (double, double) toBox(double x, double y) => (dx + x * k, dy + y * k);
}

enum CoachLevel { good, partial, miss, noTape, dark, unsupported }

class AiCoachResult {
  const AiCoachResult(this.level, this.coverage, this.headline, this.tips);
  final CoachLevel level;

  /// 가이드선 위에서 테이프로 보이는 비율(0~1).
  final double coverage;
  final String headline;
  final List<String> tips;
}

const _guideSpacing = 3.0;
const _diffThreshold = 55;

/// 기기 안에서만 도는 가상 AI 코치. 화면의 주된 색(피부)과 다른 색을 "테이프"로 보고
/// 가이드선과 얼마나 겹치는지, 어느 쪽으로 치우쳤는지를 계산한다.
/// 구김·당김 세기는 알 수 없다.
AiCoachResult analyzeTape({
  required RawFrame frame,
  required List<List<List<double>>> guide,
  double boxW = 300,
  double boxH = 400,
}) {
  if (guide.isEmpty) {
    return const AiCoachResult(CoachLevel.unsupported, 0, '이 단계는 가이드선이 없어요',
        ['위치를 볼 수 있는 단계(2~5단계)를 골라 주세요.', '아래 직접 점검은 그대로 할 수 있어요.']);
  }
  final fw = frame.width, fh = frame.height, n = fw * fh;
  final px = frame.rgba;

  var lumSum = 0.0, lumN = 0;
  final hist = List.generate(3, (_) => List.filled(256, 0));
  for (var i = 0; i < n; i += 2) {
    final r = px[i * 4], g = px[i * 4 + 1], b = px[i * 4 + 2];
    lumSum += 0.299 * r + 0.587 * g + 0.114 * b;
    lumN++;
    hist[0][r]++;
    hist[1][g]++;
    hist[2][b]++;
  }
  if (lumN == 0 || lumSum / lumN < 45) {
    return const AiCoachResult(CoachLevel.dark, 0, '화면이 너무 어두워요',
        ['밝은 곳에서 다리가 잘 보이게 비춰 주세요.', '그다음 다시 물어봐 주세요.']);
  }
  final med = [for (final h in hist) _median(h, lumN)];

  final diff = Uint8List(n);
  var diffCount = 0;
  for (var i = 0; i < n; i++) {
    final dr = px[i * 4] - med[0], dg = px[i * 4 + 1] - med[1], db = px[i * 4 + 2] - med[2];
    if (dr * dr + dg * dg + db * db > _diffThreshold * _diffThreshold) {
      diff[i] = 1;
      diffCount++;
    }
  }
  if (diffCount / n < 0.004) {
    return const AiCoachResult(CoachLevel.noTape, 0, '테이프가 잘 보이지 않아요', [
      '다리와 테이프가 화면에 크게 나오게 가까이 비춰 주세요.',
      '테이프 색이 피부색과 비슷하면 구분하기 어려워요. 배경을 단순하게 해 보세요.',
    ]);
  }

  final fit = GuideFit(boxW, boxH);
  final s = math.max(boxW / fw, boxH / fh);
  final ox = (boxW - fw * s) / 2, oy = (boxH - fh * s) / 2;

  bool near(double fx, double fy, int r) {
    var c = 0, t = 0;
    for (var y = fy.round() - r; y <= fy.round() + r; y++) {
      for (var x = fx.round() - r; x <= fx.round() + r; x++) {
        if (x < 0 || y < 0 || x >= fw || y >= fh) continue;
        t++;
        c += diff[y * fw + x];
      }
    }
    return t > 0 && c / t >= 0.5;
  }

  var total = 0, hits = 0, missCount = 0, found = 0;
  var sx = 0.0, sy = 0.0;
  const dirs = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (-1, -1), (1, -1), (-1, 1)];
  for (final line in guide) {
    for (var i = 0; i + 1 < line.length; i++) {
      final a = line[i], b = line[i + 1];
      final len = math.sqrt(math.pow(b[0] - a[0], 2) + math.pow(b[1] - a[1], 2));
      final steps = math.max(1, (len / _guideSpacing).ceil());
      for (var j = 0; j <= steps; j++) {
        final t = j / steps;
        final (bx, by) = fit.toBox(a[0] + (b[0] - a[0]) * t, a[1] + (b[1] - a[1]) * t);
        final fx = (bx - ox) / s, fy = (by - oy) / s;
        total++;
        if (near(fx, fy, 2)) {
          hits++;
          continue;
        }
        missCount++;
        (int, int)? best;
        var bestD = 1 << 30;
        for (final d in dirs) {
          for (var m = 3; m <= 14; m++) {
            if (near(fx + d.$1 * m, fy + d.$2 * m, 2)) {
              if (m < bestD) {
                bestD = m;
                best = (d.$1 * m, d.$2 * m);
              }
              break;
            }
          }
        }
        if (best != null) {
          found++;
          sx += best.$1;
          sy += best.$2;
        }
      }
    }
  }
  final coverage = total == 0 ? 0.0 : hits / total;
  final pct = (coverage * 100).round();

  final tips = <String>[];
  if (missCount > 0 && found >= missCount * 0.3) {
    final mx = sx / found, my = sy / found;
    if (mx.abs() >= 2) tips.add('테이프가 가이드선보다 ${mx > 0 ? '오른쪽' : '왼쪽'}으로 치우쳤어요. ${mx > 0 ? '왼쪽' : '오른쪽'}으로 옮겨 붙여 보세요.');
    if (my.abs() >= 2) tips.add('테이프가 가이드선보다 ${my > 0 ? '아래' : '위'}쪽에 있어요. ${my > 0 ? '위' : '아래'}쪽으로 옮겨 붙여 보세요.');
  }

  if (coverage >= 0.7) {
    return AiCoachResult(CoachLevel.good, coverage, '잘 붙였어요! 가이드선과 $pct% 겹쳐요', [
      ...tips,
      '끝이 들뜨지 않았는지 손으로 눌러 확인해 보세요.',
      '조이거나 아프면 바로 떼고 다시 붙이세요.',
    ]);
  }
  if (coverage >= 0.35) {
    return AiCoachResult(CoachLevel.partial, coverage, '거의 맞지만 보완이 필요해요 ($pct% 겹침)', [
      ...tips,
      if (tips.isEmpty) '일부가 가이드선에서 벗어났어요. 화면의 가이드선을 보며 위치를 다듬어 보세요.',
      '카메라가 흔들리거나 각도가 다르면 어긋나 보일 수 있어요. 다리를 가이드선 안에 맞춰 다시 비춰 보세요.',
    ]);
  }
  return AiCoachResult(CoachLevel.miss, coverage, '가이드와 많이 달라요 ($pct% 겹침)', [
    ...tips,
    '가이드선 위에 테이프가 거의 없어요. 단계 설명을 다시 읽고 위치를 확인해 보세요.',
    '다리가 화면 가운데 오도록 비추면 더 정확해요.',
  ]);
}

int _median(List<int> hist, int total) {
  var acc = 0;
  for (var v = 0; v < 256; v++) {
    acc += hist[v];
    if (acc * 2 >= total) return v;
  }
  return 128;
}
