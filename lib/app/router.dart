import 'package:go_router/go_router.dart';

import '../presentation/complete/complete_screen.dart';
import '../presentation/favorites/favorites_screen.dart';
import '../presentation/guide/step_guide_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/safety/safety_check_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
    GoRoute(
      path: '/safety/:id',
      builder: (_, s) => SafetyCheckScreen(symptomId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/guide/:id',
      builder: (_, s) => StepGuideScreen(symptomId: s.pathParameters['id']!),
    ),
    GoRoute(
      path: '/complete/:id',
      builder: (_, s) => CompleteScreen(symptomId: s.pathParameters['id']!),
    ),
  ],
);
