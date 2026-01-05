import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'core/network/connectivity_service.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/movie_repository.dart';
import 'ui/blocs/connectivity/connectivity_bloc.dart';
import 'ui/blocs/connectivity/connectivity_event.dart';
import 'ui/blocs/movies/movies_bloc.dart';
import 'ui/router/app_router.dart';

class PopularMoviesApp extends StatelessWidget {
  final MovieRepository movieRepository;
  final ConnectivityService connectivityService;

  const PopularMoviesApp({
    super.key,
    required this.movieRepository,
    required this.connectivityService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider<MovieRepository>.value(value: movieRepository),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (context) =>
                ConnectivityBloc(connectivityService: connectivityService)
                  ..add(const StartConnectivityMonitoring()),
          ),
          BlocProvider(
            create: (context) => MoviesBloc(repository: movieRepository),
          ),
        ],
        child: MaterialApp.router(
          title: 'Popular Movies',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.darkTheme,
          routerConfig: AppRouter.router,
        ),
      ),
    );
  }
}
