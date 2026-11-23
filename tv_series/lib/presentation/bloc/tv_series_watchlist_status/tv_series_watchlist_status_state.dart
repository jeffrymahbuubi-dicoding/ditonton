part of 'tv_series_watchlist_status_bloc.dart';

class TvSeriesWatchlistStatusState extends Equatable {
  final bool isAdded;
  final String message;

  const TvSeriesWatchlistStatusState({this.isAdded = false, this.message = ''});

  @override
  List<Object?> get props => [isAdded, message];
}
