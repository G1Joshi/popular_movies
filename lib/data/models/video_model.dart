import 'package:equatable/equatable.dart';

class VideoModel extends Equatable {
  final String id;
  final String key;
  final String name;
  final String site;
  final String type;
  final bool official;
  final String? publishedAt;

  const VideoModel({
    required this.id,
    required this.key,
    required this.name,
    required this.site,
    required this.type,
    this.official = false,
    this.publishedAt,
  });

  factory VideoModel.fromJson(Map<String, dynamic> json) {
    return VideoModel(
      id: json['id'] as String,
      key: json['key'] as String,
      name: json['name'] as String,
      site: json['site'] as String,
      type: json['type'] as String,
      official: json['official'] as bool? ?? false,
      publishedAt: json['published_at'] as String?,
    );
  }

  bool get isYouTube => site.toLowerCase() == 'youtube';
  bool get isTrailer => type.toLowerCase() == 'trailer';

  @override
  List<Object?> get props => [id, key, name, site, type, official];
}

class VideosResponse extends Equatable {
  final List<VideoModel> results;

  const VideosResponse({required this.results});

  factory VideosResponse.fromJson(Map<String, dynamic> json) {
    return VideosResponse(
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => VideoModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  List<VideoModel> get trailers =>
      results.where((v) => v.isTrailer && v.isYouTube).toList();

  @override
  List<Object?> get props => [results];
}
