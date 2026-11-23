import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';

class DatabaseHelper {
  static DatabaseHelper? _databaseHelper;
  DatabaseHelper._instance() {
    _databaseHelper = this;
  }

  factory DatabaseHelper() => _databaseHelper ?? DatabaseHelper._instance();

  static Database? _database;

  /// Lets a test supply a [Database] (or `null` to force a fresh open).
  @visibleForTesting
  static set testDatabase(Database? database) => _database = database;

  /// Lets a test open the database through a mocked [DatabaseFactory].
  @visibleForTesting
  static DatabaseFactory? testDatabaseFactory;

  Future<Database?> get database async {
    _database ??= await _initDb();
    return _database;
  }

  static const String _tblWatchlist = 'watchlist';
  static const String _tblTvSeriesWatchlist = 'tv_series_watchlist';
  static const int _databaseVersion = 2;

  Future<Database> _initDb() async {
    // Same calls as the global `openDatabase`, but through a factory a test
    // can replace.
    final factory = testDatabaseFactory ?? databaseFactory;
    final path = await factory.getDatabasesPath();
    final databasePath = '$path/ditonton.db';

    return factory.openDatabase(
      databasePath,
      options: OpenDatabaseOptions(
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade,
      ),
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE  $_tblWatchlist (
        id INTEGER PRIMARY KEY,
        title TEXT,
        overview TEXT,
        posterPath TEXT
      );
    ''');
    await _createTvSeriesWatchlist(db);
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createTvSeriesWatchlist(db);
    }
  }

  Future<void> _createTvSeriesWatchlist(Database db) async {
    await db.execute('''
      CREATE TABLE  $_tblTvSeriesWatchlist (
        id INTEGER PRIMARY KEY,
        name TEXT,
        overview TEXT,
        posterPath TEXT
      );
    ''');
  }

  Future<int> insertWatchlist(Map<String, dynamic> movie) async {
    final db = await database;
    return await db!.insert(_tblWatchlist, movie);
  }

  Future<int> removeWatchlist(int id) async {
    final db = await database;
    return await db!.delete(_tblWatchlist, where: 'id = ?', whereArgs: [id]);
  }

  Future<Map<String, dynamic>?> getMovieById(int id) async {
    final db = await database;
    final results = await db!.query(
      _tblWatchlist,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getWatchlistMovies() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(_tblWatchlist);

    return results;
  }

  Future<int> insertTvSeriesWatchlist(Map<String, dynamic> tvSeries) async {
    final db = await database;
    return await db!.insert(_tblTvSeriesWatchlist, tvSeries);
  }

  Future<int> removeTvSeriesWatchlist(int id) async {
    final db = await database;
    return await db!.delete(
      _tblTvSeriesWatchlist,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<Map<String, dynamic>?> getTvSeriesById(int id) async {
    final db = await database;
    final results = await db!.query(
      _tblTvSeriesWatchlist,
      where: 'id = ?',
      whereArgs: [id],
    );

    if (results.isNotEmpty) {
      return results.first;
    } else {
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getWatchlistTvSeries() async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db!.query(
      _tblTvSeriesWatchlist,
    );

    return results;
  }
}
