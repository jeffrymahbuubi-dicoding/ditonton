import 'package:core/core.dart';
import 'package:tv_series/data/models/season_model.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:equatable/equatable.dart';

class TvSeriesDetailResponse extends Equatable {
  const TvSeriesDetailResponse({
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
  final List<GenreModel> genres;
  final List<SeasonModel> seasons;

  factory TvSeriesDetailResponse.fromJson(Map<String, dynamic> json) =>
      TvSeriesDetailResponse(
        id: json['id'],
        name: json['name'] ?? '',
        overview: json['overview'] ?? '',
        posterPath: json['poster_path'],
        backdropPath: json['backdrop_path'],
        firstAirDate: json['first_air_date'],
        voteAverage: (json['vote_average'] as num?)?.toDouble() ?? 0,
        voteCount: json['vote_count'] ?? 0,
        numberOfSeasons: json['number_of_seasons'] ?? 0,
        numberOfEpisodes: json['number_of_episodes'] ?? 0,
        genres: List<GenreModel>.from(
          (json['genres'] as List? ?? []).map((x) => GenreModel.fromJson(x)),
        ),
        seasons: List<SeasonModel>.from(
          (json['seasons'] as List? ?? []).map((x) => SeasonModel.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'first_air_date': firstAirDate,
    'vote_average': voteAverage,
    'vote_count': voteCount,
    'number_of_seasons': numberOfSeasons,
    'number_of_episodes': numberOfEpisodes,
    'genres': List<dynamic>.from(genres.map((x) => x.toJson())),
    'seasons': List<dynamic>.from(seasons.map((x) => x.toJson())),
  };

  TvSeriesDetail toEntity() => TvSeriesDetail(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    firstAirDate: firstAirDate,
    voteAverage: voteAverage,
    voteCount: voteCount,
    numberOfSeasons: numberOfSeasons,
    numberOfEpisodes: numberOfEpisodes,
    genres: genres.map((genre) => genre.toEntity()).toList(),
    seasons: seasons.map((season) => season.toEntity()).toList(),
  );

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
