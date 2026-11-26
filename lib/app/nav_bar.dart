import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

const navRoutes = ['/', '/ai', '/favorites', '/more', '/my'];

/// 하단 탭: 홈 · AI검사 · 즐겨찾기 · 더보기 · MY. index는 navRoutes 순서와 같다.
class TapeFitNavBar extends StatelessWidget {
  const TapeFitNavBar({super.key, required this.index});
  final int index;

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: index,
      onDestinationSelected: (i) {
        if (i == index) return;
        context.go(navRoutes[i]);
      },
      destinations: const [
        NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: '홈'),
        NavigationDestination(icon: Icon(Icons.auto_awesome_outlined), selectedIcon: Icon(Icons.auto_awesome), label: 'AI검사'),
        NavigationDestination(icon: Icon(Icons.star_outline), selectedIcon: Icon(Icons.star), label: '즐겨찾기'),
        NavigationDestination(icon: Icon(Icons.more_horiz), selectedIcon: Icon(Icons.more_horiz), label: '더보기'),
        NavigationDestination(icon: Icon(Icons.person_outline), selectedIcon: Icon(Icons.person), label: 'MY'),
      ],
    );
  }
}
