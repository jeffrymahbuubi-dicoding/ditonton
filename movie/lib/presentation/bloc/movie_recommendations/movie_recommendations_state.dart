part of 'movie_recommendations_bloc.dart';

sealed class MovieRecommendationsState extends Equatable {
  const MovieRecommendationsState();

  @override
  List<Object?> get props => [];
}

class MovieRecommendationsEmpty extends MovieRecommendationsState {
  const MovieRecommendationsEmpty();
}

class MovieRecommendationsLoading extends MovieRecommendationsState {
  const MovieRecommendationsLoading();
}

class MovieRecommendationsHasData extends MovieRecommendationsState {
  final List<Movie> result;

  const MovieRecommendationsHasData(this.result);

  @override
  List<Object?> get props => [result];
}

class MovieRecommendationsError extends MovieRecommendationsState {
  final String message;

  const MovieRecommendationsError(this.message);

  @override
  List<Object?> get props => [message];
}
