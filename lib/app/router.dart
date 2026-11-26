import 'package:go_router/go_router.dart';

import '../presentation/ai_check/ai_check_screen.dart';
import '../presentation/ai_check/ai_coming_soon_screen.dart';
import '../presentation/complete/complete_screen.dart';
import '../presentation/favorites/favorites_screen.dart';
import '../presentation/guide/step_guide_screen.dart';
import '../presentation/home/home_screen.dart';
import '../presentation/more/glossary_screen.dart';
import '../presentation/intro/tape_intro_screen.dart';
import '../presentation/more/more_screen.dart';
import '../presentation/my/my_screen.dart';
import '../presentation/safety/safety_check_screen.dart';

final appRouter = GoRouter(
  routes: [
    GoRoute(path: '/', builder: (_, __) => const HomeScreen()),
    GoRoute(path: '/ai', builder: (_, __) => const AiComingSoonScreen()),
    GoRoute(path: '/ai-preview', builder: (_, __) => const AiCheckScreen()),
    GoRoute(path: '/favorites', builder: (_, __) => const FavoritesScreen()),
    GoRoute(path: '/more', builder: (_, __) => const MoreScreen()),
    GoRoute(path: '/intro', builder: (_, __) => const TapeIntroScreen()),
    GoRoute(path: '/glossary', builder: (_, __) => const GlossaryScreen()),
    GoRoute(path: '/my', builder: (_, __) => const MyScreen()),
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
