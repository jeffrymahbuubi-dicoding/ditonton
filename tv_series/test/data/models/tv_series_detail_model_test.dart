import 'dart:convert';

import 'package:tv_series/data/models/tv_series_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/tv_series_dummy_models.dart';
import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../json_reader.dart';

void main() {
  test('fromJson should read the detail response of TMDB', () {
    final result = TvSeriesDetailResponse.fromJson(
      json.decode(readJson('dummy_data/tv_detail.json')),
    );
    expect(result.id, 1399);
    expect(result.name, 'Game of Thrones');
    expect(result.genres, isNotEmpty);
    expect(result.seasons, hasLength(2));
    expect(result.numberOfSeasons, greaterThan(0));
  });

  test('toJson and fromJson should round trip', () {
    final json = testTvSeriesDetailResponse.toJson();
    expect(json['number_of_seasons'], 8);
    expect(json['seasons'], [testSeasonModel.toJson()]);
    expect(TvSeriesDetailResponse.fromJson(json), testTvSeriesDetailResponse);
  });

  test('toEntity should copy genres and seasons', () {
    expect(testTvSeriesDetailResponse.toEntity(), testTvSeriesDetail);
  });

  test('fromJson should fall back to defaults for missing values', () {
    final result = TvSeriesDetailResponse.fromJson({
      'id': 5,
      'name': null,
      'overview': null,
      'poster_path': null,
      'backdrop_path': null,
      'first_air_date': null,
      'vote_average': null,
      'vote_count': null,
      'number_of_seasons': null,
      'number_of_episodes': null,
      'genres': null,
      'seasons': null,
    });
    expect(result.name, '');
    expect(result.overview, '');
    expect(result.posterPath, isNull);
    expect(result.voteAverage, 0);
    expect(result.voteCount, 0);
    expect(result.numberOfSeasons, 0);
    expect(result.numberOfEpisodes, 0);
    expect(result.genres, isEmpty);
    expect(result.seasons, isEmpty);
  });
}
