part of 'movie_watchlist_status_bloc.dart';

sealed class MovieWatchlistStatusEvent extends Equatable {
  const MovieWatchlistStatusEvent();

  @override
  List<Object?> get props => [];
}

class LoadMovieWatchlistStatus extends MovieWatchlistStatusEvent {
  final int id;

  const LoadMovieWatchlistStatus(this.id);

  @override
  List<Object?> get props => [id];
}

class AddMovieToWatchlist extends MovieWatchlistStatusEvent {
  final MovieDetail movie;

  const AddMovieToWatchlist(this.movie);

  @override
  List<Object?> get props => [movie];
}

class RemoveMovieFromWatchlist extends MovieWatchlistStatusEvent {
  final MovieDetail movie;

  const RemoveMovieFromWatchlist(this.movie);

  @override
  List<Object?> get props => [movie];
}
