import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:rxdart/rxdart.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/usecases/search_tv_series.dart';

part 'tv_series_search_event.dart';
part 'tv_series_search_state.dart';

class TvSeriesSearchBloc
    extends Bloc<TvSeriesSearchEvent, TvSeriesSearchState> {
  static const debounceDuration = Duration(milliseconds: 500);

  final SearchTvSeries searchTvSeries;

  TvSeriesSearchBloc(this.searchTvSeries) : super(const TvSeriesSearchEmpty()) {
    on<TvSeriesSearchQueryChanged>((event, emit) async {
      if (event.query.isEmpty) {
        emit(const TvSeriesSearchEmpty());
        return;
      }
      emit(const TvSeriesSearchLoading());
      final result = await searchTvSeries.execute(event.query);
      result.fold(
        (failure) => emit(TvSeriesSearchError(failure.message)),
        (data) => emit(TvSeriesSearchHasData(data)),
      );
    }, transformer: _debounce<TvSeriesSearchQueryChanged>());
  }

  static EventTransformer<E> _debounce<E>() {
    return (events, mapper) =>
        events.debounceTime(debounceDuration).switchMap(mapper);
  }
}
