import 'package:core/core.dart';
import 'package:tv_series/data/datasources/tv_series_local_data_source.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_models.dart';
import '../../helpers/tv_series_data_test_helper.mocks.dart';

void main() {
  late TvSeriesLocalDataSourceImpl dataSource;
  late MockDatabaseHelper mockDatabaseHelper;

  setUp(() {
    mockDatabaseHelper = MockDatabaseHelper();
    dataSource = TvSeriesLocalDataSourceImpl(
      databaseHelper: mockDatabaseHelper,
    );
  });

  group('save watchlist', () {
    test('should return success message when insert is successful', () async {
      // arrange
      when(
        mockDatabaseHelper.insertTvSeriesWatchlist(testTvSeriesTable.toJson()),
      ).thenAnswer((_) async => 1);
      // act
      final result = await dataSource.insertWatchlist(testTvSeriesTable);
      // assert
      expect(result, 'Added to Watchlist');
    });

    test('should throw DatabaseException when insert fails', () async {
      // arrange
      when(
        mockDatabaseHelper.insertTvSeriesWatchlist(testTvSeriesTable.toJson()),
      ).thenThrow(Exception('insert failed'));
      // act
      final call = dataSource.insertWatchlist(testTvSeriesTable);
      // assert
      expect(call, throwsA(isA<DatabaseException>()));
    });
  });

  group('remove watchlist', () {
    test('should return success message when remove is successful', () async {
      // arrange
      when(mockDatabaseHelper.removeTvSeriesWatchlist(testTvSeriesTable.id))
          .thenAnswer((_) async => 1);
      // act
      final result = await dataSource.removeWatchlist(testTvSeriesTable);
      // assert
      expect(result, 'Removed from Watchlist');
    });

    test('should throw DatabaseException when remove fails', () async {
      // arrange
      when(mockDatabaseHelper.removeTvSeriesWatchlist(testTvSeriesTable.id))
          .thenThrow(Exception('remove failed'));
      // act
      final call = dataSource.removeWatchlist(testTvSeriesTable);
      // assert
      expect(call, throwsA(isA<DatabaseException>()));
    });
  });

  group('get tv series by id', () {
    test('should return the table when the row is found', () async {
      // arrange
      when(mockDatabaseHelper.getTvSeriesById(1399))
          .thenAnswer((_) async => testTvSeriesMap);
      // act
      final result = await dataSource.getTvSeriesById(1399);
      // assert
      expect(result, testTvSeriesTable);
    });

    test('should return null when the row is not found', () async {
      // arrange
      when(mockDatabaseHelper.getTvSeriesById(1399))
          .thenAnswer((_) async => null);
      // act
      final result = await dataSource.getTvSeriesById(1399);
      // assert
      expect(result, isNull);
    });
  });

  group('get watchlist tv series', () {
    test('should return the list of tables', () async {
      // arrange
      when(mockDatabaseHelper.getWatchlistTvSeries())
          .thenAnswer((_) async => [testTvSeriesMap]);
      // act
      final result = await dataSource.getWatchlistTvSeries();
      // assert
      expect(result, [testTvSeriesTable]);
    });

    test('should return an empty list when nothing is saved', () async {
      // arrange
      when(mockDatabaseHelper.getWatchlistTvSeries())
          .thenAnswer((_) async => []);
      // act
      final result = await dataSource.getWatchlistTvSeries();
      // assert
      expect(result, isEmpty);
    });
  });
}
