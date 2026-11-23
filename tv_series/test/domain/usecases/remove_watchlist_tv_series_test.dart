import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/usecases/remove_watchlist_tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_domain_test_helper.mocks.dart';

void main() {
  late RemoveWatchlistTvSeries usecase;
  late MockTvSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockTvSeriesRepository();
    usecase = RemoveWatchlistTvSeries(mockRepository);
  });

  test(
    'should remove a tv series from the watchlist from the repository',
    () async {
      // arrange
      when(mockRepository.removeWatchlist(testTvSeriesDetail))
          .thenAnswer((_) async => const Right('Removed from Watchlist'));
      // act
      final result = await usecase.execute(testTvSeriesDetail);
      // assert
      expect(result, const Right('Removed from Watchlist'));
      verify(mockRepository.removeWatchlist(testTvSeriesDetail));
    },
  );

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.removeWatchlist(testTvSeriesDetail))
        .thenAnswer((_) async => const Left(ServerFailure('')));
    // act
    final result = await usecase.execute(testTvSeriesDetail);
    // assert
    expect(result, const Left(ServerFailure('')));
  });
}
