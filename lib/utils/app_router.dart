import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:nasa_app/animations/rocket_animation.dart';
import 'package:nasa_app/games/puzzle.dart';
import 'package:nasa_app/games/space_race.dart';
import 'package:nasa_app/models/lesson_model.dart';
import 'package:nasa_app/screens/auth_screen.dart';
import 'package:nasa_app/screens/control_flow_screen.dart';
import 'package:nasa_app/screens/lesson_detail.dart';
import 'package:nasa_app/screens/main_screen.dart';
import 'package:nasa_app/screens/onboarding_screen.dart';
import 'package:nasa_app/screens/splash_screen.dart';
import 'package:nasa_app/screens/test_screen.dart';
import 'package:nasa_app/screens/video_screen.dart';

class AppRouter {
  static const String onboardingPath = '/onboarding';
  static const String mainPath = '/home';
  static const String authPath = '/auth';
  static const String controlFlow = '/control-flow';
  static const String lessonDetail = '/lessonDetail';
  static const String videoPlayer = '/youtubePlayer';
  static const String testScreen = '/testScreen';
  static const String puzzleGame = '/puzzleGame';
  static const String raceGame = '/raceGame';

  static final GoRouter router = GoRouter(
    routes: [
      GoRoute(
        path: '/',
        pageBuilder: (context, state) =>
            MaterialPage(key: state.pageKey, child: const SplashScreen()),
      ),
      GoRoute(
        path: mainPath,
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          state: state,
          child: const MainScreen(),
        ),
      ),
      GoRoute(
        path: controlFlow,
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          state: state,
          child: const ControlFlowScreen(),
        ),
      ),

      GoRoute(
        path: authPath,
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          state: state,
          child: const AuthScreen(),
        ),
      ),
      GoRoute(
        path: testScreen,
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          state: state,
          child: TestScreen(lessonIndex: state.extra as int),
        ),
      ),
      GoRoute(
        path: lessonDetail,
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          state: state,
          child: LessonDetailPage(
            lesson:
                (state.extra as Map<String, dynamic>?)?['lesson'] as LessonData,
            lessonIndex:
                (state.extra as Map<String, dynamic>?)?['lessonIndex'] as int,
          ),
        ),
      ),

      GoRoute(
        path: videoPlayer,
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          state: state,
          child: VideoScreen(
            videoId: (state.extra as List)[0] as String,
            lessonData: (state.extra as List)[1] as LessonData,
          ),
        ),
      ),
      GoRoute(
        path: onboardingPath,
        pageBuilder: (context, state) => buildPageWithRocketTransition(
          state: state,
          child: OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: puzzleGame,
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          state: state,
          child: const PuzzleGame(),
        ),
      ),
      GoRoute(
        path: raceGame,
        pageBuilder: (context, state) => buildPageWithSlideRightTransition(
          state: state,
          child: const RaceGameHost(),
        ),
      ),
    ],
  );
}

CustomTransitionPage<void> buildPageWithRocketTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 1800),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return RocketTransitionWidget(animation: animation, child: child);
    },
  );
}

CustomTransitionPage<void> buildPageWithSlideRightTransition({
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 500),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnimation = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(animation);
      return SlideTransition(position: offsetAnimation, child: child);
    },
  );
}
