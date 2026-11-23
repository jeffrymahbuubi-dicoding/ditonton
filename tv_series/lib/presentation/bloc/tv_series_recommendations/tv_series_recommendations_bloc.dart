import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/usecases/get_tv_series_recommendations.dart';

part 'tv_series_recommendations_event.dart';
part 'tv_series_recommendations_state.dart';

class TvSeriesRecommendationsBloc
    extends Bloc<TvSeriesRecommendationsEvent, TvSeriesRecommendationsState> {
  final GetTvSeriesRecommendations getTvSeriesRecommendations;

  TvSeriesRecommendationsBloc(this.getTvSeriesRecommendations)
    : super(const TvSeriesRecommendationsEmpty()) {
    on<FetchTvSeriesRecommendations>((event, emit) async {
      emit(const TvSeriesRecommendationsLoading());
      final result = await getTvSeriesRecommendations.execute(event.id);
      result.fold(
        (failure) => emit(TvSeriesRecommendationsError(failure.message)),
        (data) => emit(TvSeriesRecommendationsHasData(data)),
      );
    });
  }
}
