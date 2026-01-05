import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movie_repository.dart';
import 'movies_event.dart';
import 'movies_state.dart';

class MoviesBloc extends Bloc<MoviesEvent, MoviesState> {
  final MovieRepository repository;

  MoviesBloc({required this.repository}) : super(const MoviesState()) {
    on<LoadMovies>(_onLoadMovies);
    on<LoadMoreMovies>(_onLoadMoreMovies);
    on<SearchMovies>(_onSearchMovies);
    on<ClearSearch>(_onClearSearch);
    on<ToggleFavorite>(_onToggleFavorite);
    on<UpdateFavoriteIds>(_onUpdateFavoriteIds);
    on<ToggleShowFavoritesOnly>(_onToggleShowFavoritesOnly);
  }

  Future<void> _onLoadMovies(
    LoadMovies event,
    Emitter<MoviesState> emit,
  ) async {
    emit(state.copyWith(status: MoviesStatus.loading));

    final (favorites, _) = await repository.getFavorites();
    final favoriteList = favorites ?? [];
    final favoriteIds = favoriteList.map((m) => m.id).toSet();

    final isConnected = await repository.isConnected;

    if (!isConnected) {
      emit(
        state.copyWith(
          status: MoviesStatus.success,
          movies: [],
          favoriteMovies: favoriteList,
          favoriteIds: favoriteIds,
          showFavoritesOnly: true,
          failure: const NetworkFailure(
            message: 'You are offline. Showing favorite movies only.',
          ),
        ),
      );
      return;
    }

    final (response, failure) = await repository.getPopularMovies(1);

    if (failure != null) {
      emit(
        state.copyWith(
          status: MoviesStatus.failure,
          failure: failure,
          favoriteMovies: favoriteList,
          favoriteIds: favoriteIds,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: MoviesStatus.success,
        movies: response!.movies,
        favoriteMovies: favoriteList,
        favoriteIds: favoriteIds,
        currentPage: 1,
        hasReachedMax: !response.hasMorePages,
        isSearching: false,
        searchQuery: '',
        showFavoritesOnly: false,
      ),
    );
  }

  Future<void> _onLoadMoreMovies(
    LoadMoreMovies event,
    Emitter<MoviesState> emit,
  ) async {
    if (state.hasReachedMax || state.status == MoviesStatus.loadingMore) {
      return;
    }

    emit(state.copyWith(status: MoviesStatus.loadingMore));

    final nextPage = state.currentPage + 1;

    final (response, failure) = state.isSearching
        ? await repository.searchMovies(state.searchQuery, nextPage)
        : await repository.getPopularMovies(nextPage);

    if (failure != null) {
      emit(state.copyWith(status: MoviesStatus.success, failure: failure));
      return;
    }

    emit(
      state.copyWith(
        status: MoviesStatus.success,
        movies: [...state.movies, ...response!.movies],
        currentPage: nextPage,
        hasReachedMax: !response.hasMorePages,
      ),
    );
  }

  Future<void> _onSearchMovies(
    SearchMovies event,
    Emitter<MoviesState> emit,
  ) async {
    if (event.query.isEmpty) {
      add(const ClearSearch());
      return;
    }

    emit(
      state.copyWith(
        status: MoviesStatus.loading,
        isSearching: true,
        searchQuery: event.query,
      ),
    );

    final (response, failure) = await repository.searchMovies(event.query, 1);

    if (failure != null) {
      emit(state.copyWith(status: MoviesStatus.failure, failure: failure));
      return;
    }

    emit(
      state.copyWith(
        status: MoviesStatus.success,
        movies: response!.movies,
        currentPage: 1,
        hasReachedMax: !response.hasMorePages,
      ),
    );
  }

  Future<void> _onClearSearch(
    ClearSearch event,
    Emitter<MoviesState> emit,
  ) async {
    emit(state.copyWith(searchQuery: '', isSearching: false));
    add(const LoadMovies());
  }

  Future<void> _onToggleFavorite(
    ToggleFavorite event,
    Emitter<MoviesState> emit,
  ) async {
    MovieModel? movie;
    try {
      movie = state.movies.firstWhere((m) => m.id == event.movieId);
    } catch (_) {
      try {
        movie = state.favoriteMovies.firstWhere((m) => m.id == event.movieId);
      } catch (_) {
        return;
      }
    }

    final newFavoriteIds = Set<int>.from(state.favoriteIds);
    List<MovieModel> newFavoriteMovies = List.from(state.favoriteMovies);

    if (event.isFavorite) {
      newFavoriteIds.remove(event.movieId);
      newFavoriteMovies.removeWhere((m) => m.id == event.movieId);
    } else {
      newFavoriteIds.add(event.movieId);
      newFavoriteMovies.add(movie);
    }

    emit(
      state.copyWith(
        favoriteIds: newFavoriteIds,
        favoriteMovies: newFavoriteMovies,
      ),
    );

    if (event.isFavorite) {
      await repository.removeFromFavorites(event.movieId);
    } else {
      await repository.addToFavorites(movie);
    }
  }

  void _onUpdateFavoriteIds(
    UpdateFavoriteIds event,
    Emitter<MoviesState> emit,
  ) {
    emit(state.copyWith(favoriteIds: event.favoriteIds));
  }

  Future<void> _onToggleShowFavoritesOnly(
    ToggleShowFavoritesOnly event,
    Emitter<MoviesState> emit,
  ) async {
    emit(state.copyWith(showFavoritesOnly: !state.showFavoritesOnly));
  }
}
