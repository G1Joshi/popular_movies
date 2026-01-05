import 'package:equatable/equatable.dart';

import '../../../core/error/failures.dart';
import '../../../data/models/cast_model.dart';
import '../../../data/models/movie_detail_model.dart';
import '../../../data/models/review_model.dart';
import '../../../data/models/video_model.dart';

enum MovieDetailStatus { initial, loading, success, failure }

class MovieDetailState extends Equatable {
  final MovieDetailStatus status;
  final MovieDetailModel? movie;
  final List<CastModel> cast;
  final List<ReviewModel> reviews;
  final List<VideoModel> videos;
  final bool isFavorite;
  final Failure? failure;

  const MovieDetailState({
    this.status = MovieDetailStatus.initial,
    this.movie,
    this.cast = const [],
    this.reviews = const [],
    this.videos = const [],
    this.isFavorite = false,
    this.failure,
  });

  MovieDetailState copyWith({
    MovieDetailStatus? status,
    MovieDetailModel? movie,
    List<CastModel>? cast,
    List<ReviewModel>? reviews,
    List<VideoModel>? videos,
    bool? isFavorite,
    Failure? failure,
  }) {
    return MovieDetailState(
      status: status ?? this.status,
      movie: movie ?? this.movie,
      cast: cast ?? this.cast,
      reviews: reviews ?? this.reviews,
      videos: videos ?? this.videos,
      isFavorite: isFavorite ?? this.isFavorite,
      failure: failure,
    );
  }

  @override
  List<Object?> get props => [
    status,
    movie,
    cast,
    reviews,
    videos,
    isFavorite,
    failure,
  ];
}
