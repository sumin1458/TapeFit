import 'package:flutter/material.dart';

import '../../app/nav_bar.dart';

/// AI검사 탭: 아직 기능이 없고 업데이트 예정 안내만 보여준다.
class AiCheckScreen extends StatelessWidget {
  const AiCheckScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('AI검사')),
      bottomNavigationBar: const TapeFitNavBar(index: 1),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.auto_awesome, size: 48),
            SizedBox(height: 12),
            Text('업데이트 예정', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
            SizedBox(height: 6),
            Text('AI검사 기능은 곧 만나볼 수 있어요.', textAlign: TextAlign.center),
          ]),
        ),
      ),
    );
  }
}
