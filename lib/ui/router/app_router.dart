import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../screens/movie_detail_screen.dart';
import '../screens/movies_list_screen.dart';
import '../screens/splash_screen.dart';

class AppRouter {
  static final GoRouter router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/movies',
        name: 'movies',
        builder: (context, state) => const MoviesListScreen(),
      ),
      GoRoute(
        path: '/movie/:id',
        name: 'movie_detail',
        pageBuilder: (context, state) {
          final movieId = int.parse(state.pathParameters['id']!);
          return CustomTransitionPage(
            key: state.pageKey,
            child: MovieDetailScreen(movieId: movieId),
            transitionsBuilder:
                (context, animation, secondaryAnimation, child) {
                  return FadeTransition(opacity: animation, child: child);
                },
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Error')),
      body: Center(child: Text('Page not found: ${state.uri}')),
    ),
  );
}
