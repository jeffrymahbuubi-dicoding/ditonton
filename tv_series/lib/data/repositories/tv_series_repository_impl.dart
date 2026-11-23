import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/data/datasources/tv_series_local_data_source.dart';
import 'package:tv_series/data/datasources/tv_series_remote_data_source.dart';
import 'package:tv_series/data/models/tv_series_model.dart';
import 'package:tv_series/data/models/tv_series_table.dart';
import 'package:tv_series/domain/entities/season_detail.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:tv_series/domain/repositories/tv_series_repository.dart';

class TvSeriesRepositoryImpl implements TvSeriesRepository {
  TvSeriesRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  final TvSeriesRemoteDataSource remoteDataSource;
  final TvSeriesLocalDataSource localDataSource;

  Future<Either<Failure, T>> _fromRemote<T>(Future<T> Function() call) async {
    try {
      return Right(await call());
    } on ServerException {
      return const Left(ServerFailure('Failed to load data from the server'));
    } on TlsException {
      return const Left(SslFailure('Failed to verify the server certificate'));
    } on SocketException {
      return const Left(ConnectionFailure('Failed to connect to the network'));
    } on Exception {
      return const Left(ServerFailure('Something went wrong'));
    }
  }

  Future<Either<Failure, List<TvSeries>>> _fromRemoteList(
    Future<List<TvSeriesModel>> Function() call,
  ) => _fromRemote(
    () async => (await call()).map((model) => model.toEntity()).toList(),
  );

  @override
  Future<Either<Failure, List<TvSeries>>> getNowPlayingTvSeries() =>
      _fromRemoteList(remoteDataSource.getNowPlayingTvSeries);

  @override
  Future<Either<Failure, List<TvSeries>>> getPopularTvSeries() =>
      _fromRemoteList(remoteDataSource.getPopularTvSeries);

  @override
  Future<Either<Failure, List<TvSeries>>> getTopRatedTvSeries() =>
      _fromRemoteList(remoteDataSource.getTopRatedTvSeries);

  @override
  Future<Either<Failure, List<TvSeries>>> getTvSeriesRecommendations(int id) =>
      _fromRemoteList(() => remoteDataSource.getTvSeriesRecommendations(id));

  @override
  Future<Either<Failure, List<TvSeries>>> searchTvSeries(String query) =>
      _fromRemoteList(() => remoteDataSource.searchTvSeries(query));

  @override
  Future<Either<Failure, TvSeriesDetail>> getTvSeriesDetail(int id) =>
      _fromRemote(() async {
        final result = await remoteDataSource.getTvSeriesDetail(id);
        return result.toEntity();
      });

  @override
  Future<Either<Failure, SeasonDetail>> getSeasonDetail(
    int tvSeriesId,
    int seasonNumber,
  ) => _fromRemote(() async {
    final result = await remoteDataSource.getSeasonDetail(
      tvSeriesId,
      seasonNumber,
    );
    return result.toEntity();
  });

  @override
  Future<Either<Failure, String>> saveWatchlist(TvSeriesDetail tvSeries) async {
    try {
      final result = await localDataSource.insertWatchlist(
        TvSeriesTable.fromEntity(tvSeries),
      );
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> removeWatchlist(
    TvSeriesDetail tvSeries,
  ) async {
    try {
      final result = await localDataSource.removeWatchlist(
        TvSeriesTable.fromEntity(tvSeries),
      );
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<bool> isAddedToWatchlist(int id) async {
    final result = await localDataSource.getTvSeriesById(id);
    return result != null;
  }

  @override
  Future<Either<Failure, List<TvSeries>>> getWatchlistTvSeries() async {
    final result = await localDataSource.getWatchlistTvSeries();
    return Right(result.map((data) => data.toWatchlistEntity()).toList());
  }
}
