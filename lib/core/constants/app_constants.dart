class AppConstants {
  AppConstants._();

  static const String appName = 'Popular Movies';
  static const String favoritesKey = 'favorite_movies';

  static const int moviesPerPage = 20;

  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
  static const Duration searchDebounce = Duration(milliseconds: 500);
}
