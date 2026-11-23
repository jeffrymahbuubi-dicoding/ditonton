import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/presentation/bloc/tv_series_watchlist_status/tv_series_watchlist_status_bloc.dart';

import '../../../dummy_data/tv_series_dummy_objects.dart';
import '../../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetWatchlistTvSeriesStatus mockGetStatus;
  late MockSaveWatchlistTvSeries mockSave;
  late MockRemoveWatchlistTvSeries mockRemove;
  late TvSeriesWatchlistStatusBloc bloc;

  const tId = 1399;
  const tDelay = Duration(milliseconds: 20);

  setUp(() {
    mockGetStatus = MockGetWatchlistTvSeriesStatus();
    mockSave = MockSaveWatchlistTvSeries();
    mockRemove = MockRemoveWatchlistTvSeries();
    bloc = TvSeriesWatchlistStatusBloc(mockGetStatus, mockSave, mockRemove);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be not added without a message', () {
    expect(bloc.state, const TvSeriesWatchlistStatusState());
  });

  test('the success messages are those of the approved notifier', () {
    expect(
      TvSeriesWatchlistStatusBloc.watchlistAddSuccessMessage,
      'Added to Watchlist',
    );
    expect(
      TvSeriesWatchlistStatusBloc.watchlistRemoveSuccessMessage,
      'Removed from Watchlist',
    );
  });

  blocTest<TvSeriesWatchlistStatusBloc, TvSeriesWatchlistStatusState>(
    'emits the added state when the series is in the watchlist',
    build: () {
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadTvSeriesWatchlistStatus(tId)),
    expect: () => [const TvSeriesWatchlistStatusState(isAdded: true)],
    verify: (_) {
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockSave.execute(any));
      verifyNever(mockRemove.execute(any));
    },
  );

  blocTest<TvSeriesWatchlistStatusBloc, TvSeriesWatchlistStatusState>(
    'emits nothing when the series is not in the watchlist',
    build: () {
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => false);
      return bloc;
    },
    act: (bloc) => bloc.add(const LoadTvSeriesWatchlistStatus(tId)),
    expect: () => <TvSeriesWatchlistStatusState>[],
    verify: (_) {
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockSave.execute(any));
      verifyNever(mockRemove.execute(any));
    },
  );

  blocTest<TvSeriesWatchlistStatusBloc, TvSeriesWatchlistStatusState>(
    'emits the added state and the message when saving succeeds',
    build: () {
      when(mockSave.execute(testTvSeriesDetail))
          .thenAnswer((_) async => const Right('Added to Watchlist'));
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);
      return bloc;
    },
    act: (bloc) => bloc.add(const AddTvSeriesToWatchlist(testTvSeriesDetail)),
    expect: () => [
      const TvSeriesWatchlistStatusState(
        isAdded: true,
        message: 'Added to Watchlist',
      ),
    ],
    verify: (_) {
      verify(mockSave.execute(testTvSeriesDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockRemove.execute(any));
    },
  );

  blocTest<TvSeriesWatchlistStatusBloc, TvSeriesWatchlistStatusState>(
    'emits the failure message when saving fails',
    build: () {
      when(mockSave.execute(testTvSeriesDetail)).thenAnswer(
        (_) async => const Left(DatabaseFailure('Failed to add watchlist')),
      );
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => false);
      return bloc;
    },
    act: (bloc) => bloc.add(const AddTvSeriesToWatchlist(testTvSeriesDetail)),
    expect: () => [
      const TvSeriesWatchlistStatusState(message: 'Failed to add watchlist'),
    ],
    verify: (_) {
      verify(mockSave.execute(testTvSeriesDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockRemove.execute(any));
    },
  );

  blocTest<TvSeriesWatchlistStatusBloc, TvSeriesWatchlistStatusState>(
    'clears the old message and emits the removed state when removing succeeds',
    build: () {
      when(mockRemove.execute(testTvSeriesDetail))
          .thenAnswer((_) async => const Right('Removed from Watchlist'));
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => false);
      return bloc;
    },
    seed: () => const TvSeriesWatchlistStatusState(
      isAdded: true,
      message: 'Added to Watchlist',
    ),
    act: (bloc) =>
        bloc.add(const RemoveTvSeriesFromWatchlist(testTvSeriesDetail)),
    expect: () => [
      const TvSeriesWatchlistStatusState(isAdded: true),
      const TvSeriesWatchlistStatusState(message: 'Removed from Watchlist'),
    ],
    verify: (_) {
      verify(mockRemove.execute(testTvSeriesDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockSave.execute(any));
    },
  );

  blocTest<TvSeriesWatchlistStatusBloc, TvSeriesWatchlistStatusState>(
    'emits the failure message and keeps the added state when removing fails',
    build: () {
      when(mockRemove.execute(testTvSeriesDetail)).thenAnswer(
        (_) async => const Left(DatabaseFailure('Failed to remove watchlist')),
      );
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);
      return bloc;
    },
    seed: () => const TvSeriesWatchlistStatusState(isAdded: true),
    act: (bloc) =>
        bloc.add(const RemoveTvSeriesFromWatchlist(testTvSeriesDetail)),
    expect: () => [
      const TvSeriesWatchlistStatusState(
        isAdded: true,
        message: 'Failed to remove watchlist',
      ),
    ],
    verify: (_) {
      verify(mockRemove.execute(testTvSeriesDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockSave.execute(any));
    },
  );

  blocTest<TvSeriesWatchlistStatusBloc, TvSeriesWatchlistStatusState>(
    'ignores a second tap while the first change is still running',
    build: () {
      when(mockSave.execute(testTvSeriesDetail)).thenAnswer((_) async {
        await Future<void>.delayed(tDelay);
        return const Right('Added to Watchlist');
      });
      when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);
      return bloc;
    },
    act: (bloc) {
      bloc
        ..add(const AddTvSeriesToWatchlist(testTvSeriesDetail))
        ..add(const AddTvSeriesToWatchlist(testTvSeriesDetail));
    },
    wait: tDelay * 3,
    expect: () => [
      const TvSeriesWatchlistStatusState(
        isAdded: true,
        message: 'Added to Watchlist',
      ),
    ],
    verify: (_) {
      verify(mockSave.execute(testTvSeriesDetail)).called(1);
      verify(mockGetStatus.execute(tId)).called(1);
      verifyNever(mockRemove.execute(any));
    },
  );

  test('accepts a new change after the previous one has finished', () async {
    when(mockSave.execute(testTvSeriesDetail))
        .thenAnswer((_) async => const Right('Added to Watchlist'));
    when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);

    bloc.add(const AddTvSeriesToWatchlist(testTvSeriesDetail));
    await Future<void>.delayed(tDelay);
    bloc.add(const AddTvSeriesToWatchlist(testTvSeriesDetail));
    await Future<void>.delayed(tDelay);

    verify(mockSave.execute(testTvSeriesDetail)).called(2);
    verify(mockGetStatus.execute(tId)).called(2);
  });

  test('a closed bloc is not written to when the change ends late', () async {
    final pending = Completer<Either<Failure, String>>();
    when(mockSave.execute(testTvSeriesDetail))
        .thenAnswer((_) => pending.future);
    when(mockGetStatus.execute(tId)).thenAnswer((_) async => true);

    bloc.add(const AddTvSeriesToWatchlist(testTvSeriesDetail));
    await Future<void>.delayed(Duration.zero);
    final closing = bloc.close();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    pending.complete(const Right('Added to Watchlist'));
    await closing;

    expect(bloc.state, const TvSeriesWatchlistStatusState());
    verify(mockSave.execute(testTvSeriesDetail)).called(1);
    verify(mockGetStatus.execute(tId)).called(1);
  });

  test('events are equal when their values are equal', () {
    expect(
      const LoadTvSeriesWatchlistStatus(1),
      const LoadTvSeriesWatchlistStatus(1),
    );
    expect(const LoadTvSeriesWatchlistStatus(1).props, [1]);
    expect(
      const AddTvSeriesToWatchlist(testTvSeriesDetail),
      const AddTvSeriesToWatchlist(testTvSeriesDetail),
    );
    expect(const AddTvSeriesToWatchlist(testTvSeriesDetail).props, [
      testTvSeriesDetail,
    ]);
    expect(
      const RemoveTvSeriesFromWatchlist(testTvSeriesDetail),
      const RemoveTvSeriesFromWatchlist(testTvSeriesDetail),
    );
    expect(const RemoveTvSeriesFromWatchlist(testTvSeriesDetail).props, [
      testTvSeriesDetail,
    ]);
  });
}
