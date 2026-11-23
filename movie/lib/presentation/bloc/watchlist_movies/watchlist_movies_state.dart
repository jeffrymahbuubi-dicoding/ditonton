part of 'watchlist_movies_bloc.dart';

sealed class WatchlistMoviesState extends Equatable {
  const WatchlistMoviesState();

  @override
  List<Object?> get props => [];
}

class WatchlistMoviesEmpty extends WatchlistMoviesState {
  const WatchlistMoviesEmpty();
}

class WatchlistMoviesLoading extends WatchlistMoviesState {
  const WatchlistMoviesLoading();
}

class WatchlistMoviesHasData extends WatchlistMoviesState {
  final List<Movie> result;

  const WatchlistMoviesHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class WatchlistMoviesError extends WatchlistMoviesState {
  final String message;

  const WatchlistMoviesError(this.message);

  @override
  List<Object?> get props => [message];
}
