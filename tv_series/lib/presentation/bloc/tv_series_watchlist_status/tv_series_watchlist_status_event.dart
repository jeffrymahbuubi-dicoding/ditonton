part of 'tv_series_watchlist_status_bloc.dart';

sealed class TvSeriesWatchlistStatusEvent extends Equatable {
  const TvSeriesWatchlistStatusEvent();

  @override
  List<Object?> get props => [];
}

class LoadTvSeriesWatchlistStatus extends TvSeriesWatchlistStatusEvent {
  final int id;

  const LoadTvSeriesWatchlistStatus(this.id);

  @override
  List<Object?> get props => [id];
}

class AddTvSeriesToWatchlist extends TvSeriesWatchlistStatusEvent {
  final TvSeriesDetail tvSeries;

  const AddTvSeriesToWatchlist(this.tvSeries);

  @override
  List<Object?> get props => [tvSeries];
}

class RemoveTvSeriesFromWatchlist extends TvSeriesWatchlistStatusEvent {
  final TvSeriesDetail tvSeries;

  const RemoveTvSeriesFromWatchlist(this.tvSeries);

  @override
  List<Object?> get props => [tvSeries];
}
