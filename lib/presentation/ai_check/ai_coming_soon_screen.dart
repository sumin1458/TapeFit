import 'package:flutter/material.dart';

import '../../app/nav_bar.dart';

/// AI검사 탭: 추후 업데이트 안내만 보여준다. (카메라 코치 화면은 /ai-preview에 보관)
class AiComingSoonScreen extends StatelessWidget {
  const AiComingSoonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI검사')),
      bottomNavigationBar: const TapeFitNavBar(index: 1),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_awesome_outlined, size: 48),
            SizedBox(height: 12),
            Text('추후 업데이트 예정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('AI검사 기능은 곧 만나볼 수 있어요.', textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
