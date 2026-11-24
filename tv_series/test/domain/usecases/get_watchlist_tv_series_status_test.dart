import 'package:tv_series/domain/usecases/get_watchlist_tv_series_status.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../helpers/tv_series_domain_test_helper.mocks.dart';

void main() {
  late GetWatchlistTvSeriesStatus usecase;
  late MockTvSeriesRepository mockRepository;

  setUp(() {
    mockRepository = MockTvSeriesRepository();
    usecase = GetWatchlistTvSeriesStatus(mockRepository);
  });

  test('should get the watchlist status from the repository', () async {
    // arrange
    when(mockRepository.isAddedToWatchlist(1399)).thenAnswer((_) async => true);
    // act
    final result = await usecase.execute(1399);
    // assert
    expect(result, true);
    verify(mockRepository.isAddedToWatchlist(1399)).called(1);
    verifyNoMoreInteractions(mockRepository);
  });
}
