import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/domain/usecases/search_movies.dart';
import 'package:rxdart/rxdart.dart';

part 'movie_search_event.dart';
part 'movie_search_state.dart';

class MovieSearchBloc extends Bloc<MovieSearchEvent, MovieSearchState> {
  static const debounceDuration = Duration(milliseconds: 500);

  final SearchMovies searchMovies;

  MovieSearchBloc(this.searchMovies) : super(const MovieSearchEmpty()) {
    on<MovieSearchQueryChanged>((event, emit) async {
      if (event.query.isEmpty) {
        emit(const MovieSearchEmpty());
        return;
      }
      emit(const MovieSearchLoading());
      final result = await searchMovies.execute(event.query);
      result.fold(
        (failure) => emit(MovieSearchError(failure.message)),
        (data) => emit(MovieSearchHasData(data)),
      );
    }, transformer: _debounce<MovieSearchQueryChanged>());
  }

  static EventTransformer<E> _debounce<E>() {
    return (events, mapper) =>
        events.debounceTime(debounceDuration).switchMap(mapper);
  }
}
