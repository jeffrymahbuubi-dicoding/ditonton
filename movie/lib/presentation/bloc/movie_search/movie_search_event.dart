part of 'movie_search_bloc.dart';

sealed class MovieSearchEvent extends Equatable {
  const MovieSearchEvent();

  @override
  List<Object?> get props => [];
}

class MovieSearchQueryChanged extends MovieSearchEvent {
  final String query;

  const MovieSearchQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}
