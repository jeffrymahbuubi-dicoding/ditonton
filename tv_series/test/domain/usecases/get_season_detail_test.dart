import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/entities/episode.dart';
import 'package:tv_series/domain/entities/season_detail.dart';
import 'package:tv_series/domain/usecases/get_season_detail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_domain_test_helper.mocks.dart';

void main() {
  late GetSeasonDetail usecase;
  late MockTvSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockTvSeriesRepository();
    usecase = GetSeasonDetail(mockRepository);
  });

  const tExpectedSeasonDetail = SeasonDetail(
    id: 3624,
    seasonNumber: 1,
    name: 'Season 1',
    episodes: [
      Episode(
        id: 63056,
        episodeNumber: 1,
        seasonNumber: 1,
        name: 'Winter Is Coming',
        overview:
            'Lord Eddard Stark is torn between his family and an old friend.',
        stillPath: '/9hGF3WUkBf7cSjMg0cdMDHJkByd.jpg',
        airDate: '2011-04-17',
        runtime: 62,
        voteAverage: 8.1,
      ),
    ],
  );

  test('should get the detail of a season from the repository', () async {
    // arrange
    when(mockRepository.getSeasonDetail(1399, 1))
        .thenAnswer((_) async => const Right(testSeasonDetail));
    // act
    final result = await usecase.execute(1399, 1);
    // assert
    expect(result, const Right(tExpectedSeasonDetail));
    verify(mockRepository.getSeasonDetail(1399, 1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.getSeasonDetail(1399, 1))
        .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
    // act
    final result = await usecase.execute(1399, 1);
    // assert
    expect(result, const Left(ServerFailure('Server Failure')));
    verify(mockRepository.getSeasonDetail(1399, 1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
