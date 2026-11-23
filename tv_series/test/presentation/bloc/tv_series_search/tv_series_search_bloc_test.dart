import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/tv_series_search/tv_series_search_bloc.dart';

import '../../../dummy_data/tv_series_dummy_objects.dart';
import '../../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockSearchTvSeries mockSearchTvSeries;
  late TvSeriesSearchBloc bloc;

  const tQuery = 'game';
  const tSettle = Duration(milliseconds: 100);
  final tWait = TvSeriesSearchBloc.debounceDuration + tSettle;

  setUp(() {
    mockSearchTvSeries = MockSearchTvSeries();
    bloc = TvSeriesSearchBloc(mockSearchTvSeries);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('debounce is 500 milliseconds', () {
    expect(
      TvSeriesSearchBloc.debounceDuration,
      const Duration(milliseconds: 500),
    );
  });

  test('initial state should be empty', () {
    expect(bloc.state, const TvSeriesSearchEmpty());
  });

  blocTest<TvSeriesSearchBloc, TvSeriesSearchState>(
    'emits loading then data when the search succeeds',
    build: () {
      when(mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => Right(testTvSeriesList));
      return bloc;
    },
    act: (bloc) => bloc.add(const TvSeriesSearchQueryChanged(tQuery)),
    wait: tWait,
    expect: () => [
      const TvSeriesSearchLoading(),
      TvSeriesSearchHasData(<TvSeries>[testTvSeries]),
    ],
    verify: (_) {
      verify(mockSearchTvSeries.execute(tQuery)).called(1);
    },
  );

  blocTest<TvSeriesSearchBloc, TvSeriesSearchState>(
    'emits loading then error when the search fails',
    build: () {
      when(mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const TvSeriesSearchQueryChanged(tQuery)),
    wait: tWait,
    expect: () => [
      const TvSeriesSearchLoading(),
      const TvSeriesSearchError('Server Failure'),
    ],
    verify: (_) {
      verify(mockSearchTvSeries.execute(tQuery)).called(1);
    },
  );

  test('does not search before the debounce time has passed', () async {
    when(mockSearchTvSeries.execute(tQuery))
        .thenAnswer((_) async => Right(testTvSeriesList));

    bloc.add(const TvSeriesSearchQueryChanged(tQuery));
    await Future<void>.delayed(const Duration(milliseconds: 200));

    expect(bloc.state, const TvSeriesSearchEmpty());
    verifyNever(mockSearchTvSeries.execute(any));
  });

  blocTest<TvSeriesSearchBloc, TvSeriesSearchState>(
    'searches only for the last query typed within the debounce time',
    build: () {
      when(mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => Right(testTvSeriesList));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const TvSeriesSearchQueryChanged('ga'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
      bloc.add(const TvSeriesSearchQueryChanged(tQuery));
    },
    wait: tWait,
    expect: () => [
      const TvSeriesSearchLoading(),
      TvSeriesSearchHasData(<TvSeries>[testTvSeries]),
    ],
    verify: (_) {
      verify(mockSearchTvSeries.execute(tQuery)).called(1);
      verifyNever(mockSearchTvSeries.execute('ga'));
    },
  );

  blocTest<TvSeriesSearchBloc, TvSeriesSearchState>(
    'drops the answer of an older query when a newer one arrives',
    build: () {
      when(mockSearchTvSeries.execute('ga')).thenAnswer((_) async {
        await Future<void>.delayed(const Duration(milliseconds: 800));
        return const Right(<TvSeries>[]);
      });
      when(mockSearchTvSeries.execute(tQuery))
          .thenAnswer((_) async => Right(testTvSeriesList));
      return bloc;
    },
    act: (bloc) async {
      bloc.add(const TvSeriesSearchQueryChanged('ga'));
      await Future<void>.delayed(
        TvSeriesSearchBloc.debounceDuration + const Duration(milliseconds: 50),
      );
      bloc.add(const TvSeriesSearchQueryChanged(tQuery));
    },
    wait: const Duration(milliseconds: 1500),
    expect: () => [
      const TvSeriesSearchLoading(),
      TvSeriesSearchHasData(<TvSeries>[testTvSeries]),
    ],
    verify: (_) {
      verify(mockSearchTvSeries.execute('ga')).called(1);
      verify(mockSearchTvSeries.execute(tQuery)).called(1);
    },
  );

  blocTest<TvSeriesSearchBloc, TvSeriesSearchState>(
    'emits empty without a request when the query is cleared',
    build: () => bloc,
    seed: () => TvSeriesSearchHasData(<TvSeries>[testTvSeries]),
    act: (bloc) => bloc.add(const TvSeriesSearchQueryChanged('')),
    wait: tWait,
    expect: () => [const TvSeriesSearchEmpty()],
    verify: (_) {
      verifyNever(mockSearchTvSeries.execute(any));
    },
  );

  test('a closed bloc is not written to when the answer comes late', () async {
    final pending = Completer<Either<Failure, List<TvSeries>>>();
    when(mockSearchTvSeries.execute(tQuery)).thenAnswer((_) => pending.future);

    bloc.add(const TvSeriesSearchQueryChanged(tQuery));
    await Future<void>.delayed(tWait);
    final closing = bloc.close();
    await Future<void>.delayed(const Duration(milliseconds: 10));
    pending.complete(Right(testTvSeriesList));
    await closing;

    expect(bloc.state, const TvSeriesSearchLoading());
    verify(mockSearchTvSeries.execute(tQuery)).called(1);
  });

  test('events and states compare by their values', () {
    expect(
      const TvSeriesSearchQueryChanged('a'),
      const TvSeriesSearchQueryChanged('a'),
    );
    expect(
      const TvSeriesSearchQueryChanged('a'),
      isNot(const TvSeriesSearchQueryChanged('b')),
    );
    expect(const TvSeriesSearchQueryChanged('a').props, ['a']);
    expect(const TvSeriesSearchError('a'), const TvSeriesSearchError('a'));
    expect(const TvSeriesSearchError('a').props, ['a']);
    expect(const TvSeriesSearchEmpty().props, isEmpty);
    expect(TvSeriesSearchHasData(testTvSeriesList).props, [testTvSeriesList]);
  });
}
