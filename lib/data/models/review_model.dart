import 'package:equatable/equatable.dart';

class ReviewModel extends Equatable {
  final String id;
  final String author;
  final String? content;
  final String? createdAt;
  final AuthorDetails? authorDetails;

  const ReviewModel({
    required this.id,
    required this.author,
    this.content,
    this.createdAt,
    this.authorDetails,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) {
    return ReviewModel(
      id: json['id'] as String,
      author: json['author'] as String? ?? 'Anonymous',
      content: json['content'] as String?,
      createdAt: json['created_at'] as String?,
      authorDetails: json['author_details'] != null
          ? AuthorDetails.fromJson(
              json['author_details'] as Map<String, dynamic>,
            )
          : null,
    );
  }

  @override
  List<Object?> get props => [id, author, content, createdAt];
}

class AuthorDetails extends Equatable {
  final String? name;
  final String? username;
  final String? avatarPath;
  final double? rating;

  const AuthorDetails({this.name, this.username, this.avatarPath, this.rating});

  factory AuthorDetails.fromJson(Map<String, dynamic> json) {
    return AuthorDetails(
      name: json['name'] as String?,
      username: json['username'] as String?,
      avatarPath: json['avatar_path'] as String?,
      rating: (json['rating'] as num?)?.toDouble(),
    );
  }

  String get displayName => name ?? username ?? 'Anonymous';

  @override
  List<Object?> get props => [name, username, avatarPath, rating];
}

class ReviewsResponse extends Equatable {
  final List<ReviewModel> reviews;
  final int totalResults;

  const ReviewsResponse({this.reviews = const [], this.totalResults = 0});

  factory ReviewsResponse.fromJson(Map<String, dynamic> json) {
    return ReviewsResponse(
      reviews:
          (json['results'] as List<dynamic>?)
              ?.map((e) => ReviewModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      totalResults: json['total_results'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [reviews, totalResults];
}
