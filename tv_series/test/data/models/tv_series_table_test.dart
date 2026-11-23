import 'package:tv_series/data/models/tv_series_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/tv_series_dummy_models.dart';
import '../../dummy_data/tv_series_dummy_objects.dart';

void main() {
  test('fromEntity should copy the fields of a TvSeriesDetail', () {
    expect(TvSeriesTable.fromEntity(testTvSeriesDetail), testTvSeriesTable);
  });

  test('fromMap should read the fields of a database row', () {
    expect(TvSeriesTable.fromMap(testTvSeriesMap), testTvSeriesTable);
  });

  test('toJson should return a map with the four columns', () {
    expect(testTvSeriesTable.toJson(), testTvSeriesMap);
  });

  test('toWatchlistEntity should return a watchlist TvSeries', () {
    expect(testTvSeriesTable.toWatchlistEntity(), testWatchlistTvSeries);
  });

  test('tables with different values should not be equal', () {
    const other = TvSeriesTable(
      id: 2,
      name: 'name',
      posterPath: 'posterPath',
      overview: 'overview',
    );
    expect(other, isNot(testTvSeriesTable));
  });
}
