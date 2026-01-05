import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/movie_model.dart';
import '../../../data/repositories/movie_repository.dart';
import 'movie_detail_event.dart';
import 'movie_detail_state.dart';

class MovieDetailBloc extends Bloc<MovieDetailEvent, MovieDetailState> {
  final MovieRepository repository;

  MovieDetailBloc({required this.repository})
    : super(const MovieDetailState()) {
    on<LoadMovieDetail>(_onLoadMovieDetail);
    on<ToggleDetailFavorite>(_onToggleDetailFavorite);
  }

  Future<void> _onLoadMovieDetail(
    LoadMovieDetail event,
    Emitter<MovieDetailState> emit,
  ) async {
    emit(state.copyWith(status: MovieDetailStatus.loading));

    final isConnected = await repository.isConnected;

    if (!isConnected) {
      emit(
        state.copyWith(
          status: MovieDetailStatus.failure,
          failure: NetworkFailure(),
        ),
      );
      return;
    }

    final results = await Future.wait([
      repository.getMovieDetails(event.movieId),
      repository.getMovieCredits(event.movieId),
      repository.getMovieReviews(event.movieId),
      repository.getMovieVideos(event.movieId),
      repository.isFavorite(event.movieId),
    ]);

    final (movie, movieFailure) = results[0] as (dynamic, dynamic);
    final (credits, _) = results[1] as (dynamic, dynamic);
    final (reviews, _) = results[2] as (dynamic, dynamic);
    final (videosResponse, _) = results[3] as (dynamic, dynamic);
    final isFavorite = results[4] as bool;

    if (movieFailure != null) {
      emit(
        state.copyWith(
          status: MovieDetailStatus.failure,
          failure: movieFailure,
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        status: MovieDetailStatus.success,
        movie: movie,
        cast: credits?.cast ?? [],
        reviews: reviews?.reviews ?? [],
        videos: videosResponse?.trailers ?? [],
        isFavorite: isFavorite,
      ),
    );
  }

  Future<void> _onToggleDetailFavorite(
    ToggleDetailFavorite event,
    Emitter<MovieDetailState> emit,
  ) async {
    if (state.movie == null) return;

    final movie = state.movie!;
    final currentFavorite = state.isFavorite;

    emit(state.copyWith(isFavorite: !currentFavorite));

    final movieModel = MovieModel(
      id: movie.id,
      title: movie.title,
      overview: movie.overview,
      posterPath: movie.posterPath,
      backdropPath: movie.backdropPath,
      voteAverage: movie.voteAverage,
      voteCount: movie.voteCount,
      releaseDate: movie.releaseDate,
      genreIds: movie.genres.map((g) => g.id).toList(),
    );

    final (_, failure) = await repository.toggleFavorite(movieModel);

    if (failure != null) {
      emit(state.copyWith(isFavorite: currentFavorite));
    }
  }
}
