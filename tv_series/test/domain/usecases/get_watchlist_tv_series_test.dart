import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/usecases/get_watchlist_tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_domain_test_helper.mocks.dart';

void main() {
  late GetWatchlistTvSeries usecase;
  late MockTvSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockTvSeriesRepository();
    usecase = GetWatchlistTvSeries(mockRepository);
  });

  test('should get watchlist tv series from the repository', () async {
    // arrange
    when(mockRepository.getWatchlistTvSeries())
        .thenAnswer((_) async => Right(testTvSeriesList));
    // act
    final result = await usecase.execute();
    // assert
    expect(result, Right(testTvSeriesList));
    verify(mockRepository.getWatchlistTvSeries());
  });

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.getWatchlistTvSeries())
        .thenAnswer((_) async => const Left(ServerFailure('')));
    // act
    final result = await usecase.execute();
    // assert
    expect(result, const Left(ServerFailure('')));
  });
}
