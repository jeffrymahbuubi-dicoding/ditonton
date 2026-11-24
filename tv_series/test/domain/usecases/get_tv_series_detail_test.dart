import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/entities/season.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:tv_series/domain/usecases/get_tv_series_detail.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_domain_test_helper.mocks.dart';

void main() {
  late GetTvSeriesDetail usecase;
  late MockTvSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockTvSeriesRepository();
    usecase = GetTvSeriesDetail(mockRepository);
  });

  const tExpectedDetail = TvSeriesDetail(
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
    seasons: [
      Season(
        id: 3624,
        seasonNumber: 1,
        episodeCount: 10,
        name: 'Season 1',
        overview: 'Trouble is brewing in the Seven Kingdoms of Westeros.',
        posterPath: '/wgfKiqzuMrFIkU1M68DDDY8kGC1.jpg',
        airDate: '2011-04-17',
      ),
    ],
  );

  test('should get the detail of a tv series from the repository', () async {
    // arrange
    when(mockRepository.getTvSeriesDetail(1))
        .thenAnswer((_) async => const Right(testTvSeriesDetail));
    // act
    final result = await usecase.execute(1);
    // assert
    expect(result, const Right(tExpectedDetail));
    verify(mockRepository.getTvSeriesDetail(1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.getTvSeriesDetail(1))
        .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
    // act
    final result = await usecase.execute(1);
    // assert
    expect(result, const Left(ServerFailure('Server Failure')));
    verify(mockRepository.getTvSeriesDetail(1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
