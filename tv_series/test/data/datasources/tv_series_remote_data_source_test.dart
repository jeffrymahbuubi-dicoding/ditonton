import 'dart:convert';

import 'package:core/core.dart';
import 'package:tv_series/data/datasources/tv_series_remote_data_source.dart';
import 'package:tv_series/data/models/season_detail_model.dart';
import 'package:tv_series/data/models/tv_series_detail_model.dart';
import 'package:tv_series/data/models/tv_series_model.dart';
import 'package:tv_series/data/models/tv_series_response.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/mockito.dart';

import '../../helpers/tv_series_data_test_helper.mocks.dart';
import '../../json_reader.dart';

void main() {
  late TvSeriesRemoteDataSourceImpl dataSource;
  late MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    dataSource = TvSeriesRemoteDataSourceImpl(client: mockHttpClient);
  });

  void stubGet(String url, String body, int status) {
    // The fixtures hold non-Latin-1 characters, so the body is sent as UTF-8
    // like TMDB does.
    when(mockHttpClient.get(Uri.parse(url))).thenAnswer(
      (_) async => http.Response.bytes(
        utf8.encode(body),
        status,
        headers: {'content-type': 'application/json; charset=utf-8'},
      ),
    );
  }

  // The list endpoints share the same shape; only the url, the fixture and
  // the method differ.
  final listEndpoints =
      <
        (
          String,
          String,
          String,
          Future<List<TvSeriesModel>> Function(TvSeriesRemoteDataSource),
        )
      >[
        (
          'now playing',
          '$baseUrl/tv/on_the_air?$apiKey',
          'dummy_data/tv_on_the_air.json',
          (d) => d.getNowPlayingTvSeries(),
        ),
        (
          'popular',
          '$baseUrl/tv/popular?$apiKey',
          'dummy_data/tv_popular.json',
          (d) => d.getPopularTvSeries(),
        ),
        (
          'top rated',
          '$baseUrl/tv/top_rated?$apiKey',
          'dummy_data/tv_top_rated.json',
          (d) => d.getTopRatedTvSeries(),
        ),
        (
          'recommendations',
          '$baseUrl/tv/1399/recommendations?$apiKey',
          'dummy_data/tv_recommendations.json',
          (d) => d.getTvSeriesRecommendations(1399),
        ),
        (
          'search',
          '$baseUrl/search/tv?$apiKey&query=game',
          'dummy_data/tv_search_game.json',
          (d) => d.searchTvSeries('game'),
        ),
      ];

  for (final (name, url, fixture, call) in listEndpoints) {
    group('get $name tv series', () {
      test(
        'should return list of TvSeriesModel when the code is 200',
        () async {
          // arrange
          stubGet(url, readJson(fixture), 200);
          // act
          final result = await call(dataSource);
          // assert
          final expected = TvSeriesResponse.fromJson(
            json.decode(readJson(fixture)),
          ).tvSeriesList;
          expect(result, expected);
          expect(result, isNotEmpty);
          verify(mockHttpClient.get(Uri.parse(url)));
        },
      );

      test('should throw ServerException when the code is 404', () async {
        // arrange
        stubGet(url, 'Not Found', 404);
        // act
        final result = call(dataSource);
        // assert
        expect(result, throwsA(isA<ServerException>()));
      });
    });
  }

  group('search', () {
    test('should encode the query in the url', () async {
      // arrange
      final url = '$baseUrl/search/tv?$apiKey&query=game+of+thrones';
      stubGet(url, readJson('dummy_data/tv_search_game.json'), 200);
      // act
      await dataSource.searchTvSeries('game of thrones');
      // assert
      verify(mockHttpClient.get(Uri.parse(url)));
    });
  });

  group('get tv series detail', () {
    final url = '$baseUrl/tv/1399?$apiKey';

    test('should return TvSeriesDetailResponse when the code is 200', () async {
      // arrange
      stubGet(url, readJson('dummy_data/tv_detail.json'), 200);
      // act
      final result = await dataSource.getTvSeriesDetail(1399);
      // assert
      final expected = TvSeriesDetailResponse.fromJson(
        json.decode(readJson('dummy_data/tv_detail.json')),
      );
      expect(result, expected);
      verify(mockHttpClient.get(Uri.parse(url)));
    });

    test('should throw ServerException when the code is 404', () async {
      // arrange
      stubGet(url, 'Not Found', 404);
      // act
      final call = dataSource.getTvSeriesDetail(1399);
      // assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });

  group('get season detail', () {
    final url = '$baseUrl/tv/1399/season/1?$apiKey';

    test('should return SeasonDetailResponse when the code is 200', () async {
      // arrange
      stubGet(url, readJson('dummy_data/tv_season_detail.json'), 200);
      // act
      final result = await dataSource.getSeasonDetail(1399, 1);
      // assert
      final expected = SeasonDetailResponse.fromJson(
        json.decode(readJson('dummy_data/tv_season_detail.json')),
      );
      expect(result, expected);
      verify(mockHttpClient.get(Uri.parse(url)));
    });

    test('should throw ServerException when the code is 404', () async {
      // arrange
      stubGet(url, 'Not Found', 404);
      // act
      final call = dataSource.getSeasonDetail(1399, 1);
      // assert
      expect(call, throwsA(isA<ServerException>()));
    });
  });
}
