import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/usecases/get_now_playing_tv_series.dart';

part 'now_playing_tv_series_event.dart';
part 'now_playing_tv_series_state.dart';

class NowPlayingTvSeriesBloc
    extends Bloc<NowPlayingTvSeriesEvent, NowPlayingTvSeriesState> {
  final GetNowPlayingTvSeries getNowPlayingTvSeries;

  NowPlayingTvSeriesBloc(this.getNowPlayingTvSeries)
    : super(const NowPlayingTvSeriesEmpty()) {
    on<FetchNowPlayingTvSeries>((event, emit) async {
      emit(const NowPlayingTvSeriesLoading());
      final result = await getNowPlayingTvSeries.execute();
      result.fold(
        (failure) => emit(NowPlayingTvSeriesError(failure.message)),
        (data) => emit(NowPlayingTvSeriesHasData(data)),
      );
    });
  }
}
