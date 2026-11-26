import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// 하단 탭. 지금 있는 화면(홈·즐겨찾기)만 연결한다.
class TapeFitNavBar extends StatelessWidget {
  const TapeFitNavBar({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        if (i == index) return;
        context.go(i == 0 ? '/' : '/favorites');
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '홈'),
        NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: '즐겨찾기'),
      ],
    );
  }
}
