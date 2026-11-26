import 'package:flutter/material.dart';

import '../../app/nav_bar.dart';
import '../../data/tape_knowledge.dart';

/// 테이핑 소개 탭: 테이프 종류와 자르는 모양별 쓰임새(출처 표시).
class TapeIntroScreen extends StatelessWidget {
  const TapeIntroScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('테이핑 소개')),
      bottomNavigationBar: const TapeFitNavBar(index: 3),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text('테이프 종류', style: t.titleMedium),
          const SizedBox(height: 8),
          for (final x in tapeTypes)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(x.name, style: t.titleSmall),
                    Text(x.kind, style: t.bodySmall),
                    const SizedBox(height: 6),
                    for (final p in x.points) Text('• $p'),
                  ],
                ),
              ),
            ),
          Text(tapeComparisonNote, style: t.bodySmall),
          const SizedBox(height: 20),
          Text('테이프 모양별 쓰임새', style: t.titleMedium),
          const SizedBox(height: 8),
          for (final s in stripShapes)
            Card(
              child: ListTile(
                title: Text(s.name),
                subtitle: Text('모양: ${s.cut}\n${s.use}'),
                isThreeLine: true,
              ),
            ),
          Text(stripNote, style: t.bodySmall),
          const Divider(height: 32),
          Text('교육용 정보이며 의료 행위를 대체하지 않아요. 전문가 검수는 아직 받지 않았어요.', style: t.bodySmall),
        ],
      ),
    );
  }
}
