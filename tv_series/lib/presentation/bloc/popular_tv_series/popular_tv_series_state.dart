part of 'popular_tv_series_bloc.dart';

sealed class PopularTvSeriesState extends Equatable {
  const PopularTvSeriesState();

  @override
  List<Object?> get props => [];
}

class PopularTvSeriesEmpty extends PopularTvSeriesState {
  const PopularTvSeriesEmpty();
}

class PopularTvSeriesLoading extends PopularTvSeriesState {
  const PopularTvSeriesLoading();
}

class PopularTvSeriesHasData extends PopularTvSeriesState {
  final List<TvSeries> result;

  const PopularTvSeriesHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class PopularTvSeriesError extends PopularTvSeriesState {
  final String message;

  const PopularTvSeriesError(this.message);

  @override
  List<Object?> get props => [message];
}
