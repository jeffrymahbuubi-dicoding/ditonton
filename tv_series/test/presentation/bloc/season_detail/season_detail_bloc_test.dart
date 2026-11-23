import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/episode.dart';
import 'package:tv_series/domain/entities/season_detail.dart';
import 'package:tv_series/presentation/bloc/season_detail/season_detail_bloc.dart';

import '../../../dummy_data/tv_series_dummy_objects.dart';
import '../../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetSeasonDetail mockGetSeasonDetail;
  late SeasonDetailBloc bloc;

  const tTvSeriesId = 1399;
  const tSeasonNumber = 1;

  setUp(() {
    mockGetSeasonDetail = MockGetSeasonDetail();
    bloc = SeasonDetailBloc(mockGetSeasonDetail);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const SeasonDetailEmpty());
  });

  blocTest<SeasonDetailBloc, SeasonDetailState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockGetSeasonDetail.execute(tTvSeriesId, tSeasonNumber))
          .thenAnswer((_) async => const Right(testSeasonDetail));
      return bloc;
    },
    act: (bloc) =>
        bloc.add(const FetchSeasonDetail(tTvSeriesId, tSeasonNumber)),
    expect: () => [
      const SeasonDetailLoading(),
      const SeasonDetailHasData(
        SeasonDetail(
          id: 3624,
          seasonNumber: 1,
          name: 'Season 1',
          episodes: [
            Episode(
              id: 63056,
              episodeNumber: 1,
              seasonNumber: 1,
              name: 'Winter Is Coming',
              overview: 'Lord Eddard Stark is torn between his family and an old friend.',
              stillPath: '/9hGF3WUkBf7cSjMg0cdMDHJkByd.jpg',
              airDate: '2011-04-17',
              runtime: 62,
              voteAverage: 8.1,
            ),
          ],
        ),
      ),
    ],
    verify: (_) {
      verify(mockGetSeasonDetail.execute(tTvSeriesId, tSeasonNumber)).called(1);
    },
  );

  blocTest<SeasonDetailBloc, SeasonDetailState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockGetSeasonDetail.execute(tTvSeriesId, tSeasonNumber))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) =>
        bloc.add(const FetchSeasonDetail(tTvSeriesId, tSeasonNumber)),
    expect: () => [
      const SeasonDetailLoading(),
      const SeasonDetailError('Server Failure'),
    ],
    verify: (_) {
      verify(mockGetSeasonDetail.execute(tTvSeriesId, tSeasonNumber)).called(1);
    },
  );

  test(
    'a closed bloc is not written to when the use case answers late',
    () async {
      final pending = Completer<Either<Failure, SeasonDetail>>();
      when(mockGetSeasonDetail.execute(tTvSeriesId, tSeasonNumber))
          .thenAnswer((_) => pending.future);

      bloc.add(const FetchSeasonDetail(tTvSeriesId, tSeasonNumber));
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(const Right(testSeasonDetail));
      await closing;

      expect(bloc.state, const SeasonDetailLoading());
      verify(mockGetSeasonDetail.execute(tTvSeriesId, tSeasonNumber)).called(1);
    },
  );

  test('events and states compare by their values', () {
    expect(const FetchSeasonDetail(1, 2), const FetchSeasonDetail(1, 2));
    expect(const FetchSeasonDetail(1, 2), isNot(const FetchSeasonDetail(1, 3)));
    expect(const FetchSeasonDetail(1, 2).props, [1, 2]);
    expect(const SeasonDetailError('a'), const SeasonDetailError('a'));
    expect(const SeasonDetailError('a').props, ['a']);
    expect(const SeasonDetailEmpty().props, isEmpty);
    expect(const SeasonDetailHasData(testSeasonDetail).props, [
      testSeasonDetail,
    ]);
  });
}
