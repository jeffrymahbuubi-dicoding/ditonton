import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/tv_series_recommendations/tv_series_recommendations_bloc.dart';

import '../../../dummy_data/tv_series_dummy_objects.dart';
import '../../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetTvSeriesRecommendations mockUseCase;
  late TvSeriesRecommendationsBloc bloc;

  const tId = 1399;

  setUp(() {
    mockUseCase = MockGetTvSeriesRecommendations();
    bloc = TvSeriesRecommendationsBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const TvSeriesRecommendationsEmpty());
  });

  blocTest<TvSeriesRecommendationsBloc, TvSeriesRecommendationsState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute(tId))
          .thenAnswer((_) async => Right(testTvSeriesList));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchTvSeriesRecommendations(tId)),
    expect: () => [
      const TvSeriesRecommendationsLoading(),
      TvSeriesRecommendationsHasData(<TvSeries>[testTvSeries]),
    ],
    verify: (_) {
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  blocTest<TvSeriesRecommendationsBloc, TvSeriesRecommendationsState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute(tId))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchTvSeriesRecommendations(tId)),
    expect: () => [
      const TvSeriesRecommendationsLoading(),
      const TvSeriesRecommendationsError('Server Failure'),
    ],
    verify: (_) {
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  test(
    'a closed bloc is not written to when the use case answers late',
    () async {
      final pending = Completer<Either<Failure, List<TvSeries>>>();
      when(mockUseCase.execute(tId)).thenAnswer((_) => pending.future);

      bloc.add(const FetchTvSeriesRecommendations(tId));
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testTvSeriesList));
      await closing;

      expect(bloc.state, const TvSeriesRecommendationsLoading());
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  test('events and states compare by their values', () {
    expect(
      const FetchTvSeriesRecommendations(1),
      const FetchTvSeriesRecommendations(1),
    );
    expect(
      const FetchTvSeriesRecommendations(1),
      isNot(const FetchTvSeriesRecommendations(2)),
    );
    expect(const FetchTvSeriesRecommendations(1).props, [1]);
    expect(
      const TvSeriesRecommendationsError('a'),
      const TvSeriesRecommendationsError('a'),
    );
    expect(const TvSeriesRecommendationsError('a').props, ['a']);
    expect(const TvSeriesRecommendationsEmpty().props, isEmpty);
  });
}
