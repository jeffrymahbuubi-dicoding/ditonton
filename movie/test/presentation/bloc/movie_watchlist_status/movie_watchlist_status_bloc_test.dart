import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/presentation/bloc/movie_watchlist_status/movie_watchlist_status_bloc.dart';

import '../../../dummy_data/dummy_objects.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetWatchListStatus mockGetStatus;
  late MockSaveWatchlist mockSave;
  late MockRemoveWatchlist mockRemove;
  late MovieWatchlistStatusBloc bloc;

  const tId = 1;
  const tDelay = Duration(milliseconds: 20);

  setUp(() {
    mockGetStatus = MockGetWatchListStatus();
    mockSave = MockSaveWatchlist();
    mockRemove = MockRemoveWatchlist();
    bloc = MovieWatchlistStatusBloc(mockGetStatus, mockSave, mockRemove);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be not added without a message', () {
    expect(bloc.state, const MovieWatchlistStatusState());
  });

  blocTest<MovieWatchlistStatusBloc, MovieWatchlistStatusState>(
    'emits the added state when the movie is in the watchlist',
    build: () {
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadMovieWatchlistStatus(tId)),
    expect: () => [const MovieWatchlistStatusState(isAdded: true)],
    verify: (_) {
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockSave.execute(any));
      verifyNever(mockRemove.execute(any));
    },
  );

  blocTest<MovieWatchlistStatusBloc, MovieWatchlistStatusState>(
    'emits nothing when the movie is not in the watchlist',
    build: () {
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => false);
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadMovieWatchlistStatus(tId)),
    expect: () => <MovieWatchlistStatusState>[],
    verify: (_) {
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockSave.execute(any));
      verifyNever(mockRemove.execute(any));
    },
  );

  blocTest<MovieWatchlistStatusBloc, MovieWatchlistStatusState>(
    'emits the added state and the message when saving succeeds',
    build: () {
      when(mockSave.execute(testMovieDetail))
          .thenAnswer((_) async => const Right('Added to Watchlist'));
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);
      return bloc;
    },
    act: (bloc) => bloc.add(AddMovieToWatchlist(testMovieDetail)),
    expect: () => [
      const MovieWatchlistStatusState(
        isAdded: true,
        message: 'Added to Watchlist',
      ),
    ],
    verify: (_) {
      verify(mockSave.execute(testMovieDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockRemove.execute(any));
    },
  );

  blocTest<MovieWatchlistStatusBloc, MovieWatchlistStatusState>(
    'emits the failure message when saving fails',
    build: () {
      when(mockSave.execute(testMovieDetail)).thenAnswer(
        (_) async => const Left(DatabaseFailure('Failed to add watchlist')),
      );
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => false);
      return bloc;
    },
    act: (bloc) => bloc.add(AddMovieToWatchlist(testMovieDetail)),
    expect: () => [
      const MovieWatchlistStatusState(message: 'Failed to add watchlist'),
    ],
    verify: (_) {
      verify(mockSave.execute(testMovieDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockRemove.execute(any));
    },
  );

  blocTest<MovieWatchlistStatusBloc, MovieWatchlistStatusState>(
    'clears the old message and emits the removed state when removing succeeds',
    build: () {
      when(mockRemove.execute(testMovieDetail))
          .thenAnswer((_) async => const Right('Removed from Watchlist'));
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => false);
      return bloc;
    },
    seed: () => const MovieWatchlistStatusState(
      isAdded: true,
      message: 'Added to Watchlist',
    ),
    act: (bloc) => bloc.add(RemoveMovieFromWatchlist(testMovieDetail)),
    expect: () => [
      const MovieWatchlistStatusState(isAdded: true),
      const MovieWatchlistStatusState(message: 'Removed from Watchlist'),
    ],
    verify: (_) {
      verify(mockRemove.execute(testMovieDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockSave.execute(any));
    },
  );

  blocTest<MovieWatchlistStatusBloc, MovieWatchlistStatusState>(
    'emits the failure message and keeps the added state when removing fails',
    build: () {
      when(mockRemove.execute(testMovieDetail)).thenAnswer(
        (_) async => const Left(DatabaseFailure('Failed to remove watchlist')),
      );
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);
      return bloc;
    },
    seed: () => const MovieWatchlistStatusState(isAdded: true),
    act: (bloc) => bloc.add(RemoveMovieFromWatchlist(testMovieDetail)),
    expect: () => [
      const MovieWatchlistStatusState(
        isAdded: true,
        message: 'Failed to remove watchlist',
      ),
    ],
    verify: (_) {
      verify(mockRemove.execute(testMovieDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockSave.execute(any));
    },
  );

  blocTest<MovieWatchlistStatusBloc, MovieWatchlistStatusState>(
    'ignores a second tap while the first change is still running',
    build: () {
      when(mockSave.execute(testMovieDetail)).thenAnswer((_) async {
        await Future<void>.delayed(tDelay);
        return const Right('Added to Watchlist');
      });
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);
      return bloc;
    },
    act: (bloc) {
      bloc
        ..add(AddMovieToWatchlist(testMovieDetail))
        ..add(AddMovieToWatchlist(testMovieDetail));
    },
    wait: tDelay * 3,
    expect: () => [
      const MovieWatchlistStatusState(
        isAdded: true,
        message: 'Added to Watchlist',
      ),
    ],
    verify: (_) {
      verify(mockSave.execute(testMovieDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockRemove.execute(any));
    },
  );

  test('accepts a new change after the previous one has finished', () async {
    when(mockSave.execute(testMovieDetail))
        .thenAnswer((_) async => const Right('Added to Watchlist'));
    when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);

    bloc.add(AddMovieToWatchlist(testMovieDetail));
    await Future<void>.delayed(tDelay);
    bloc.add(AddMovieToWatchlist(testMovieDetail));
    await Future<void>.delayed(tDelay);

    verify(mockSave.execute(testMovieDetail)).called(2);
    verify(mockGetStatus.execute(tId)).called(2);
  });

  test('a closed bloc is not written to when the change ends late', () async {
    final pending = Completer<Either<Failure, String>>();
    when(mockSave.execute(testMovieDetail)).thenAnswer((_) => pending.future);
    when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);

    bloc.add(AddMovieToWatchlist(testMovieDetail));
    await Future<void>.delayed(Duration.zero);
    final closing = bloc.close();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    pending.complete(const Right('Added to Watchlist'));
    await closing;

    expect(bloc.state, const MovieWatchlistStatusState());
    verify(mockSave.execute(testMovieDetail)).called(1);
    verify(mockGetStatus.execute(tId)).called(1);
  });

  test('events are equal when their values are equal', () {
    expect(
      const LoadMovieWatchlistStatus(1),
      const LoadMovieWatchlistStatus(1),
    );
    expect(const LoadMovieWatchlistStatus(1).props, [1]);
    expect(
      AddMovieToWatchlist(testMovieDetail),
      AddMovieToWatchlist(testMovieDetail),
    );
    expect(AddMovieToWatchlist(testMovieDetail).props, [testMovieDetail]);
    expect(
      RemoveMovieFromWatchlist(testMovieDetail),
      RemoveMovieFromWatchlist(testMovieDetail),
    );
    expect(RemoveMovieFromWatchlist(testMovieDetail).props, [testMovieDetail]);
  });
}
