import '../../core/constants/api_constants.dart';
import '../../core/error/exceptions.dart';
import '../../core/network/api_client.dart';
import '../models/cast_model.dart';
import '../models/movie_detail_model.dart';
import '../models/movies_response.dart';
import '../models/review_model.dart';
import '../models/video_model.dart';

abstract class MovieRemoteDataSource {
  Future<MoviesResponse> getPopularMovies(int page);

  Future<MoviesResponse> getTopRatedMovies(int page);

  Future<MoviesResponse> getNowPlayingMovies(int page);

  Future<MoviesResponse> searchMovies(String query, int page);

  Future<MovieDetailModel> getMovieDetails(int movieId);

  Future<CreditsModel> getMovieCredits(int movieId);

  Future<ReviewsResponse> getMovieReviews(int movieId);

  Future<VideosResponse> getMovieVideos(int movieId);
}

class MovieRemoteDataSourceImpl implements MovieRemoteDataSource {
  final ApiClient apiClient;

  MovieRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<MoviesResponse> getPopularMovies(int page) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.popularMovies,
        queryParameters: {'page': page},
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return MoviesResponse.fromJson(response.data!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MoviesResponse> getTopRatedMovies(int page) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.topRatedMovies,
        queryParameters: {'page': page},
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return MoviesResponse.fromJson(response.data!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MoviesResponse> getNowPlayingMovies(int page) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.nowPlayingMovies,
        queryParameters: {'page': page},
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return MoviesResponse.fromJson(response.data!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MoviesResponse> searchMovies(String query, int page) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        ApiConstants.searchMovies,
        queryParameters: {'query': query, 'page': page},
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return MoviesResponse.fromJson(response.data!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<MovieDetailModel> getMovieDetails(int movieId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.movieDetails}/$movieId',
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return MovieDetailModel.fromJson(response.data!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<CreditsModel> getMovieCredits(int movieId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.movieDetails}/$movieId${ApiConstants.movieCredits}',
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return CreditsModel.fromJson(response.data!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<ReviewsResponse> getMovieReviews(int movieId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.movieDetails}/$movieId${ApiConstants.movieReviews}',
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return ReviewsResponse.fromJson(response.data!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }

  @override
  Future<VideosResponse> getMovieVideos(int movieId) async {
    try {
      final response = await apiClient.get<Map<String, dynamic>>(
        '${ApiConstants.movieDetails}/$movieId${ApiConstants.movieVideos}',
      );

      if (response.data == null) {
        throw const ServerException(message: 'Empty response from server');
      }

      return VideosResponse.fromJson(response.data!);
    } catch (e) {
      if (e is ServerException) rethrow;
      throw ServerException(message: e.toString());
    }
  }
}
