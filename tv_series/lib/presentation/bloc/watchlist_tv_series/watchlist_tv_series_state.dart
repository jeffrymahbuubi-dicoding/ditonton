part of 'watchlist_tv_series_bloc.dart';

sealed class WatchlistTvSeriesState extends Equatable {
  const WatchlistTvSeriesState();

  @override
  List<Object?> get props => [];
}

class WatchlistTvSeriesEmpty extends WatchlistTvSeriesState {
  const WatchlistTvSeriesEmpty();
}

class WatchlistTvSeriesLoading extends WatchlistTvSeriesState {
  const WatchlistTvSeriesLoading();
}

class WatchlistTvSeriesHasData extends WatchlistTvSeriesState {
  final List<TvSeries> result;

  const WatchlistTvSeriesHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class WatchlistTvSeriesError extends WatchlistTvSeriesState {
  final String message;

  const WatchlistTvSeriesError(this.message);

  @override
  List<Object?> get props => [message];
}
