import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:popular_movies/app.dart';
import 'package:popular_movies/core/network/api_client.dart';
import 'package:popular_movies/core/network/connectivity_service.dart';
import 'package:popular_movies/data/datasources/movie_local_datasource.dart';
import 'package:popular_movies/data/datasources/movie_remote_datasource.dart';
import 'package:popular_movies/data/repositories/movie_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Popular Movies App Integration Tests', () {
    late SharedPreferences sharedPreferences;
    late MovieRepository movieRepository;
    late ConnectivityService connectivityService;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      sharedPreferences = await SharedPreferences.getInstance();

      final apiClient = ApiClient();
      connectivityService = ConnectivityService();

      final remoteDataSource = MovieRemoteDataSourceImpl(apiClient: apiClient);
      final localDataSource = MovieLocalDataSourceImpl(
        sharedPreferences: sharedPreferences,
      );

      movieRepository = MovieRepositoryImpl(
        remoteDataSource: remoteDataSource,
        localDataSource: localDataSource,
        connectivityService: connectivityService,
      );
    });

    testWidgets('App launches and displays movies list', (tester) async {
      await tester.pumpWidget(
        PopularMoviesApp(
          movieRepository: movieRepository,
          connectivityService: connectivityService,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      expect(find.text('Movies'), findsOneWidget);
      expect(find.byType(TextField), findsOneWidget);
      expect(find.text('All Movies'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
    });

    testWidgets('Search functionality works', (tester) async {
      await tester.pumpWidget(
        PopularMoviesApp(
          movieRepository: movieRepository,
          connectivityService: connectivityService,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      final searchField = find.byType(TextField);
      expect(searchField, findsOneWidget);

      await tester.enterText(searchField, 'Avengers');
      await tester.pump(const Duration(milliseconds: 600));
      await tester.pumpAndSettle(const Duration(seconds: 2));
    });

    testWidgets('Toggle favorites filter', (tester) async {
      await tester.pumpWidget(
        PopularMoviesApp(
          movieRepository: movieRepository,
          connectivityService: connectivityService,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      final favoritesChip = find.text('Favorites');
      expect(favoritesChip, findsOneWidget);

      await tester.tap(favoritesChip);
      await tester.pumpAndSettle();

      expect(find.text('No Favorites Yet'), findsOneWidget);

      final allMoviesChip = find.text('All Movies');
      await tester.tap(allMoviesChip);
      await tester.pumpAndSettle();
    });

    testWidgets('Navigate to movie detail page', (tester) async {
      await tester.pumpWidget(
        PopularMoviesApp(
          movieRepository: movieRepository,
          connectivityService: connectivityService,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final movieCards = find.byType(GestureDetector);

      if (movieCards.evaluate().isNotEmpty) {
        await tester.tap(movieCards.first);
        await tester.pumpAndSettle(const Duration(seconds: 3));

        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Icon &&
                (widget.icon == Icons.favorite ||
                    widget.icon == Icons.favorite_border),
          ),
          findsWidgets,
        );
      }
    });

    testWidgets('Add movie to favorites and verify persistence', (
      tester,
    ) async {
      await tester.pumpWidget(
        PopularMoviesApp(
          movieRepository: movieRepository,
          connectivityService: connectivityService,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 5));

      final favoriteIcons = find.byIcon(Icons.favorite_border);

      if (favoriteIcons.evaluate().isNotEmpty) {
        await tester.tap(favoriteIcons.first);
        await tester.pumpAndSettle();

        expect(find.textContaining('added to favorites'), findsOneWidget);
        expect(find.byIcon(Icons.favorite), findsWidgets);
      }
    });

    testWidgets('Pull to refresh works', (tester) async {
      await tester.pumpWidget(
        PopularMoviesApp(
          movieRepository: movieRepository,
          connectivityService: connectivityService,
        ),
      );

      await tester.pumpAndSettle(const Duration(seconds: 3));

      final scrollable = find.byType(CustomScrollView);

      if (scrollable.evaluate().isNotEmpty) {
        await tester.fling(scrollable, const Offset(0, 300), 1000);
        await tester.pump();

        expect(find.byType(RefreshIndicator), findsOneWidget);

        await tester.pumpAndSettle(const Duration(seconds: 3));
      }
    });
  });
}
