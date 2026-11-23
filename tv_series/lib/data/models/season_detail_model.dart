import 'package:tv_series/data/models/episode_model.dart';
import 'package:tv_series/domain/entities/season_detail.dart';
import 'package:equatable/equatable.dart';

class SeasonDetailResponse extends Equatable {
  const SeasonDetailResponse({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.episodes,
  });

  final int id;
  final int seasonNumber;
  final String name;
  final List<EpisodeModel> episodes;

  factory SeasonDetailResponse.fromJson(Map<String, dynamic> json) =>
      SeasonDetailResponse(
        id: json['id'],
        seasonNumber: json['season_number'],
        name: json['name'] ?? '',
        episodes: List<EpisodeModel>.from(
          (json['episodes'] as List? ?? []).map(
            (x) => EpisodeModel.fromJson(x),
          ),
        ),
      );

  Map<String, dynamic> toJson() => {
    'id': id,
    'season_number': seasonNumber,
    'name': name,
    'episodes': List<dynamic>.from(episodes.map((x) => x.toJson())),
  };

  SeasonDetail toEntity() => SeasonDetail(
    id: id,
    seasonNumber: seasonNumber,
    name: name,
    episodes: episodes.map((episode) => episode.toEntity()).toList(),
  );

  @override
  List<Object> get props => [id, seasonNumber, name, episodes];
}
