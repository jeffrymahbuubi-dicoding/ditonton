import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:equatable/equatable.dart';

class TvSeriesModel extends Equatable {
  const TvSeriesModel({
    required this.id,
    required this.name,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.voteAverage,
    required this.voteCount,
    required this.firstAirDate,
    required this.genreIds,
  });

  final int id;
  final String? name;
  final String? overview;
  final String? posterPath;
  final String? backdropPath;
  final double? voteAverage;
  final int? voteCount;
  final String? firstAirDate;
  final List<int>? genreIds;

  factory TvSeriesModel.fromJson(Map<String, dynamic> json) => TvSeriesModel(
    id: json['id'],
    name: json['name'],
    overview: json['overview'],
    posterPath: json['poster_path'],
    backdropPath: json['backdrop_path'],
    voteAverage: (json['vote_average'] as num?)?.toDouble(),
    voteCount: json['vote_count'],
    firstAirDate: json['first_air_date'],
    genreIds: (json['genre_ids'] as List?)?.map((x) => x as int).toList(),
  );

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'overview': overview,
    'poster_path': posterPath,
    'backdrop_path': backdropPath,
    'vote_average': voteAverage,
    'vote_count': voteCount,
    'first_air_date': firstAirDate,
    'genre_ids': genreIds,
  };

  TvSeries toEntity() => TvSeries(
    id: id,
    name: name,
    overview: overview,
    posterPath: posterPath,
    backdropPath: backdropPath,
    voteAverage: voteAverage,
    voteCount: voteCount,
    firstAirDate: firstAirDate,
    genreIds: genreIds,
  );

  @override
  List<Object?> get props => [
    id,
    name,
    overview,
    posterPath,
    backdropPath,
    voteAverage,
    voteCount,
    firstAirDate,
    genreIds,
  ];
}
