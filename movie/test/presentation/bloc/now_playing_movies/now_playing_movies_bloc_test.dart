import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/presentation/bloc/now_playing_movies/now_playing_movies_bloc.dart';
import 'package:movie/domain/entities/movie.dart';

import '../../../dummy_data/dummy_objects.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetNowPlayingMovies mockUseCase;
  late NowPlayingMoviesBloc bloc;

  setUp(() {
    mockUseCase = MockGetNowPlayingMovies();
    bloc = NowPlayingMoviesBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const NowPlayingMoviesEmpty());
  });

  blocTest<NowPlayingMoviesBloc, NowPlayingMoviesState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute()).thenAnswer((_) async => Right(testMovieList));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchNowPlayingMovies()),
    expect: () => [
      const NowPlayingMoviesLoading(),
      NowPlayingMoviesHasData(<Movie>[testMovie]),
    ],
    verify: (_) {
      verify(mockUseCase.execute()).called(1);
    },
  );

  blocTest<NowPlayingMoviesBloc, NowPlayingMoviesState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchNowPlayingMovies()),
    expect: () => [
      const NowPlayingMoviesLoading(),
      const NowPlayingMoviesError('Server Failure'),
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

      bloc.add(const FetchNowPlayingMovies());
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testMovieList));
      await closing;

      expect(bloc.state, const NowPlayingMoviesLoading());
      verify(mockUseCase.execute()).called(1);
    },
  );

  test('an event has no values to compare', () {
    expect(const FetchNowPlayingMovies(), const FetchNowPlayingMovies());
    expect(const FetchNowPlayingMovies().props, isEmpty);
  });
}
