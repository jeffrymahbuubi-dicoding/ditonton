import 'package:tv_series/domain/entities/episode.dart';
import 'package:equatable/equatable.dart';

class EpisodeModel extends Equatable {
  const EpisodeModel({
    required this.id,
    required this.episodeNumber,
    required this.seasonNumber,
    required this.name,
    required this.overview,
    required this.stillPath,
    required this.airDate,
    required this.runtime,
    required this.voteAverage,
  });

  final int id;
  final int episodeNumber;
  final int seasonNumber;
  final String name;
  final String? overview;
  final String? stillPath;
  final String? airDate;
  final int? runtime;
  final double voteAverage;

  factory EpisodeModel.fromJson(Map<String, dynamic> json) => EpisodeModel(
    id: json['id'],
    episodeNumber: json['episode_number'],
    seasonNumber: json['season_number'],
    name: json['name'] ?? '',
    overview: json['overview'],
    stillPath: json['still_path'],
    airDate: json['air_date'],
    runtime: json['runtime'],
    voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'episode_number': episodeNumber,
    'season_number': seasonNumber,
    'name': name,
    'overview': overview,
    'still_path': stillPath,
    'air_date': airDate,
    'runtime': runtime,
    'vote_average': voteAverage,
  };

  Episode toEntity() => Episode(
    id: id,
    episodeNumber: episodeNumber,
    seasonNumber: seasonNumber,
    name: name,
    overview: overview,
    stillPath: stillPath,
    airDate: airDate,
    runtime: runtime,
    voteAverage: voteAverage,
  );

  @override
  List<Object?> get props => [
    id,
    episodeNumber,
    seasonNumber,
    name,
    overview,
    stillPath,
    airDate,
    runtime,
    voteAverage,
  ];
}
