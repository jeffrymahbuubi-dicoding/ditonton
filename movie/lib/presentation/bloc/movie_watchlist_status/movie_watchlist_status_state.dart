part of 'movie_watchlist_status_bloc.dart';

class MovieWatchlistStatusState extends Equatable {
  final bool isAdded;
  final String message;

  const MovieWatchlistStatusState({this.isAdded = false, this.message = ''});

  @override
  List<Object?> get props => [isAdded, message];
}
