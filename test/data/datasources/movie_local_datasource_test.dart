import 'package:flutter_test/flutter_test.dart';
import 'package:popular_movies/data/datasources/movie_local_datasource.dart';
import 'package:popular_movies/data/models/movie_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late MovieLocalDataSourceImpl dataSource;
  late SharedPreferences sharedPreferences;

  const testMovie = MovieModel(
    id: 1,
    title: 'Test Movie',
    overview: 'Test overview',
    posterPath: '/test.jpg',
    voteAverage: 8.5,
  );

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    sharedPreferences = await SharedPreferences.getInstance();
    dataSource = MovieLocalDataSourceImpl(sharedPreferences: sharedPreferences);
  });

  group('MovieLocalDataSource', () {
    test('getFavorites returns empty list when no favorites', () async {
      final result = await dataSource.getFavorites();
      expect(result, isEmpty);
    });

    test('addToFavorites adds movie successfully', () async {
      await dataSource.addToFavorites(testMovie);

      final favorites = await dataSource.getFavorites();
      expect(favorites.length, 1);
      expect(favorites.first.id, testMovie.id);
    });

    test('removeFromFavorites removes movie successfully', () async {
      await dataSource.addToFavorites(testMovie);
      await dataSource.removeFromFavorites(testMovie.id);

      final favorites = await dataSource.getFavorites();
      expect(favorites, isEmpty);
    });

    test('isFavorite returns true for favorited movie', () async {
      await dataSource.addToFavorites(testMovie);

      final result = await dataSource.isFavorite(testMovie.id);
      expect(result, true);
    });

    test('isFavorite returns false for non-favorited movie', () async {
      final result = await dataSource.isFavorite(999);
      expect(result, false);
    });

    test('getFavoriteIds returns set of favorited movie ids', () async {
      await dataSource.addToFavorites(testMovie);
      await dataSource.addToFavorites(
        const MovieModel(id: 2, title: 'Test Movie 2'),
      );

      final ids = await dataSource.getFavoriteIds();
      expect(ids, {1, 2});
    });

    test('addToFavorites does not add duplicate', () async {
      await dataSource.addToFavorites(testMovie);
      await dataSource.addToFavorites(testMovie);

      final favorites = await dataSource.getFavorites();
      expect(favorites.length, 1);
    });
  });
}
