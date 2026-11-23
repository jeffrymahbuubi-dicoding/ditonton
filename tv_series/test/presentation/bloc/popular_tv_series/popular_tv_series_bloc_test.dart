import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/popular_tv_series/popular_tv_series_bloc.dart';

import '../../../dummy_data/tv_series_dummy_objects.dart';
import '../../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetPopularTvSeries mockUseCase;
  late PopularTvSeriesBloc bloc;

  setUp(() {
    mockUseCase = MockGetPopularTvSeries();
    bloc = PopularTvSeriesBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const PopularTvSeriesEmpty());
  });

  blocTest<PopularTvSeriesBloc, PopularTvSeriesState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => Right(testTvSeriesList));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchPopularTvSeries()),
    expect: () => [
      const PopularTvSeriesLoading(),
      PopularTvSeriesHasData(<TvSeries>[testTvSeries]),
    ],
    verify: (_) {
      verify(mockUseCase.execute()).called(1);
    },
  );

  blocTest<PopularTvSeriesBloc, PopularTvSeriesState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute())
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchPopularTvSeries()),
    expect: () => [
      const PopularTvSeriesLoading(),
      const PopularTvSeriesError('Server Failure'),
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

      bloc.add(const FetchPopularTvSeries());
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testTvSeriesList));
      await closing;

      expect(bloc.state, const PopularTvSeriesLoading());
      verify(mockUseCase.execute()).called(1);
    },
  );

  test('an event has no values to compare', () {
    expect(const FetchPopularTvSeries(), const FetchPopularTvSeries());
    expect(const FetchPopularTvSeries().props, isEmpty);
  });

  test('states compare by their values', () {
    expect(
      PopularTvSeriesHasData(testTvSeriesList),
      PopularTvSeriesHasData(testTvSeriesList),
    );
    expect(PopularTvSeriesHasData(testTvSeriesList).props, [testTvSeriesList]);
    expect(const PopularTvSeriesError('a'), const PopularTvSeriesError('a'));
    expect(const PopularTvSeriesError('a').props, ['a']);
    expect(const PopularTvSeriesEmpty().props, isEmpty);
  });
}
