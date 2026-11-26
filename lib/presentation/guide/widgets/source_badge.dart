import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../domain/guide_models.dart';

/// 출처 ID 칩 목록. 칩을 누르면 출처 링크를 연다(링크가 없으면 출처 설명을 보여 준다).
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
            child: ActionChip(
              label: Text(id, style: const TextStyle(fontSize: 11)),
              visualDensity: VisualDensity.compact,
              padding: EdgeInsets.zero,
              onPressed: () => _open(context, references[id], id),
            ),
          ),
      ],
    );
  }

  Future<void> _open(BuildContext context, Reference? ref, String id) async {
    final messenger = ScaffoldMessenger.of(context);
    final uri = ref == null ? null : Uri.tryParse(ref.url);
    if (uri == null || !ref!.url.startsWith('https://')) {
      messenger.showSnackBar(SnackBar(content: Text(ref?.title ?? id)));
      return;
    }
    final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!ok) messenger.showSnackBar(const SnackBar(content: Text('링크를 열 수 없어요.')));
  }
}

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
