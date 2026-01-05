class ApiConstants {
  ApiConstants._();
  static const String apiKey = 'API_KEY';
  static const String baseUrl = 'https://api.themoviedb.org/3';
  static const String imageBaseUrl = 'https://image.tmdb.org/t/p';

  static const String posterSizeW185 = '/w185';
  static const String posterSizeW342 = '/w342';
  static const String posterSizeW500 = '/w500';
  static const String posterSizeOriginal = '/original';

  static const String backdropSizeW780 = '/w780';
  static const String backdropSizeW1280 = '/w1280';
  static const String backdropSizeOriginal = '/original';

  static const String popularMovies = '/movie/popular';
  static const String topRatedMovies = '/movie/top_rated';
  static const String nowPlayingMovies = '/movie/now_playing';
  static const String upcomingMovies = '/movie/upcoming';
  static const String searchMovies = '/search/movie';
  static const String movieDetails = '/movie';
  static const String movieCredits = '/credits';
  static const String movieReviews = '/reviews';
  static const String movieVideos = '/videos';

  static String getPosterUrl(String? path, {String size = posterSizeW342}) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl$size$path';
  }

  static String getBackdropUrl(
    String? path, {
    String size = backdropSizeW1280,
  }) {
    if (path == null || path.isEmpty) return '';
    return '$imageBaseUrl$size$path';
  }
}
