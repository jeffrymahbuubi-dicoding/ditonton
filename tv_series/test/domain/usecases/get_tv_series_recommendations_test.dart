import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
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

  test('should get tv series recommendations from the repository', () async {
    // arrange
    when(mockRepository.getTvSeriesRecommendations(1))
        .thenAnswer((_) async => Right(testTvSeriesList));
    // act
    final result = await usecase.execute(1);
    // assert
    expect(result, Right(testTvSeriesList));
    verify(mockRepository.getTvSeriesRecommendations(1));
  });

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.getTvSeriesRecommendations(1))
        .thenAnswer((_) async => const Left(ServerFailure('')));
    // act
    final result = await usecase.execute(1);
    // assert
    expect(result, const Left(ServerFailure('')));
  });
}
