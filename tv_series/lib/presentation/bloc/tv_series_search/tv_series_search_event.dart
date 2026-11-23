part of 'tv_series_search_bloc.dart';

sealed class TvSeriesSearchEvent extends Equatable {
  const TvSeriesSearchEvent();

  @override
  List<Object?> get props => [];
}

class TvSeriesSearchQueryChanged extends TvSeriesSearchEvent {
  final String query;

  const TvSeriesSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
