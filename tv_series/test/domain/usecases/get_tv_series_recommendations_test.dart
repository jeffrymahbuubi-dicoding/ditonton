import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/usecases/get_tv_series_recommendations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_domain_test_helper.mocks.dart';

void main() {
  late GetTvSeriesRecommendations usecase;
  late MockTvSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockTvSeriesRepository();
    usecase = GetTvSeriesRecommendations(mockRepository);
  });

  const tExpectedTvSeries = TvSeries(
    id: 1399,
    name: 'Game of Thrones',
    overview: 'Seven noble families fight for control of the mythical land of Westeros.',
    posterPath: '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
    backdropPath: '/2OMB0ynKlyIenMJWI2Dy9IWT4c.jpg',
    voteAverage: 8.4,
    voteCount: 25000,
    firstAirDate: '2011-04-17',
    genreIds: [10765, 18],
  );

  test('should get tv series recommendations from the repository', () async {
    // arrange
    when(mockRepository.getTvSeriesRecommendations(1))
        .thenAnswer((_) async => Right(testTvSeriesList));
    // act
    final result = await usecase.execute(1);
    // assert
    expect(result.getOrElse(() => []), [tExpectedTvSeries]);
    verify(mockRepository.getTvSeriesRecommendations(1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.getTvSeriesRecommendations(1))
        .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
    // act
    final result = await usecase.execute(1);
    // assert
    expect(result, const Left(ServerFailure('Server Failure')));
    verify(mockRepository.getTvSeriesRecommendations(1)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
