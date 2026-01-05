import 'movie_model.dart';

class MoviesResponse {
  final int page;
  final List<MovieModel> movies;
  final int totalPages;
  final int totalResults;

  const MoviesResponse({
    required this.page,
    required this.movies,
    required this.totalPages,
    required this.totalResults,
  });

  factory MoviesResponse.fromJson(Map<String, dynamic> json) {
    return MoviesResponse(
      page: json['page'] as int? ?? 1,
      movies:
          (json['results'] as List<dynamic>?)
              ?.map((e) => MovieModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalPages: json['total_pages'] as int? ?? 1,
      totalResults: json['total_results'] as int? ?? 0,
    );
  }

  bool get hasMorePages => page < totalPages;
}
