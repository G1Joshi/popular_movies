import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:popular_movies/core/error/failures.dart';
import 'package:popular_movies/data/models/movie_model.dart';
import 'package:popular_movies/data/models/movies_response.dart';
import 'package:popular_movies/data/repositories/movie_repository.dart';
import 'package:popular_movies/ui/blocs/movies/movies_bloc.dart';
import 'package:popular_movies/ui/blocs/movies/movies_event.dart';
import 'package:popular_movies/ui/blocs/movies/movies_state.dart';

class MockMovieRepository extends Mock implements MovieRepository {}

void main() {
  late MockMovieRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(const MovieModel(id: 0, title: 'Fallback'));
  });

  setUp(() {
    mockRepository = MockMovieRepository();
  });

  final testMovies = [
    const MovieModel(
      id: 1,
      title: 'Test Movie 1',
      overview: 'Test overview 1',
      posterPath: '/test1.jpg',
      voteAverage: 8.5,
    ),
    const MovieModel(
      id: 2,
      title: 'Test Movie 2',
      overview: 'Test overview 2',
      posterPath: '/test2.jpg',
      voteAverage: 7.0,
    ),
  ];

  final testMoviesResponse = MoviesResponse(
    page: 1,
    movies: testMovies,
    totalPages: 5,
    totalResults: 100,
  );

  group('MoviesBloc', () {
    test('initial state is correct', () {
      when(
        () => mockRepository.getFavorites(),
      ).thenAnswer((_) async => (<MovieModel>[], null));
      when(() => mockRepository.isConnected).thenAnswer((_) async => true);

      final bloc = MoviesBloc(repository: mockRepository);
      expect(bloc.state, const MoviesState());
    });

    blocTest<MoviesBloc, MoviesState>(
      'emits [loading, success] when LoadMovies is added successfully',
      build: () {
        when(
          () => mockRepository.getFavorites(),
        ).thenAnswer((_) async => (<MovieModel>[], null));
        when(() => mockRepository.isConnected).thenAnswer((_) async => true);
        when(
          () => mockRepository.getPopularMovies(1),
        ).thenAnswer((_) async => (testMoviesResponse, null));
        return MoviesBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadMovies()),
      expect: () => [
        const MoviesState(status: MoviesStatus.loading),
        MoviesState(
          status: MoviesStatus.success,
          movies: testMovies,
          favoriteMovies: const [],
          favoriteIds: const {},
          currentPage: 1,
          hasReachedMax: false,
          isSearching: false,
          searchQuery: '',
          showFavoritesOnly: false,
        ),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits [loading, failure] when LoadMovies fails',
      build: () {
        when(
          () => mockRepository.getFavorites(),
        ).thenAnswer((_) async => (<MovieModel>[], null));
        when(() => mockRepository.isConnected).thenAnswer((_) async => true);
        when(() => mockRepository.getPopularMovies(1)).thenAnswer(
          (_) async => (null, const ServerFailure(message: 'Server error')),
        );
        return MoviesBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadMovies()),
      expect: () => [
        const MoviesState(status: MoviesStatus.loading),
        isA<MoviesState>()
            .having((s) => s.status, 'status', MoviesStatus.failure)
            .having((s) => s.failure, 'failure', isA<ServerFailure>()),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits offline state when no connection',
      build: () {
        when(
          () => mockRepository.getFavorites(),
        ).thenAnswer((_) async => (testMovies, null));
        when(() => mockRepository.isConnected).thenAnswer((_) async => false);
        return MoviesBloc(repository: mockRepository);
      },
      act: (bloc) => bloc.add(const LoadMovies()),
      expect: () => [
        const MoviesState(status: MoviesStatus.loading),
        isA<MoviesState>()
            .having((s) => s.status, 'status', MoviesStatus.success)
            .having((s) => s.showFavoritesOnly, 'showFavoritesOnly', true)
            .having((s) => s.favoriteMovies.length, 'favoriteMovies', 2),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits updated state when ToggleFavorite adds movie',
      build: () {
        when(
          () => mockRepository.addToFavorites(any()),
        ).thenAnswer((_) async => null);
        return MoviesBloc(repository: mockRepository);
      },
      seed: () => MoviesState(
        status: MoviesStatus.success,
        movies: testMovies,
        favoriteIds: const {},
        favoriteMovies: const [],
      ),
      act: (bloc) =>
          bloc.add(const ToggleFavorite(movieId: 1, isFavorite: false)),
      expect: () => [
        isA<MoviesState>().having(
          (s) => s.favoriteIds.contains(1),
          'contains id 1',
          true,
        ),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits updated state when ToggleFavorite removes movie',
      build: () {
        when(
          () => mockRepository.removeFromFavorites(1),
        ).thenAnswer((_) async => null);
        return MoviesBloc(repository: mockRepository);
      },
      seed: () => MoviesState(
        status: MoviesStatus.success,
        movies: testMovies,
        favoriteIds: const {1},
        favoriteMovies: [testMovies[0]],
      ),
      act: (bloc) =>
          bloc.add(const ToggleFavorite(movieId: 1, isFavorite: true)),
      expect: () => [
        isA<MoviesState>().having(
          (s) => s.favoriteIds.contains(1),
          'contains id 1',
          false,
        ),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits toggled showFavoritesOnly state',
      build: () => MoviesBloc(repository: mockRepository),
      seed: () => const MoviesState(
        status: MoviesStatus.success,
        showFavoritesOnly: false,
      ),
      act: (bloc) => bloc.add(const ToggleShowFavoritesOnly()),
      expect: () => [
        isA<MoviesState>().having(
          (s) => s.showFavoritesOnly,
          'showFavoritesOnly',
          true,
        ),
      ],
    );

    blocTest<MoviesBloc, MoviesState>(
      'emits search results when SearchMovies is called',
      build: () {
        when(
          () => mockRepository.searchMovies('test', 1),
        ).thenAnswer((_) async => (testMoviesResponse, null));
        return MoviesBloc(repository: mockRepository);
      },
      seed: () => const MoviesState(status: MoviesStatus.success),
      act: (bloc) => bloc.add(const SearchMovies('test')),
      expect: () => [
        isA<MoviesState>()
            .having((s) => s.status, 'status', MoviesStatus.loading)
            .having((s) => s.isSearching, 'isSearching', true)
            .having((s) => s.searchQuery, 'searchQuery', 'test'),
        isA<MoviesState>()
            .having((s) => s.status, 'status', MoviesStatus.success)
            .having((s) => s.movies.length, 'movies length', 2),
      ],
    );
  });
}
