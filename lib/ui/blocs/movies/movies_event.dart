import 'package:equatable/equatable.dart';

abstract class MoviesEvent extends Equatable {
  const MoviesEvent();

  @override
  List<Object?> get props => [];
}

class LoadMovies extends MoviesEvent {
  final bool refresh;

  const LoadMovies({this.refresh = false});

  @override
  List<Object?> get props => [refresh];
}

class LoadMoreMovies extends MoviesEvent {
  const LoadMoreMovies();
}

class SearchMovies extends MoviesEvent {
  final String query;

  const SearchMovies(this.query);

  @override
  List<Object?> get props => [query];
}

class ClearSearch extends MoviesEvent {
  const ClearSearch();
}

class ToggleFavorite extends MoviesEvent {
  final int movieId;
  final bool isFavorite;

  const ToggleFavorite({required this.movieId, required this.isFavorite});

  @override
  List<Object?> get props => [movieId, isFavorite];
}

class UpdateFavoriteIds extends MoviesEvent {
  final Set<int> favoriteIds;

  const UpdateFavoriteIds(this.favoriteIds);

  @override
  List<Object?> get props => [favoriteIds];
}

class ToggleShowFavoritesOnly extends MoviesEvent {
  const ToggleShowFavoritesOnly();
}
