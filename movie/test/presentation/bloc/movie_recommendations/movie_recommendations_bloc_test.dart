import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/presentation/bloc/movie_recommendations/movie_recommendations_bloc.dart';
import 'package:movie/domain/entities/movie.dart';

import '../../../dummy_data/dummy_objects.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetMovieRecommendations mockUseCase;
  late MovieRecommendationsBloc bloc;

  const tId = 1;

  setUp(() {
    mockUseCase = MockGetMovieRecommendations();
    bloc = MovieRecommendationsBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const MovieRecommendationsEmpty());
  });

  blocTest<MovieRecommendationsBloc, MovieRecommendationsState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute(tId))
          .thenAnswer((_) async => Right(testMovieList));
      return bloc;
    },
    act: (bloc) => bloc.add(FetchMovieRecommendations(tId)),
    expect: () => [
      const MovieRecommendationsLoading(),
      MovieRecommendationsHasData(<Movie>[testMovie]),
    ],
    verify: (_) {
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  blocTest<MovieRecommendationsBloc, MovieRecommendationsState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute(tId))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(FetchMovieRecommendations(tId)),
    expect: () => [
      const MovieRecommendationsLoading(),
      const MovieRecommendationsError('Server Failure'),
    ],
    verify: (_) {
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  test(
    'a closed bloc is not written to when the use case answers late',
    () async {
      final pending = Completer<Either<Failure, List<Movie>>>();
      when(mockUseCase.execute(tId)).thenAnswer((_) => pending.future);

      bloc.add(FetchMovieRecommendations(tId));
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testMovieList));
      await closing;

      expect(bloc.state, const MovieRecommendationsLoading());
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  test('events are equal when their ids are equal', () {
    expect(
      const FetchMovieRecommendations(1),
      const FetchMovieRecommendations(1),
    );
    expect(
      const FetchMovieRecommendations(1),
      isNot(const FetchMovieRecommendations(2)),
    );
    expect(const FetchMovieRecommendations(1).props, [1]);
  });
}
