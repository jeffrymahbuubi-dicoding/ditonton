import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
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

  test('should get the detail of a season from the repository', () async {
    // arrange
    when(mockRepository.getSeasonDetail(1399, 1))
        .thenAnswer((_) async => const Right(testSeasonDetail));
    // act
    final result = await usecase.execute(1399, 1);
    // assert
    expect(result, const Right(testSeasonDetail));
    verify(mockRepository.getSeasonDetail(1399, 1));
  });

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.getSeasonDetail(1399, 1))
        .thenAnswer((_) async => const Left(ServerFailure('')));
    // act
    final result = await usecase.execute(1399, 1);
    // assert
    expect(result, const Left(ServerFailure('')));
  });
}
