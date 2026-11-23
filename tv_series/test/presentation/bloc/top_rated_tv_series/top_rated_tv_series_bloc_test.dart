import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/top_rated_tv_series/top_rated_tv_series_bloc.dart';

import '../../../dummy_data/tv_series_dummy_objects.dart';
import '../../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetTopRatedTvSeries mockUseCase;
  late TopRatedTvSeriesBloc bloc;

  setUp(() {
    mockUseCase = MockGetTopRatedTvSeries();
    bloc = TopRatedTvSeriesBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const TopRatedTvSeriesEmpty());
  });

  blocTest<TopRatedTvSeriesBloc, TopRatedTvSeriesState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => Right(testTvSeriesList));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchTopRatedTvSeries()),
    expect: () => [
      const TopRatedTvSeriesLoading(),
      TopRatedTvSeriesHasData(<TvSeries>[testTvSeries]),
    ],
    verify: (_) {
      verify(mockUseCase.execute()).called(1);
    },
  );

  blocTest<TopRatedTvSeriesBloc, TopRatedTvSeriesState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchTopRatedTvSeries()),
    expect: () => [
      const TopRatedTvSeriesLoading(),
      const TopRatedTvSeriesError('Server Failure'),
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

      bloc.add(const FetchTopRatedTvSeries());
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testTvSeriesList));
      await closing;

      expect(bloc.state, const TopRatedTvSeriesLoading());
      verify(mockUseCase.execute()).called(1);
    },
  );

  test('an event has no values to compare', () {
    expect(const FetchTopRatedTvSeries(), const FetchTopRatedTvSeries());
    expect(const FetchTopRatedTvSeries().props, isEmpty);
  });

  test('states compare by their values', () {
    expect(
      TopRatedTvSeriesHasData(testTvSeriesList),
      TopRatedTvSeriesHasData(testTvSeriesList),
    );
    expect(TopRatedTvSeriesHasData(testTvSeriesList).props, [testTvSeriesList]);
    expect(const TopRatedTvSeriesError('a'), const TopRatedTvSeriesError('a'));
    expect(const TopRatedTvSeriesError('a').props, ['a']);
    expect(const TopRatedTvSeriesEmpty().props, isEmpty);
  });
}
