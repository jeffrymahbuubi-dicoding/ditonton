part of 'now_playing_tv_series_bloc.dart';

sealed class NowPlayingTvSeriesState extends Equatable {
  const NowPlayingTvSeriesState();

  @override
  List<Object?> get props => [];
}

class NowPlayingTvSeriesEmpty extends NowPlayingTvSeriesState {
  const NowPlayingTvSeriesEmpty();
}

class NowPlayingTvSeriesLoading extends NowPlayingTvSeriesState {
  const NowPlayingTvSeriesLoading();
}

class NowPlayingTvSeriesHasData extends NowPlayingTvSeriesState {
  final List<TvSeries> result;

  const NowPlayingTvSeriesHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class NowPlayingTvSeriesError extends NowPlayingTvSeriesState {
  final String message;

  const NowPlayingTvSeriesError(this.message);

  @override
  List<Object?> get props => [message];
}
