import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:movie/data/datasources/movie_local_data_source.dart';
import 'package:movie/data/datasources/movie_remote_data_source.dart';
import 'package:movie/data/models/movie_table.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/domain/entities/movie_detail.dart';
import 'package:movie/domain/repositories/movie_repository.dart';
import 'package:core/core.dart';

class MovieRepositoryImpl implements MovieRepository {
  final MovieRemoteDataSource remoteDataSource;
  final MovieLocalDataSource localDataSource;

  MovieRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
  });

  @override
  Future<Either<Failure, List<Movie>>> getNowPlayingMovies() {
    return _request(() async {
      final result = await remoteDataSource.getNowPlayingMovies();
      return result.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, MovieDetail>> getMovieDetail(int id) {
    return _request(() async {
      final result = await remoteDataSource.getMovieDetail(id);
      return result.toEntity();
    });
  }

  @override
  Future<Either<Failure, List<Movie>>> getMovieRecommendations(int id) {
    return _request(() async {
      final result = await remoteDataSource.getMovieRecommendations(id);
      return result.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<Movie>>> getPopularMovies() {
    return _request(() async {
      final result = await remoteDataSource.getPopularMovies();
      return result.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<Movie>>> getTopRatedMovies() {
    return _request(() async {
      final result = await remoteDataSource.getTopRatedMovies();
      return result.map((model) => model.toEntity()).toList();
    });
  }

  @override
  Future<Either<Failure, List<Movie>>> searchMovies(String query) {
    return _request(() async {
      final result = await remoteDataSource.searchMovies(query);
      return result.map((model) => model.toEntity()).toList();
    });
  }

  Future<Either<Failure, T>> _request<T>(Future<T> Function() call) async {
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

  @override
  Future<Either<Failure, String>> saveWatchlist(MovieDetail movie) async {
    try {
      final result = await localDataSource.insertWatchlist(
        MovieTable.fromEntity(movie),
      );
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<Either<Failure, String>> removeWatchlist(MovieDetail movie) async {
    try {
      final result = await localDataSource.removeWatchlist(
        MovieTable.fromEntity(movie),
      );
      return Right(result);
    } on DatabaseException catch (e) {
      return Left(DatabaseFailure(e.message));
    }
  }

  @override
  Future<bool> isAddedToWatchlist(int id) async {
    final result = await localDataSource.getMovieById(id);
    return result != null;
  }

  @override
  Future<Either<Failure, List<Movie>>> getWatchlistMovies() async {
    final result = await localDataSource.getWatchlistMovies();
    return Right(result.map((data) => data.toEntity()).toList());
  }
}
