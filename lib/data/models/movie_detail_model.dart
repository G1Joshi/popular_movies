import 'package:equatable/equatable.dart';

class MovieDetailModel extends Equatable {
  final int id;
  final String title;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double voteAverage;
  final int voteCount;
  final String? releaseDate;
  final List<Genre> genres;
  final int? runtime;
  final String? status;
  final String? tagline;
  final int? budget;
  final int? revenue;
  final String? homepage;
  final String originalLanguage;
  final List<ProductionCompany> productionCompanies;

  const MovieDetailModel({
    required this.id,
    required this.title,
    this.overview,
    this.posterPath,
    this.backdropPath,
    this.voteAverage = 0.0,
    this.voteCount = 0,
    this.releaseDate,
    this.genres = const [],
    this.runtime,
    this.status,
    this.tagline,
    this.budget,
    this.revenue,
    this.homepage,
    this.originalLanguage = 'en',
    this.productionCompanies = const [],
  });

  factory MovieDetailModel.fromJson(Map<String, dynamic> json) {
    return MovieDetailModel(
      id: json['id'] as int,
      title: json['title'] as String? ?? 'Unknown',
      overview: json['overview'] as String?,
      posterPath: json['poster_path'] as String?,
      backdropPath: json['backdrop_path'] as String?,
      voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0.0,
      voteCount: json['vote_count'] as int? ?? 0,
      releaseDate: json['release_date'] as String?,
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((e) => Genre.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      runtime: json['runtime'] as int?,
      status: json['status'] as String?,
      tagline: json['tagline'] as String?,
      budget: json['budget'] as int?,
      revenue: json['revenue'] as int?,
      homepage: json['homepage'] as String?,
      originalLanguage: json['original_language'] as String? ?? 'en',
      productionCompanies:
          (json['production_companies'] as List<dynamic>?)
              ?.map(
                (e) => ProductionCompany.fromJson(e as Map<String, dynamic>),
              )
              .toList() ??
          [],
    );
  }

  String get formattedRuntime {
    if (runtime == null) return 'Unknown';
    final hours = runtime! ~/ 60;
    final minutes = runtime! % 60;
    if (hours > 0) {
      return '${hours}h ${minutes}m';
    }
    return '${minutes}m';
  }

  String get genresString => genres.map((g) => g.name).join(', ');

  @override
  List<Object?> get props => [
    id,
    title,
    overview,
    posterPath,
    backdropPath,
    voteAverage,
    releaseDate,
    genres,
  ];
}

class Genre extends Equatable {
  final int id;
  final String name;

  const Genre({required this.id, required this.name});

  factory Genre.fromJson(Map<String, dynamic> json) {
    return Genre(id: json['id'] as int, name: json['name'] as String);
  }

  @override
  List<Object?> get props => [id, name];
}

class ProductionCompany extends Equatable {
  final int id;
  final String name;
  final String? logoPath;
  final String? originCountry;

  const ProductionCompany({
    required this.id,
    required this.name,
    this.logoPath,
    this.originCountry,
  });

  factory ProductionCompany.fromJson(Map<String, dynamic> json) {
    return ProductionCompany(
      id: json['id'] as int,
      name: json['name'] as String,
      logoPath: json['logo_path'] as String?,
      originCountry: json['origin_country'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name];
}
