import 'dart:convert';

import 'package:core/core.dart';
import 'package:tv_series/data/models/season_detail_model.dart';
import 'package:tv_series/data/models/tv_series_detail_model.dart';
import 'package:tv_series/data/models/tv_series_model.dart';
import 'package:tv_series/data/models/tv_series_response.dart';
import 'package:http/http.dart' as http;

abstract class TvSeriesRemoteDataSource {
  Future<List<TvSeriesModel>> getNowPlayingTvSeries();
  Future<List<TvSeriesModel>> getPopularTvSeries();
  Future<List<TvSeriesModel>> getTopRatedTvSeries();
  Future<TvSeriesDetailResponse> getTvSeriesDetail(int id);
  Future<List<TvSeriesModel>> getTvSeriesRecommendations(int id);
  Future<List<TvSeriesModel>> searchTvSeries(String query);
  Future<SeasonDetailResponse> getSeasonDetail(
    int tvSeriesId,
    int seasonNumber,
  );
}

class TvSeriesRemoteDataSourceImpl implements TvSeriesRemoteDataSource {
  TvSeriesRemoteDataSourceImpl({required this.client});

  final http.Client client;

  Future<List<TvSeriesModel>> _getList(String url) async {
    final response = await client.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return TvSeriesResponse.fromJson(json.decode(response.body)).tvSeriesList;
    } else {
      throw ServerException();
    }
  }

  @override
  Future<List<TvSeriesModel>> getNowPlayingTvSeries() =>
      _getList('$baseUrl/tv/on_the_air?$apiKey');

  @override
  Future<List<TvSeriesModel>> getPopularTvSeries() =>
      _getList('$baseUrl/tv/popular?$apiKey');

  @override
  Future<List<TvSeriesModel>> getTopRatedTvSeries() =>
      _getList('$baseUrl/tv/top_rated?$apiKey');

  @override
  Future<List<TvSeriesModel>> getTvSeriesRecommendations(int id) =>
      _getList('$baseUrl/tv/$id/recommendations?$apiKey');

  @override
  Future<List<TvSeriesModel>> searchTvSeries(String query) => _getList(
    '$baseUrl/search/tv?$apiKey&query=${Uri.encodeQueryComponent(query)}',
  );

  @override
  Future<TvSeriesDetailResponse> getTvSeriesDetail(int id) async {
    final response = await client.get(Uri.parse('$baseUrl/tv/$id?$apiKey'));

    if (response.statusCode == 200) {
      return TvSeriesDetailResponse.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }

  @override
  Future<SeasonDetailResponse> getSeasonDetail(
    int tvSeriesId,
    int seasonNumber,
  ) async {
    final response = await client.get(
      Uri.parse('$baseUrl/tv/$tvSeriesId/season/$seasonNumber?$apiKey'),
    );

    if (response.statusCode == 200) {
      return SeasonDetailResponse.fromJson(json.decode(response.body));
    } else {
      throw ServerException();
    }
  }
}
