import 'package:equatable/equatable.dart';

class Season extends Equatable {
  const Season({
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
