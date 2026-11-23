part of 'season_detail_bloc.dart';

sealed class SeasonDetailEvent extends Equatable {
  const SeasonDetailEvent();

  @override
  List<Object?> get props => [];
}

class FetchSeasonDetail extends SeasonDetailEvent {
  final int tvSeriesId;
  final int seasonNumber;

  const FetchSeasonDetail(this.tvSeriesId, this.seasonNumber);

  @override
  List<Object?> get props => [tvSeriesId, seasonNumber];
}
