import 'package:flutter/material.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../../domain/guide_models.dart';

/// 단계·주의사항 아래에 출처를 글자 링크로 보여 준다. 링크가 없는 출처는 설명만 표시한다.
class SourceLine extends StatelessWidget {
  const SourceLine({super.key, required this.sources, required this.references});
  final List<String> sources;
  final Map<String, Reference> references;

  @override
  Widget build(BuildContext context) {
    final refs = [for (final id in sources) if (references[id] != null) references[id]!];
    if (refs.isEmpty) {
      return const Text('출처: 검수 예정', style: TextStyle(fontSize: 12, color: Colors.black54));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      for (final r in refs)
        InkWell(
          onTap: r.url.startsWith('https://')
              ? () => launchUrl(Uri.parse(r.url), mode: LaunchMode.externalApplication)
              : null,
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Text('출처 · ${r.title}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12,
                  color: r.url.isEmpty ? Colors.black54 : Theme.of(context).colorScheme.primary,
                  decoration: r.url.isEmpty ? null : TextDecoration.underline,
                )),
          ),
        ),
    ]);
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
