import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/presentation/bloc/top_rated_movies/top_rated_movies_bloc.dart';
import 'package:movie/domain/entities/movie.dart';

import '../../../dummy_data/dummy_objects.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetTopRatedMovies mockUseCase;
  late TopRatedMoviesBloc bloc;

  setUp(() {
    mockUseCase = MockGetTopRatedMovies();
    bloc = TopRatedMoviesBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const TopRatedMoviesEmpty());
  });

  blocTest<TopRatedMoviesBloc, TopRatedMoviesState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute()).thenAnswer((_) async => Right(testMovieList));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchTopRatedMovies()),
    expect: () => [
      const TopRatedMoviesLoading(),
      TopRatedMoviesHasData(<Movie>[testMovie]),
    ],
    verify: (_) {
      verify(mockUseCase.execute()).called(1);
    },
  );

  blocTest<TopRatedMoviesBloc, TopRatedMoviesState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchTopRatedMovies()),
    expect: () => [
      const TopRatedMoviesLoading(),
      const TopRatedMoviesError('Server Failure'),
    ],
    verify: (_) {
      verify(mockUseCase.execute()).called(1);
    },
  );

  test(
    'a closed bloc is not written to when the use case answers late',
    () async {
      final pending = Completer<Either<Failure, List<Movie>>>();
      when(mockUseCase.execute()).thenAnswer((_) => pending.future);

      bloc.add(const FetchTopRatedMovies());
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testMovieList));
      await closing;

      expect(bloc.state, const TopRatedMoviesLoading());
      verify(mockUseCase.execute()).called(1);
    },
  );

  test('an event has no values to compare', () {
    expect(const FetchTopRatedMovies(), const FetchTopRatedMovies());
    expect(const FetchTopRatedMovies().props, isEmpty);
  });
}
