import 'package:flutter/material.dart';

import '../../../domain/guide_models.dart';

class ReviewBadge extends StatelessWidget {
  const ReviewBadge({super.key, required this.review});
  final Review review;

  @override
  Widget build(BuildContext context) {
    if (!review.verified) return const SizedBox.shrink();
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
