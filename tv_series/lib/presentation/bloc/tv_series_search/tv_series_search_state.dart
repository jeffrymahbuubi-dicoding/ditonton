part of 'tv_series_search_bloc.dart';

sealed class TvSeriesSearchState extends Equatable {
  const TvSeriesSearchState();

  @override
  List<Object?> get props => [];
}

class TvSeriesSearchEmpty extends TvSeriesSearchState {
  const TvSeriesSearchEmpty();
}

class TvSeriesSearchLoading extends TvSeriesSearchState {
  const TvSeriesSearchLoading();
}

class TvSeriesSearchHasData extends TvSeriesSearchState {
  final List<TvSeries> result;

  const TvSeriesSearchHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class TvSeriesSearchError extends TvSeriesSearchState {
  final String message;

  const TvSeriesSearchError(this.message);

  @override
  List<Object?> get props => [message];
}
