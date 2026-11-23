import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/presentation/bloc/watchlist_movies/watchlist_movies_bloc.dart';
import 'package:movie/domain/entities/movie.dart';

import '../../../dummy_data/dummy_objects.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetWatchlistMovies mockUseCase;
  late WatchlistMoviesBloc bloc;

  setUp(() {
    mockUseCase = MockGetWatchlistMovies();
    bloc = WatchlistMoviesBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const WatchlistMoviesEmpty());
  });

  blocTest<WatchlistMoviesBloc, WatchlistMoviesState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute()).thenAnswer((_) async => Right(testMovieList));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchWatchlistMovies()),
    expect: () => [
      const WatchlistMoviesLoading(),
      WatchlistMoviesHasData(<Movie>[testMovie]),
    ],
    verify: (_) {
      verify(mockUseCase.execute()).called(1);
    },
  );

  blocTest<WatchlistMoviesBloc, WatchlistMoviesState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchWatchlistMovies()),
    expect: () => [
      const WatchlistMoviesLoading(),
      const WatchlistMoviesError('Server Failure'),
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

      bloc.add(const FetchWatchlistMovies());
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testMovieList));
      await closing;

      expect(bloc.state, const WatchlistMoviesLoading());
      verify(mockUseCase.execute()).called(1);
    },
  );

  test('an event has no values to compare', () {
    expect(const FetchWatchlistMovies(), const FetchWatchlistMovies());
    expect(const FetchWatchlistMovies().props, isEmpty);
  });
}
