import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:core/core.dart';
import 'package:movie/domain/entities/movie_detail.dart';
import 'package:movie/domain/usecases/get_watchlist_status.dart';
import 'package:movie/domain/usecases/remove_watchlist.dart';
import 'package:movie/domain/usecases/save_watchlist.dart';

part 'movie_watchlist_status_event.dart';
part 'movie_watchlist_status_state.dart';

class MovieWatchlistStatusBloc
    extends Bloc<MovieWatchlistStatusEvent, MovieWatchlistStatusState> {
  static const watchlistAddSuccessMessage = 'Added to Watchlist';
  static const watchlistRemoveSuccessMessage = 'Removed from Watchlist';

  final GetWatchListStatus getWatchListStatus;
  final SaveWatchlist saveWatchlist;
  final RemoveWatchlist removeWatchlist;

  bool _changing = false;

  MovieWatchlistStatusBloc(
    this.getWatchListStatus,
    this.saveWatchlist,
    this.removeWatchlist,
  ) : super(const MovieWatchlistStatusState()) {
    on<LoadMovieWatchlistStatus>((event, emit) async {
      final isAdded = await getWatchListStatus.execute(event.id);
      final loaded = MovieWatchlistStatusState(isAdded: isAdded);
      if (loaded != state) {
        emit(loaded);
      }
    });
    on<AddMovieToWatchlist>(
      (event, emit) => _change(
        event.movie.id,
        () => saveWatchlist.execute(event.movie),
        emit,
      ),
    );
    on<RemoveMovieFromWatchlist>(
      (event, emit) => _change(
        event.movie.id,
        () => removeWatchlist.execute(event.movie),
        emit,
      ),
    );
  }

  Future<void> _change(
    int id,
    Future<Either<Failure, String>> Function() change,
    Emitter<MovieWatchlistStatusState> emit,
  ) async {
    if (_changing) {
      return;
    }
    _changing = true;
    try {
      if (state.message.isNotEmpty) {
        emit(MovieWatchlistStatusState(isAdded: state.isAdded));
      }
      final result = await change();
      final message = result.fold((failure) => failure.message, (text) => text);
      final isAdded = await getWatchListStatus.execute(id);
      emit(MovieWatchlistStatusState(isAdded: isAdded, message: message));
    } finally {
      _changing = false;
    }
  }
}
