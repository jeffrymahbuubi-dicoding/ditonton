import 'package:tv_series/domain/entities/episode.dart';
import 'package:equatable/equatable.dart';

class SeasonDetail extends Equatable {
  const SeasonDetail({
    required this.id,
    required this.seasonNumber,
    required this.name,
    required this.episodes,
  });

  final int id;
  final int seasonNumber;
  final String name;
  final List<Episode> episodes;

  @override
  List<Object> get props => [id, seasonNumber, name, episodes];
}
