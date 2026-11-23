import 'package:equatable/equatable.dart';

class Episode extends Equatable {
  const Episode({
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
