import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:tv_series/domain/usecases/get_watchlist_tv_series_status.dart';
import 'package:tv_series/domain/usecases/remove_watchlist_tv_series.dart';
import 'package:tv_series/domain/usecases/save_watchlist_tv_series.dart';

part 'tv_series_watchlist_status_event.dart';
part 'tv_series_watchlist_status_state.dart';

class TvSeriesWatchlistStatusBloc
    extends Bloc<TvSeriesWatchlistStatusEvent, TvSeriesWatchlistStatusState> {
  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetWatchlistTvSeriesStatus getWatchlistTvSeriesStatus;
  final SaveWatchlistTvSeries saveWatchlistTvSeries;
  final RemoveWatchlistTvSeries removeWatchlistTvSeries;

  bool _changing = false;

  TvSeriesWatchlistStatusBloc(
    this.getWatchlistTvSeriesStatus,
    this.saveWatchlistTvSeries,
    this.removeWatchlistTvSeries,
  ) : super(const TvSeriesWatchlistStatusState()) {
    on<LoadTvSeriesWatchlistStatus>((event, emit) async {
      final isAdded = await getWatchlistTvSeriesStatus.execute(event.id);
      final loaded = TvSeriesWatchlistStatusState(isAdded: isAdded);
      if (loaded != state) {
        emit(loaded);
      }
    });
    on<AddTvSeriesToWatchlist>(
      (event, emit) => _change(
        event.tvSeries.id,
        () => saveWatchlistTvSeries.execute(event.tvSeries),
        emit,
      ),
    );
    on<RemoveTvSeriesFromWatchlist>(
      (event, emit) => _change(
        event.tvSeries.id,
        () => removeWatchlistTvSeries.execute(event.tvSeries),
        emit,
      ),
    );
  }

  Future<void> _change(
    int id,
    Future<Either<Failure, String>> Function() change,
    Emitter<TvSeriesWatchlistStatusState> emit,
  ) async {
    if (_changing) {
      return;
    }
    _changing = true;
    try {
      if (state.message.isNotEmpty) {
        emit(TvSeriesWatchlistStatusState(isAdded: state.isAdded));
      }
      final result = await change();
      final message = result.fold((failure) => failure.message, (text) => text);
      final isAdded = await getWatchlistTvSeriesStatus.execute(id);
      emit(TvSeriesWatchlistStatusState(isAdded: isAdded, message: message));
    } finally {
      _changing = false;
    }
  }
}
