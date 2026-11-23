import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/now_playing_tv_series/now_playing_tv_series_bloc.dart';

import '../../../dummy_data/tv_series_dummy_objects.dart';
import '../../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetNowPlayingTvSeries mockUseCase;
  late NowPlayingTvSeriesBloc bloc;

  setUp(() {
    mockUseCase = MockGetNowPlayingTvSeries();
    bloc = NowPlayingTvSeriesBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const NowPlayingTvSeriesEmpty());
  });

  blocTest<NowPlayingTvSeriesBloc, NowPlayingTvSeriesState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => Right(testTvSeriesList));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchNowPlayingTvSeries()),
    expect: () => [
      const NowPlayingTvSeriesLoading(),
      NowPlayingTvSeriesHasData(<TvSeries>[testTvSeries]),
    ],
    verify: (_) {
      verify(mockUseCase.execute()).called(1);
    },
  );

  blocTest<NowPlayingTvSeriesBloc, NowPlayingTvSeriesState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchNowPlayingTvSeries()),
    expect: () => [
      const NowPlayingTvSeriesLoading(),
      const NowPlayingTvSeriesError('Server Failure'),
    ],
    verify: (_) {
      verify(mockUseCase.execute()).called(1);
    },
  );

  test(
    'a closed bloc is not written to when the use case answers late',
    () async {
      final pending = Completer<Either<Failure, List<TvSeries>>>();
      when(mockUseCase.execute()).thenAnswer((_) => pending.future);

      bloc.add(const FetchNowPlayingTvSeries());
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testTvSeriesList));
      await closing;

      expect(bloc.state, const NowPlayingTvSeriesLoading());
      verify(mockUseCase.execute()).called(1);
    },
  );

  test('an event has no values to compare', () {
    expect(const FetchNowPlayingTvSeries(), const FetchNowPlayingTvSeries());
    expect(const FetchNowPlayingTvSeries().props, isEmpty);
  });

  test('states compare by their values', () {
    expect(
      NowPlayingTvSeriesHasData(testTvSeriesList),
      NowPlayingTvSeriesHasData(testTvSeriesList),
    );
    expect(NowPlayingTvSeriesHasData(testTvSeriesList).props, [
      testTvSeriesList,
    ]);
    expect(
      const NowPlayingTvSeriesError('a'),
      const NowPlayingTvSeriesError('a'),
    );
    expect(const NowPlayingTvSeriesError('a').props, ['a']);
    expect(const NowPlayingTvSeriesEmpty().props, isEmpty);
  });
}
