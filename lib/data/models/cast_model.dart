import 'package:equatable/equatable.dart';

class CastModel extends Equatable {
  final int id;
  final String name;
  final String? character;
  final String? profilePath;
  final int order;

  const CastModel({
    required this.id,
    required this.name,
    this.character,
    this.profilePath,
    this.order = 0,
  });

  factory CastModel.fromJson(Map<String, dynamic> json) {
    return CastModel(
      id: json['id'] as int,
      name: json['name'] as String? ?? 'Unknown',
      character: json['character'] as String?,
      profilePath: json['profile_path'] as String?,
      order: json['order'] as int? ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, character, profilePath];
}

class CreditsModel extends Equatable {
  final List<CastModel> cast;

  const CreditsModel({this.cast = const []});

  factory CreditsModel.fromJson(Map<String, dynamic> json) {
    return CreditsModel(
      cast:
          (json['cast'] as List<dynamic>?)
              ?.map((e) => CastModel.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  @override
  List<Object?> get props => [cast];
}
