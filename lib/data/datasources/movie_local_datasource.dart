import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_constants.dart';
import '../../core/error/exceptions.dart';
import '../models/movie_model.dart';

abstract class MovieLocalDataSource {
  Future<List<MovieModel>> getFavorites();

  Future<void> addToFavorites(MovieModel movie);

  Future<void> removeFromFavorites(int movieId);

  Future<bool> isFavorite(int movieId);

  Future<Set<int>> getFavoriteIds();
}

class MovieLocalDataSourceImpl implements MovieLocalDataSource {
  final SharedPreferences sharedPreferences;

  MovieLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<List<MovieModel>> getFavorites() async {
    try {
      final jsonString = sharedPreferences.getString(AppConstants.favoritesKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => MovieModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      throw CacheException(message: 'Failed to get favorites: ${e.toString()}');
    }
  }

  @override
  Future<void> addToFavorites(MovieModel movie) async {
    try {
      final favorites = await getFavorites();

      if (favorites.any((m) => m.id == movie.id)) {
        return;
      }

      favorites.add(movie);
      await _saveFavorites(favorites);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to add to favorites: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> removeFromFavorites(int movieId) async {
    try {
      final favorites = await getFavorites();
      favorites.removeWhere((movie) => movie.id == movieId);
      await _saveFavorites(favorites);
    } catch (e) {
      if (e is CacheException) rethrow;
      throw CacheException(
        message: 'Failed to remove from favorites: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    try {
      final favoriteIds = await getFavoriteIds();
      return favoriteIds.contains(movieId);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Set<int>> getFavoriteIds() async {
    try {
      final favorites = await getFavorites();
      return favorites.map((m) => m.id).toSet();
    } catch (e) {
      return {};
    }
  }

  Future<void> _saveFavorites(List<MovieModel> favorites) async {
    final jsonList = favorites.map((m) => m.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await sharedPreferences.setString(AppConstants.favoritesKey, jsonString);
  }
}
