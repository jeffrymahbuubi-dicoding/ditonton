part of 'movie_detail_bloc.dart';

sealed class MovieDetailState extends Equatable {
  const MovieDetailState();

  @override
  List<Object?> get props => [];
}

class MovieDetailEmpty extends MovieDetailState {
  const MovieDetailEmpty();
}

class MovieDetailLoading extends MovieDetailState {
  const MovieDetailLoading();
}

class MovieDetailHasData extends MovieDetailState {
  final MovieDetail result;

  const MovieDetailHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class MovieDetailError extends MovieDetailState {
  final String message;

  const MovieDetailError(this.message);

  @override
  List<Object?> get props => [message];
}
