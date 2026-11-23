import 'package:movie/data/models/movie_table.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/dummy_objects.dart';

void main() {
  test('fromEntity should copy the fields of a MovieDetail', () {
    final result = MovieTable.fromEntity(testMovieDetail);
    expect(result, testMovieTable);
  });

  test('fromMap should read the fields of a database row', () {
    expect(MovieTable.fromMap(testMovieMap), testMovieTable);
  });

  test('toJson should return a map with the four fields', () {
    expect(testMovieTable.toJson(), testMovieMap);
  });

  test('toEntity should return a watchlist Movie', () {
    expect(testMovieTable.toEntity(), testWatchlistMovie);
  });

  test('tables with different values should not be equal', () {
    const other = MovieTable(
      id: 2,
      title: 'title',
      posterPath: 'posterPath',
      overview: 'overview',
    );
    expect(other, isNot(testMovieTable));
  });
}
