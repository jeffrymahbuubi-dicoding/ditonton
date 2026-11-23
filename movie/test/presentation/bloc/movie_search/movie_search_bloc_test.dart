import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/presentation/bloc/movie_search/movie_search_bloc.dart';

import '../../../dummy_data/dummy_objects.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockSearchMovies mockSearchMovies;
  late MovieSearchBloc bloc;

  const tQuery = 'spiderman';
  const tSettle = Duration(milliseconds: 100);
  final tWait = MovieSearchBloc.debounceDuration + tSettle;

  setUp(() {
    mockSearchMovies = MockSearchMovies();
    bloc = MovieSearchBloc(mockSearchMovies);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('debounce is 500 milliseconds', () {
    expect(MovieSearchBloc.debounceDuration, const Duration(milliseconds: 500));
  });

  test('initial state should be empty', () {
    expect(bloc.state, const MovieSearchEmpty());
  });

  blocTest<MovieSearchBloc, MovieSearchState>(
    'emits loading then data when the search succeeds',
    build: () {
      when(mockSearchMovies.execute(tQuery))
          .thenAnswer((_) async => Right(testMovieList));
      return bloc;
    },
    act: (bloc) => bloc.add(const MovieSearchQueryChanged(tQuery)),
    wait: tWait,
    expect: () => [
      const MovieSearchLoading(),
      MovieSearchHasData(<Movie>[testMovie]),
    ],
    verify: (_) {
      verify(mockSearchMovies.execute(tQuery)).called(1);
    },
  );

  blocTest<MovieSearchBloc, MovieSearchState>(
    'emits loading then error when the search fails',
    build: () {
      when(mockSearchMovies.execute(tQuery))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const MovieSearchQueryChanged(tQuery)),
    wait: tWait,
    expect: () => [
      const MovieSearchLoading(),
      const MovieSearchError('Server Failure'),
    ],
    verify: (_) {
      verify(mockSearchMovies.execute(tQuery)).called(1);
    },
  );

  test('does not search before the debounce time has passed', () async {
    when(mockSearchMovies.execute(tQuery))
        .thenAnswer((_) async => Right(testMovieList));

    bloc.add(const MovieSearchQueryChanged(tQuery));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(bloc.state, const MovieSearchEmpty());
    verifyNever(mockSearchMovies.execute(any));
  });

  blocTest<MovieSearchBloc, MovieSearchState>(
    'searches only for the last query typed within the debounce time',
    build: () {
      when(mockSearchMovies.execute(tQuery))
          .thenAnswer((_) async => Right(testMovieList));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const MovieSearchQueryChanged('spi'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      bloc.add(const MovieSearchQueryChanged(tQuery));
    },
    wait: tWait,
    expect: () => [
      const MovieSearchLoading(),
      MovieSearchHasData(<Movie>[testMovie]),
    ],
    verify: (_) {
      verify(mockSearchMovies.execute(tQuery)).called(1);
      verifyNever(mockSearchMovies.execute('spi'));
    },
  );

  blocTest<MovieSearchBloc, MovieSearchState>(
    'drops the answer of an older query when a newer one arrives',
    build: () {
      when(mockSearchMovies.execute('spi')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        return const Right(<Movie>[]);
      });
      when(mockSearchMovies.execute(tQuery))
          .thenAnswer((_) async => Right(testMovieList));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const MovieSearchQueryChanged('spi'));
      await Future<void>.delayed(
        MovieSearchBloc.debounceDuration + const Duration(milliseconds: 50),
      );
      bloc.add(const MovieSearchQueryChanged(tQuery));
    },
    wait: const Duration(milliseconds: 1500),
    expect: () => [
      const MovieSearchLoading(),
      MovieSearchHasData(<Movie>[testMovie]),
    ],
    verify: (_) {
      verify(mockSearchMovies.execute('spi')).called(1);
      verify(mockSearchMovies.execute(tQuery)).called(1);
    },
  );

  blocTest<MovieSearchBloc, MovieSearchState>(
    'emits empty without a request when the query is cleared',
    build: () => bloc,
    seed: () => MovieSearchHasData(<Movie>[testMovie]),
    act: (bloc) => bloc.add(const MovieSearchQueryChanged('')),
    wait: tWait,
    expect: () => [const MovieSearchEmpty()],
    verify: (_) {
      verifyNever(mockSearchMovies.execute(any));
    },
  );

  test('a closed bloc is not written to when the answer comes late', () async {
    final pending = Completer<Either<Failure, List<Movie>>>();
    when(mockSearchMovies.execute(tQuery)).thenAnswer((_) => pending.future);

    bloc.add(const MovieSearchQueryChanged(tQuery));
    await Future<void>.delayed(tWait);
    final closing = bloc.close();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    pending.complete(Right(testMovieList));
    await closing;

    expect(bloc.state, const MovieSearchLoading());
    verify(mockSearchMovies.execute(tQuery)).called(1);
  });

  test('events are equal when their queries are equal', () {
    expect(
      const MovieSearchQueryChanged('a'),
      const MovieSearchQueryChanged('a'),
    );
    expect(
      const MovieSearchQueryChanged('a'),
      isNot(const MovieSearchQueryChanged('b')),
    );
    expect(const MovieSearchQueryChanged('a').props, ['a']);
  });
}
