part of 'tv_series_detail_bloc.dart';

sealed class TvSeriesDetailState extends Equatable {
  const TvSeriesDetailState();

  @override
  List<Object?> get props => [];
}

class TvSeriesDetailEmpty extends TvSeriesDetailState {
  const TvSeriesDetailEmpty();
}

class TvSeriesDetailLoading extends TvSeriesDetailState {
  const TvSeriesDetailLoading();
}

class TvSeriesDetailHasData extends TvSeriesDetailState {
  final TvSeriesDetail result;

  const TvSeriesDetailHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class TvSeriesDetailError extends TvSeriesDetailState {
  final String message;

  const TvSeriesDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
