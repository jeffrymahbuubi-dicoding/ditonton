import 'package:tv_series/domain/entities/season.dart';
import 'package:equatable/equatable.dart';

class SeasonModel extends Equatable {
  const SeasonModel({
    required this.id,
    required this.seasonNumber,
    required this.episodeCount,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.airDate,
  });

  final int id;
  final int seasonNumber;
  final int episodeCount;
  final String name;
  final String? overview;
  final String? posterPath;
  final String? airDate;

  factory SeasonModel.fromJson(Map<String, dynamic> json) => SeasonModel(
    id: json['id'],
    seasonNumber: json['season_number'],
    episodeCount: json['episode_count'] ?? 0,
    name: json['name'] ?? '',
    overview: json['overview'],
    posterPath: json['poster_path'],
    airDate: json['air_date'],
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'season_number': seasonNumber,
    'episode_count': episodeCount,
    'name': name,
    'overview': overview,
    'poster_path': posterPath,
    'air_date': airDate,
  };

  Season toEntity() => Season(
    id: id,
    seasonNumber: seasonNumber,
    episodeCount: episodeCount,
    name: name,
    overview: overview,
    posterPath: posterPath,
    airDate: airDate,
  );

  @override
  List<Object?> get props => [
    id,
    seasonNumber,
    episodeCount,
    name,
    overview,
    posterPath,
    airDate,
  ];
}
