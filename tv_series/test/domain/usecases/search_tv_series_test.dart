import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/usecases/search_tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_domain_test_helper.mocks.dart';

void main() {
  late SearchTvSeries usecase;
  late MockTvSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockTvSeriesRepository();
    usecase = SearchTvSeries(mockRepository);
  });

  test('should get tv series matching the query from the repository', () async {
    // arrange
    when(mockRepository.searchTvSeries('game'))
        .thenAnswer((_) async => Right(testTvSeriesList));
    // act
    final result = await usecase.execute('game');
    // assert
    expect(result, Right(testTvSeriesList));
    verify(mockRepository.searchTvSeries('game'));
  });

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.searchTvSeries('game'))
        .thenAnswer((_) async => const Left(ServerFailure('')));
    // act
    final result = await usecase.execute('game');
    // assert
    expect(result, const Left(ServerFailure('')));
  });
}
