import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../application/guide_providers.dart';
import '../../domain/guide_models.dart';

/// PRD 4번: 사전 체크리스트. 하나라도 해당하면 테이핑 대신 진료를 권고하고 진행을 막는다.
const redFlags = [
  '다친 직후이거나, 붓기·멍이 심하다',
  '체중을 실을 수 없다',
  '뼈가 부러지거나 빠진 것 같다 (골절·탈구 의심)',
  '붙일 부위에 상처, 발진 등 피부 이상이 있거나 테이프 알레르기가 있다',
];

class SafetyCheckScreen extends ConsumerStatefulWidget {
  const SafetyCheckScreen({super.key, required this.symptomId});
  final String symptomId;

  @override
  ConsumerState<SafetyCheckScreen> createState() => _SafetyCheckScreenState();
}

class _SafetyCheckScreenState extends ConsumerState<SafetyCheckScreen> {
  final _flags = List<bool>.filled(redFlags.length, false);

  bool get _blocked => _flags.any((v) => v);

  @override
  Widget build(BuildContext context) {
    final symptom = ref.watch(symptomProvider(widget.symptomId));
    return Scaffold(
      appBar: AppBar(title: const Text('안전 체크')),
      body: symptom.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => const Center(child: Text('불러오지 못했어요.')),
        data: (s) => s == null ? const Center(child: Text('가이드를 찾을 수 없어요.')) : _body(s),
      ),
    );
  }

  Widget _body(Symptom s) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text('시작하기 전에 확인해 주세요', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 4),
        const Text('아래에 해당하는 항목을 모두 체크하세요.'),
        const SizedBox(height: 8),
        for (var i = 0; i < redFlags.length; i++)
          CheckboxListTile(
            value: _flags[i],
            onChanged: (v) => setState(() => _flags[i] = v ?? false),
            title: Text(redFlags[i]),
            controlAffinity: ListTileControlAffinity.leading,
          ),
        const SizedBox(height: 12),
        if (_blocked)
          Card(
            color: Theme.of(context).colorScheme.errorContainer,
            child: const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                '테이핑을 하지 말고 먼저 전문의 진료를 받으세요. '
                '증상의 심한 정도가 손상 정도와 반드시 일치하지 않고, 골절이 동반될 수 있어요.',
              ),
            ),
          )
        else ...[
          Text('준비물: ${s.tapeNeeded}'),
          const SizedBox(height: 8),
          FilledButton(
            onPressed: () => context.pushReplacement('/guide/${s.id}'),
            child: const Text('해당 없어요, 시작할게요'),
          ),
        ],
      ],
    );
  }
}
