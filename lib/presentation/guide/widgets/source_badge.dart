import 'package:flutter/material.dart';

import '../../../domain/guide_models.dart';

/// 출처 ID 칩 목록. 출처가 없으면 "송수민 검수 전" 안내를 대신 보여 준다.
class SourceBadge extends StatelessWidget {
  const SourceBadge({super.key, required this.sources, required this.references});
  final List<String> sources;
  final Map<String, Reference> references;

  @override
  Widget build(BuildContext context) {
    if (sources.isEmpty) {
      return const Text('출처: 검수 예정', style: TextStyle(fontSize: 12, color: Colors.black54));
    }
    return Wrap(
      spacing: 6,
      children: [
        for (final id in sources)
          Tooltip(
            message: references[id]?.title ?? id,
            child: Chip(
              label: Text(id, style: const TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
            ),
          ),
      ],
    );
  }
}

class ReviewBadge extends StatelessWidget {
  const ReviewBadge({super.key, required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    final color = review.verified ? Colors.green.shade700 : Colors.orange.shade800;
    return Row(mainAxisSize: MainAxisSize.min, children: [
      Icon(review.verified ? Icons.verified : Icons.pending_outlined, size: 16, color: color),
      const SizedBox(width: 4),
      Text(review.label, style: TextStyle(fontSize: 12, color: color)),
    ]);
  }
}

class DisclaimerBanner extends StatelessWidget {
  const DisclaimerBanner({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.info_outline, size: 18),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13))),
      ]),
    );
  }
}
