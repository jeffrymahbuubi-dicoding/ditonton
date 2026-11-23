import 'package:core/core.dart';
import 'package:tv_series/domain/entities/season.dart';
import 'package:equatable/equatable.dart';

class TvSeriesDetail extends Equatable {
  const TvSeriesDetail({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.firstAirDate,
    required this.voteAverage,
    required this.voteCount,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.genres,
    required this.seasons,
  });

  final int id;
  final String name;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final String? firstAirDate;
  final double voteAverage;
  final int voteCount;
  final int numberOfSeasons;
  final int numberOfEpisodes;
  final List<Genre> genres;
  final List<Season> seasons;

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    posterPath,
    backdropPath,
    firstAirDate,
    voteAverage,
    voteCount,
    numberOfSeasons,
    numberOfEpisodes,
    genres,
    seasons,
  ];
}
