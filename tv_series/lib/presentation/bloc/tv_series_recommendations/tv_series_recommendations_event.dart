part of 'tv_series_recommendations_bloc.dart';

sealed class TvSeriesRecommendationsEvent extends Equatable {
  const TvSeriesRecommendationsEvent();

  @override
  List<Object?> get props => [];
}

class FetchTvSeriesRecommendations extends TvSeriesRecommendationsEvent {
  final int id;

  const FetchTvSeriesRecommendations(this.id);

  @override
  List<Object?> get props => [id];
}
