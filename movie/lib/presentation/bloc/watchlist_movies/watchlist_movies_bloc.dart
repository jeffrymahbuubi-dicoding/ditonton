import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/domain/usecases/get_watchlist_movies.dart';

part 'watchlist_movies_event.dart';
part 'watchlist_movies_state.dart';

class WatchlistMoviesBloc
    extends Bloc<WatchlistMoviesEvent, WatchlistMoviesState> {
  final GetWatchlistMovies getWatchlistMovies;

  WatchlistMoviesBloc(this.getWatchlistMovies)
    : super(const WatchlistMoviesEmpty()) {
    on<FetchWatchlistMovies>((event, emit) async {
      emit(const WatchlistMoviesLoading());
      final result = await getWatchlistMovies.execute();
      result.fold(
        (failure) => emit(WatchlistMoviesError(failure.message)),
        (data) => emit(WatchlistMoviesHasData(data)),
      );
    });
  }
}
