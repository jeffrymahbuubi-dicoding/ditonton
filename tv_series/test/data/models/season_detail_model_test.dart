import 'dart:convert';

import 'package:tv_series/data/models/season_detail_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/tv_series_dummy_models.dart';
import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../json_reader.dart';

void main() {
  test('fromJson should read the season response of TMDB', () {
    final result = SeasonDetailResponse.fromJson(
      json.decode(readJson('dummy_data/tv_season_detail.json')),
    );
    expect(result.seasonNumber, 1);
    expect(result.episodes, hasLength(3));
    expect(result.episodes.first.name, 'Winter Is Coming');
  });

  test('toJson and fromJson should round trip', () {
    final json = testSeasonDetailResponse.toJson();
    expect(json['episodes'], [testEpisodeModel.toJson()]);
    expect(SeasonDetailResponse.fromJson(json), testSeasonDetailResponse);
  });

  test('toEntity should copy the episodes', () {
    expect(testSeasonDetailResponse.toEntity(), testSeasonDetail);
  });

  test('fromJson should use defaults when name and episodes are missing', () {
    final result = SeasonDetailResponse.fromJson({
      'id': 1,
      'season_number': 3,
      'name': null,
      'episodes': null,
    });
    expect(result.name, '');
    expect(result.episodes, isEmpty);
  });
}
