import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/network/api_client.dart';
import 'core/network/connectivity_service.dart';
import 'data/datasources/movie_local_datasource.dart';
import 'data/datasources/movie_remote_datasource.dart';
import 'data/repositories/movie_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final sharedPreferences = await SharedPreferences.getInstance();

  final apiClient = ApiClient();
  final connectivityService = ConnectivityService();

  final remoteDataSource = MovieRemoteDataSourceImpl(apiClient: apiClient);
  final localDataSource = MovieLocalDataSourceImpl(
    sharedPreferences: sharedPreferences,
  );

  final movieRepository = MovieRepositoryImpl(
    remoteDataSource: remoteDataSource,
    localDataSource: localDataSource,
    connectivityService: connectivityService,
  );

  runApp(
    PopularMoviesApp(
      movieRepository: movieRepository,
      connectivityService: connectivityService,
    ),
  );
}
