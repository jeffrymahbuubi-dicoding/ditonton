import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/usecases/save_watchlist_tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_domain_test_helper.mocks.dart';

void main() {
  late SaveWatchlistTvSeries usecase;
  late MockTvSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockTvSeriesRepository();
    usecase = SaveWatchlistTvSeries(mockRepository);
  });

  test(
    'should save a tv series to the watchlist from the repository',
    () async {
      // arrange
      when(mockRepository.saveWatchlist(testTvSeriesDetail))
          .thenAnswer((_) async => const Right('Added to Watchlist'));
      // act
      final result = await usecase.execute(testTvSeriesDetail);
      // assert
      expect(result, const Right('Added to Watchlist'));
      verify(mockRepository.saveWatchlist(testTvSeriesDetail)).called(1);
      verifyNoMoreInteractions(mockRepository);
    },
  );

  test('should pass the failure of the repository through', () async {
    // arrange
    when(mockRepository.saveWatchlist(testTvSeriesDetail))
        .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
    // act
    final result = await usecase.execute(testTvSeriesDetail);
    // assert
    expect(result, const Left(ServerFailure('Server Failure')));
    verify(mockRepository.saveWatchlist(testTvSeriesDetail)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
