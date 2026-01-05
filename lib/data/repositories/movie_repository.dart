import '../../core/error/exceptions.dart';
import '../../core/error/failures.dart';
import '../../core/network/connectivity_service.dart';
import '../datasources/movie_local_datasource.dart';
import '../datasources/movie_remote_datasource.dart';
import '../models/cast_model.dart';
import '../models/movie_detail_model.dart';
import '../models/movie_model.dart';
import '../models/movies_response.dart';
import '../models/review_model.dart';
import '../models/video_model.dart';

abstract class MovieRepository {
  Future<(MoviesResponse?, Failure?)> getPopularMovies(int page);

  Future<(MoviesResponse?, Failure?)> getTopRatedMovies(int page);

  Future<(MoviesResponse?, Failure?)> getNowPlayingMovies(int page);

  Future<(MoviesResponse?, Failure?)> searchMovies(String query, int page);

  Future<(MovieDetailModel?, Failure?)> getMovieDetails(int movieId);

  Future<(CreditsModel?, Failure?)> getMovieCredits(int movieId);

  Future<(ReviewsResponse?, Failure?)> getMovieReviews(int movieId);

  Future<(VideosResponse?, Failure?)> getMovieVideos(int movieId);

  Future<(List<MovieModel>?, Failure?)> getFavorites();

  Future<Failure?> addToFavorites(MovieModel movie);

  Future<Failure?> removeFromFavorites(int movieId);

  Future<(bool?, Failure?)> toggleFavorite(MovieModel movie);

  Future<bool> isFavorite(int movieId);

  Future<Set<int>> getFavoriteIds();

  Future<bool> get isConnected;

  Stream<bool> get onConnectivityChanged;
}

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;
  final ConnectivityService connectivityService;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.connectivityService,
  });

  @override
  Future<(MoviesResponse?, Failure?)> getPopularMovies(int page) async {
    if (!await isConnected) {
      return (null, const NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getPopularMovies(page);

      if (result.movies.isEmpty) {
        return (null, const EmptyResultFailure());
      }

      return (result, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(MoviesResponse?, Failure?)> getTopRatedMovies(int page) async {
    if (!await isConnected) {
      return (null, const NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getTopRatedMovies(page);

      if (result.movies.isEmpty) {
        return (null, const EmptyResultFailure());
      }

      return (result, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(MoviesResponse?, Failure?)> getNowPlayingMovies(int page) async {
    if (!await isConnected) {
      return (null, const NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getNowPlayingMovies(page);

      if (result.movies.isEmpty) {
        return (null, const EmptyResultFailure());
      }

      return (result, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(MoviesResponse?, Failure?)> searchMovies(
    String query,
    int page,
  ) async {
    if (!await isConnected) {
      return (null, const NetworkFailure());
    }

    try {
      final result = await remoteDataSource.searchMovies(query, page);

      if (result.movies.isEmpty) {
        return (
          null,
          EmptyResultFailure(message: 'No movies found for "$query"'),
        );
      }

      return (result, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(MovieDetailModel?, Failure?)> getMovieDetails(int movieId) async {
    if (!await isConnected) {
      return (null, const NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getMovieDetails(movieId);
      return (result, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(CreditsModel?, Failure?)> getMovieCredits(int movieId) async {
    if (!await isConnected) {
      return (null, const NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getMovieCredits(movieId);
      return (result, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(ReviewsResponse?, Failure?)> getMovieReviews(int movieId) async {
    if (!await isConnected) {
      return (null, const NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getMovieReviews(movieId);
      return (result, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(VideosResponse?, Failure?)> getMovieVideos(int movieId) async {
    if (!await isConnected) {
      return (null, const NetworkFailure());
    }

    try {
      final result = await remoteDataSource.getMovieVideos(movieId);
      return (result, null);
    } on ServerException catch (e) {
      return (
        null,
        ServerFailure(message: e.message, statusCode: e.statusCode),
      );
    } catch (e) {
      return (null, ServerFailure(message: e.toString()));
    }
  }

  @override
  Future<(List<MovieModel>?, Failure?)> getFavorites() async {
    try {
      final result = await localDataSource.getFavorites();
      return (result, null);
    } on CacheException catch (e) {
      return (null, CacheFailure(message: e.message));
    } catch (e) {
      return (null, CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<Failure?> addToFavorites(MovieModel movie) async {
    try {
      await localDataSource.addToFavorites(movie);
      return null;
    } on CacheException catch (e) {
      return CacheFailure(message: e.message);
    } catch (e) {
      return CacheFailure(message: e.toString());
    }
  }

  @override
  Future<Failure?> removeFromFavorites(int movieId) async {
    try {
      await localDataSource.removeFromFavorites(movieId);
      return null;
    } on CacheException catch (e) {
      return CacheFailure(message: e.message);
    } catch (e) {
      return CacheFailure(message: e.toString());
    }
  }

  @override
  Future<(bool?, Failure?)> toggleFavorite(MovieModel movie) async {
    try {
      final isFav = await localDataSource.isFavorite(movie.id);

      if (isFav) {
        await localDataSource.removeFromFavorites(movie.id);
        return (false, null);
      } else {
        await localDataSource.addToFavorites(movie);
        return (true, null);
      }
    } on CacheException catch (e) {
      return (null, CacheFailure(message: e.message));
    } catch (e) {
      return (null, CacheFailure(message: e.toString()));
    }
  }

  @override
  Future<bool> isFavorite(int movieId) async {
    return localDataSource.isFavorite(movieId);
  }

  @override
  Future<Set<int>> getFavoriteIds() async {
    return localDataSource.getFavoriteIds();
  }

  @override
  Future<bool> get isConnected => connectivityService.isConnected;

  @override
  Stream<bool> get onConnectivityChanged =>
      connectivityService.onConnectivityChanged;
}
