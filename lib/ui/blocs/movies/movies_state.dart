import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/movie_model.dart';

enum MoviesStatus { initial, loading, success, failure, loadingMore }

class MoviesState extends Equatable {
  final MoviesStatus status;
  final List<MovieModel> movies;
  final List<MovieModel> favoriteMovies;
  final Set<int> favoriteIds;
  final String searchQuery;
  final int currentPage;
  final bool hasReachedMax;
  final Failure? failure;
  final bool isSearching;
  final bool showFavoritesOnly;

  const MoviesState({
    this.status = MoviesStatus.initial,
    this.movies = const [],
    this.favoriteMovies = const [],
    this.favoriteIds = const {},
    this.searchQuery = '',
    this.currentPage = 1,
    this.hasReachedMax = false,
    this.failure,
    this.isSearching = false,
    this.showFavoritesOnly = false,
  });

  List<MovieModel> get displayedMovies {
    if (showFavoritesOnly) {
      return favoriteMovies;
    }
    return movies;
  }

  bool isFavorite(int movieId) => favoriteIds.contains(movieId);

  MoviesState copyWith({
    MoviesStatus? status,
    List<MovieModel>? movies,
    List<MovieModel>? favoriteMovies,
    Set<int>? favoriteIds,
    String? searchQuery,
    int? currentPage,
    bool? hasReachedMax,
    Failure? failure,
    bool? isSearching,
    bool? showFavoritesOnly,
  }) {
    return MoviesState(
      status: status ?? this.status,
      movies: movies ?? this.movies,
      favoriteMovies: favoriteMovies ?? this.favoriteMovies,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      searchQuery: searchQuery ?? this.searchQuery,
      currentPage: currentPage ?? this.currentPage,
      hasReachedMax: hasReachedMax ?? this.hasReachedMax,
      failure: failure,
      isSearching: isSearching ?? this.isSearching,
      showFavoritesOnly: showFavoritesOnly ?? this.showFavoritesOnly,
    );
  }

  @override
  List<Object?> get props => [
    status,
    movies,
    favoriteMovies,
    favoriteIds,
    searchQuery,
    currentPage,
    hasReachedMax,
    failure,
    isSearching,
    showFavoritesOnly,
  ];
}
