import 'package:core/data/db/database_helper.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:sqflite/sqflite.dart';

import '../../helpers/test_helper.mocks.dart';

const testMovieMap = {
  'id': 1,
  'overview': 'overview',
  'posterPath': 'posterPath',
  'title': 'title',
};

const testTvSeriesMap = {
  'id': 1399,
  'name': 'Game of Thrones',
  'posterPath': '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
  'overview': 'Seven noble families fight for control of the mythical land of Westeros.',
};

void main() {
  late DatabaseHelper helper;
  late MockDatabase mockDatabase;

  setUp(() {
    mockDatabase = MockDatabase();
    helper = DatabaseHelper();
    DatabaseHelper.testDatabase = mockDatabase;
  });

  tearDown(() {
    DatabaseHelper.testDatabase = null;
    DatabaseHelper.testDatabaseFactory = null;
  });

  test('factory should always return the same instance', () {
    expect(DatabaseHelper(), same(helper));
  });

  group('opening the database', () {
    late MockDatabaseFactory mockFactory;
    late OpenDatabaseOptions options;

    setUp(() {
      DatabaseHelper.testDatabase = null;
      mockFactory = MockDatabaseFactory();
      DatabaseHelper.testDatabaseFactory = mockFactory;
      when(mockFactory.getDatabasesPath()).thenAnswer((_) async => '/db');
      when(
        mockFactory.openDatabase(
          '/db/ditonton.db',
          options: anyNamed('options'),
        ),
      ).thenAnswer((invocation) async {
        options = invocation.namedArguments[#options] as OpenDatabaseOptions;
        return mockDatabase;
      });
    });

    test('should open ditonton.db with version 2 once and reuse it', () async {
      final first = await helper.database;
      final second = await helper.database;

      expect(first, same(mockDatabase));
      expect(second, same(mockDatabase));
      expect(options.version, 2);
      verify(
        mockFactory.openDatabase(
          '/db/ditonton.db',
          options: anyNamed('options'),
        ),
      ).called(1);
    });

    test('onCreate should create both watchlist tables', () async {
      await helper.database;

      await options.onCreate!(mockDatabase, 2);

      final sql = verify(mockDatabase.execute(captureAny)).captured;
      expect(sql, hasLength(2));
      expect(sql[0], contains('CREATE TABLE  watchlist'));
      expect(sql[0], contains('title TEXT'));
      expect(sql[1], contains('CREATE TABLE  tv_series_watchlist'));
      expect(sql[1], contains('name TEXT'));
    });

    test('onUpgrade from version 1 should add the tv series table', () async {
      await helper.database;

      await options.onUpgrade!(mockDatabase, 1, 2);

      final sql = verify(mockDatabase.execute(captureAny)).captured;
      expect(sql, hasLength(1));
      expect(sql.single, contains('CREATE TABLE  tv_series_watchlist'));
    });

    test('onUpgrade from version 2 should change nothing', () async {
      await helper.database;

      await options.onUpgrade!(mockDatabase, 2, 2);

      verifyNever(mockDatabase.execute(any));
    });
  });

  group('movie watchlist', () {
    test('insertWatchlist should insert the movie row', () async {
      when(mockDatabase.insert('watchlist', testMovieMap))
          .thenAnswer((_) async => 1);

      final result = await helper.insertWatchlist(testMovieMap);

      expect(result, 1);
    });

    test('removeWatchlist should delete the movie row by id', () async {
      when(mockDatabase.delete('watchlist', where: 'id = ?', whereArgs: [1]))
          .thenAnswer((_) async => 1);

      final result = await helper.removeWatchlist(1);

      expect(result, 1);
    });

    test('getMovieById should return the first row', () async {
      when(mockDatabase.query('watchlist', where: 'id = ?', whereArgs: [1]))
          .thenAnswer((_) async => [testMovieMap]);

      final result = await helper.getMovieById(1);

      expect(result, testMovieMap);
    });

    test('getMovieById should return null when there is no row', () async {
      when(mockDatabase.query('watchlist', where: 'id = ?', whereArgs: [1]))
          .thenAnswer((_) async => []);

      expect(await helper.getMovieById(1), isNull);
    });

    test('getWatchlistMovies should return every row', () async {
      when(mockDatabase.query('watchlist'))
          .thenAnswer((_) async => [testMovieMap]);

      expect(await helper.getWatchlistMovies(), [testMovieMap]);
    });
  });

  group('tv series watchlist', () {
    test('insertTvSeriesWatchlist should insert into its own table', () async {
      when(mockDatabase.insert('tv_series_watchlist', testTvSeriesMap))
          .thenAnswer((_) async => 1);

      final result = await helper.insertTvSeriesWatchlist(testTvSeriesMap);

      expect(result, 1);
      verifyNever(mockDatabase.insert('watchlist', any));
    });

    test('removeTvSeriesWatchlist should delete the row by id', () async {
      when(
        mockDatabase.delete(
          'tv_series_watchlist',
          where: 'id = ?',
          whereArgs: [1399],
        ),
      ).thenAnswer((_) async => 1);

      final result = await helper.removeTvSeriesWatchlist(1399);

      expect(result, 1);
    });

    test('getTvSeriesById should return the first row', () async {
      when(
        mockDatabase.query(
          'tv_series_watchlist',
          where: 'id = ?',
          whereArgs: [1399],
        ),
      ).thenAnswer((_) async => [testTvSeriesMap]);

      final result = await helper.getTvSeriesById(1399);

      expect(result, testTvSeriesMap);
    });

    test('getTvSeriesById should return null when there is no row', () async {
      when(
        mockDatabase.query(
          'tv_series_watchlist',
          where: 'id = ?',
          whereArgs: [1399],
        ),
      ).thenAnswer((_) async => []);

      expect(await helper.getTvSeriesById(1399), isNull);
    });

    test('getWatchlistTvSeries should return every row', () async {
      when(mockDatabase.query('tv_series_watchlist'))
          .thenAnswer((_) async => [testTvSeriesMap]);

      expect(await helper.getWatchlistTvSeries(), [testTvSeriesMap]);
    });
  });
}
