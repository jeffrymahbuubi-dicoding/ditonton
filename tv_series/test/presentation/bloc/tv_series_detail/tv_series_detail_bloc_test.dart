import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:tv_series/presentation/bloc/tv_series_detail/tv_series_detail_bloc.dart';

import '../../../dummy_data/tv_series_dummy_objects.dart';
import '../../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetTvSeriesDetail mockUseCase;
  late TvSeriesDetailBloc bloc;

  const tId = 1399;

  setUp(() {
    mockUseCase = MockGetTvSeriesDetail();
    bloc = TvSeriesDetailBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const TvSeriesDetailEmpty());
  });

  blocTest<TvSeriesDetailBloc, TvSeriesDetailState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute(tId))
          .thenAnswer((_) async => Right(testTvSeriesDetail));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchTvSeriesDetail(tId)),
    expect: () => [
      const TvSeriesDetailLoading(),
      TvSeriesDetailHasData(
        TvSeriesDetail(
          id: 1399,
          name: 'Game of Thrones',
          overview: 'Seven noble families fight for control of the mythical land of Westeros.',
          posterPath: '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
          backdropPath: '/2OMB0ynKlyIenMJWI2Dy9IWT4c.jpg',
          firstAirDate: '2011-04-17',
          voteAverage: 8.4,
          voteCount: 25000,
          numberOfSeasons: 8,
          numberOfEpisodes: 73,
          genres: [Genre(id: 18, name: 'Drama')],
          seasons: [testSeason],
        ),
      ),
    ],
    verify: (_) {
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  blocTest<TvSeriesDetailBloc, TvSeriesDetailState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute(tId))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(const FetchTvSeriesDetail(tId)),
    expect: () => [
      const TvSeriesDetailLoading(),
      const TvSeriesDetailError('Server Failure'),
    ],
    verify: (_) {
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  test(
    'a closed bloc is not written to when the use case answers late',
    () async {
      final pending = Completer<Either<Failure, TvSeriesDetail>>();
      when(mockUseCase.execute(tId)).thenAnswer((_) => pending.future);

      bloc.add(const FetchTvSeriesDetail(tId));
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testTvSeriesDetail));
      await closing;

      expect(bloc.state, const TvSeriesDetailLoading());
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  test('events and states compare by their values', () {
    expect(const FetchTvSeriesDetail(1), const FetchTvSeriesDetail(1));
    expect(const FetchTvSeriesDetail(1), isNot(const FetchTvSeriesDetail(2)));
    expect(const FetchTvSeriesDetail(1).props, [1]);
    expect(const TvSeriesDetailError('a'), const TvSeriesDetailError('a'));
    expect(const TvSeriesDetailError('a').props, ['a']);
    expect(const TvSeriesDetailEmpty().props, isEmpty);
  });
}
