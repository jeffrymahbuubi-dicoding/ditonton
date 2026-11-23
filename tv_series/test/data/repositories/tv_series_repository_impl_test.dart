import 'dart:io';

import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/data/models/tv_series_model.dart';
import 'package:tv_series/data/repositories/tv_series_repository_impl.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import '../../dummy_data/tv_series_dummy_models.dart';
import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_data_test_helper.mocks.dart';

void main() {
  late TvSeriesRepositoryImpl repository;
  late MockTvSeriesRemoteDataSource mockRemoteDataSource;
  late MockTvSeriesLocalDataSource mockLocalDataSource;

  setUp(() {
    mockRemoteDataSource = MockTvSeriesRemoteDataSource();
    mockLocalDataSource = MockTvSeriesLocalDataSource();
    repository = TvSeriesRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  const connectionFailure = ConnectionFailure(
    'Failed to connect to the network',
  );
  const serverFailure = ServerFailure('Failed to load data from the server');
  const sslFailure = SslFailure('Failed to verify the server certificate');
  const unknownFailure = ServerFailure('Something went wrong');

  // The five list methods behave the same way, so one table drives them.
  final listMethods =
      <
        (
          String,
          Future<List<TvSeriesModel>> Function(MockTvSeriesRemoteDataSource),
          Future<Either<Failure, List<TvSeries>>> Function(
            TvSeriesRepositoryImpl,
          ),
        )
      >[
        (
          'now playing',
          (d) => d.getNowPlayingTvSeries(),
          (r) => r.getNowPlayingTvSeries(),
        ),
        (
          'popular',
          (d) => d.getPopularTvSeries(),
          (r) => r.getPopularTvSeries(),
        ),
        (
          'top rated',
          (d) => d.getTopRatedTvSeries(),
          (r) => r.getTopRatedTvSeries(),
        ),
        (
          'recommendations',
          (d) => d.getTvSeriesRecommendations(1399),
          (r) => r.getTvSeriesRecommendations(1399),
        ),
        (
          'search',
          (d) => d.searchTvSeries('game'),
          (r) => r.searchTvSeries('game'),
        ),
      ];

  for (final (name, stub, call) in listMethods) {
    group('$name tv series', () {
      test(
        'should return the entities when the data source succeeds',
        () async {
          // arrange
          when(stub(mockRemoteDataSource))
              .thenAnswer((_) async => [testTvSeriesModel]);
          // act
          final result = await call(repository);
          // assert
          final list = result.getOrElse(() => []);
          expect(list, testTvSeriesList);
        },
      );

      test('should return ServerFailure on a ServerException', () async {
        // arrange
        when(stub(mockRemoteDataSource)).thenThrow(ServerException());
        // act
        final result = await call(repository);
        // assert
        expect(result, const Left(serverFailure));
      });

      test('should return ConnectionFailure on a SocketException', () async {
        // arrange
        when(
          stub(mockRemoteDataSource),
        ).thenThrow(const SocketException('Failed to connect to the network'));
        // act
        final result = await call(repository);
        // assert
        verify(stub(mockRemoteDataSource)).called(1);
        expect(result, const Left(connectionFailure));
      });

      test('should return SslFailure on a TlsException', () async {
        // arrange
        when(stub(mockRemoteDataSource))
            .thenThrow(const TlsException('Certificate rejected'));
        // act
        final result = await call(repository);
        // assert
        verify(stub(mockRemoteDataSource)).called(1);
        expect(result, const Left(sslFailure));
      });

      test('should return a ServerFailure on any other exception', () async {
        // arrange
        when(stub(mockRemoteDataSource))
            .thenThrow(const FormatException('Unexpected data'));
        // act
        final result = await call(repository);
        // assert
        verify(stub(mockRemoteDataSource)).called(1);
        expect(result, const Left(unknownFailure));
      });
    });
  }

  group('tv series detail', () {
    test('should return the entity when the data source succeeds', () async {
      // arrange
      when(mockRemoteDataSource.getTvSeriesDetail(1399))
          .thenAnswer((_) async => testTvSeriesDetailResponse);
      // act
      final result = await repository.getTvSeriesDetail(1399);
      // assert
      verify(mockRemoteDataSource.getTvSeriesDetail(1399));
      expect(result, const Right(testTvSeriesDetail));
    });

    test('should return ServerFailure on a ServerException', () async {
      // arrange
      when(mockRemoteDataSource.getTvSeriesDetail(1399))
          .thenThrow(ServerException());
      // act
      final result = await repository.getTvSeriesDetail(1399);
      // assert
      expect(result, const Left(serverFailure));
    });

    test('should return ConnectionFailure on a SocketException', () async {
      // arrange
      when(mockRemoteDataSource.getTvSeriesDetail(1399))
          .thenThrow(const SocketException('Failed to connect to the network'));
      // act
      final result = await repository.getTvSeriesDetail(1399);
      // assert
      expect(result, const Left(connectionFailure));
    });

    test('should return SslFailure on a TlsException', () async {
      // arrange
      when(mockRemoteDataSource.getTvSeriesDetail(1399))
          .thenThrow(const TlsException('Certificate rejected'));
      // act
      final result = await repository.getTvSeriesDetail(1399);
      // assert
      verify(mockRemoteDataSource.getTvSeriesDetail(1399)).called(1);
      expect(result, const Left(sslFailure));
    });

    test('should return a ServerFailure on any other exception', () async {
      // arrange
      when(mockRemoteDataSource.getTvSeriesDetail(1399))
          .thenThrow(const FormatException('Unexpected data'));
      // act
      final result = await repository.getTvSeriesDetail(1399);
      // assert
      verify(mockRemoteDataSource.getTvSeriesDetail(1399)).called(1);
      expect(result, const Left(unknownFailure));
    });
  });

  group('season detail', () {
    test('should return the entity when the data source succeeds', () async {
      // arrange
      when(mockRemoteDataSource.getSeasonDetail(1399, 1))
          .thenAnswer((_) async => testSeasonDetailResponse);
      // act
      final result = await repository.getSeasonDetail(1399, 1);
      // assert
      verify(mockRemoteDataSource.getSeasonDetail(1399, 1));
      expect(result, const Right(testSeasonDetail));
    });

    test('should return ServerFailure on a ServerException', () async {
      // arrange
      when(mockRemoteDataSource.getSeasonDetail(1399, 1))
          .thenThrow(ServerException());
      // act
      final result = await repository.getSeasonDetail(1399, 1);
      // assert
      expect(result, const Left(serverFailure));
    });

    test('should return ConnectionFailure on a SocketException', () async {
      // arrange
      when(mockRemoteDataSource.getSeasonDetail(1399, 1))
          .thenThrow(const SocketException('Failed to connect to the network'));
      // act
      final result = await repository.getSeasonDetail(1399, 1);
      // assert
      expect(result, const Left(connectionFailure));
    });

    test('should return SslFailure on a TlsException', () async {
      // arrange
      when(mockRemoteDataSource.getSeasonDetail(1399, 1))
          .thenThrow(const TlsException('Certificate rejected'));
      // act
      final result = await repository.getSeasonDetail(1399, 1);
      // assert
      verify(mockRemoteDataSource.getSeasonDetail(1399, 1)).called(1);
      expect(result, const Left(sslFailure));
    });

    test('should return a ServerFailure on any other exception', () async {
      // arrange
      when(mockRemoteDataSource.getSeasonDetail(1399, 1))
          .thenThrow(const FormatException('Unexpected data'));
      // act
      final result = await repository.getSeasonDetail(1399, 1);
      // assert
      verify(mockRemoteDataSource.getSeasonDetail(1399, 1)).called(1);
      expect(result, const Left(unknownFailure));
    });
  });

  group('save watchlist', () {
    test('should return success message when saving is successful', () async {
      // arrange
      when(mockLocalDataSource.insertWatchlist(testTvSeriesTable))
          .thenAnswer((_) async => 'Added to Watchlist');
      // act
      final result = await repository.saveWatchlist(testTvSeriesDetail);
      // assert
      expect(result, const Right('Added to Watchlist'));
    });

    test('should return DatabaseFailure when saving fails', () async {
      // arrange
      when(mockLocalDataSource.insertWatchlist(testTvSeriesTable))
          .thenThrow(DatabaseException('Failed to add watchlist'));
      // act
      final result = await repository.saveWatchlist(testTvSeriesDetail);
      // assert
      expect(result, const Left(DatabaseFailure('Failed to add watchlist')));
    });
  });

  group('remove watchlist', () {
    test('should return success message when removing is successful', () async {
      // arrange
      when(mockLocalDataSource.removeWatchlist(testTvSeriesTable))
          .thenAnswer((_) async => 'Removed from Watchlist');
      // act
      final result = await repository.removeWatchlist(testTvSeriesDetail);
      // assert
      expect(result, const Right('Removed from Watchlist'));
    });

    test('should return DatabaseFailure when removing fails', () async {
      // arrange
      when(mockLocalDataSource.removeWatchlist(testTvSeriesTable))
          .thenThrow(DatabaseException('Failed to remove watchlist'));
      // act
      final result = await repository.removeWatchlist(testTvSeriesDetail);
      // assert
      expect(result, const Left(DatabaseFailure('Failed to remove watchlist')));
    });
  });

  group('watchlist status', () {
    test('should return true when the series is saved', () async {
      // arrange
      when(mockLocalDataSource.getTvSeriesById(1399))
          .thenAnswer((_) async => testTvSeriesTable);
      // act
      final result = await repository.isAddedToWatchlist(1399);
      // assert
      expect(result, true);
    });

    test('should return false when the series is not saved', () async {
      // arrange
      when(mockLocalDataSource.getTvSeriesById(1399))
          .thenAnswer((_) async => null);
      // act
      final result = await repository.isAddedToWatchlist(1399);
      // assert
      expect(result, false);
    });
  });

  group('get watchlist tv series', () {
    test('should return the saved series as entities', () async {
      // arrange
      when(mockLocalDataSource.getWatchlistTvSeries())
          .thenAnswer((_) async => [testTvSeriesTable]);
      // act
      final result = await repository.getWatchlistTvSeries();
      // assert
      final list = result.getOrElse(() => []);
      expect(list, [testWatchlistTvSeries]);
    });
  });
}
