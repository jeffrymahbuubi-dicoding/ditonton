part of 'tv_series_recommendations_bloc.dart';

sealed class TvSeriesRecommendationsState extends Equatable {
  const TvSeriesRecommendationsState();

  @override
  List<Object?> get props => [];
}

class TvSeriesRecommendationsEmpty extends TvSeriesRecommendationsState {
  const TvSeriesRecommendationsEmpty();
}

class TvSeriesRecommendationsLoading extends TvSeriesRecommendationsState {
  const TvSeriesRecommendationsLoading();
}

class TvSeriesRecommendationsHasData extends TvSeriesRecommendationsState {
  final List<TvSeries> result;

  const TvSeriesRecommendationsHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class TvSeriesRecommendationsError extends TvSeriesRecommendationsState {
  final String message;

  const TvSeriesRecommendationsError(this.message);

  @override
  List<Object?> get props => [message];
}
