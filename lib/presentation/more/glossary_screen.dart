import 'package:flutter/material.dart';

import '../../data/tape_knowledge.dart';

/// 테이핑 용어 사전: 검색 + 출처 표시.
class GlossaryScreen extends StatefulWidget {
  const GlossaryScreen({super.key});

  @override
  State<GlossaryScreen> createState() => _GlossaryScreenState();
}

class _GlossaryScreenState extends State<GlossaryScreen> {
  String _q = '';

  @override
  Widget build(BuildContext context) {
    final q = _q.trim().toLowerCase();
    final terms = glossaryTerms
        .where((t) =>
            q.isEmpty ||
            t.term.toLowerCase().contains(q) ||
            t.english.toLowerCase().contains(q) ||
            t.meaning.toLowerCase().contains(q))
        .toList();
    return Scaffold(
      appBar: AppBar(title: const Text('테이핑 용어 사전')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          TextField(
            key: const ValueKey('glossary-search'),
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: '용어 검색 (예: 앵커, tension)',
              border: OutlineInputBorder(),
            ),
            onChanged: (v) => setState(() => _q = v),
          ),
          const SizedBox(height: 8),
          Text('논문·공식 자료에서 확인한 용어만 담았어요. 전문가 검수는 아직 받지 않았어요.',
              style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 8),
          if (terms.isEmpty)
            const Padding(padding: EdgeInsets.all(24), child: Center(child: Text('검색 결과가 없어요.'))),
          for (final t in terms)
            Card(
              child: ListTile(
                title: Text('${t.term}  (${t.english})'),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(t.meaning),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
