import 'package:tv_series/data/models/season_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/tv_series_dummy_models.dart';
import '../../dummy_data/tv_series_dummy_objects.dart';

void main() {
  test('toEntity should copy every field', () {
    expect(testSeasonModel.toEntity(), testSeason);
  });

  test('toJson and fromJson should round trip', () {
    final json = testSeasonModel.toJson();
    expect(json['season_number'], 1);
    expect(json['episode_count'], 10);
    expect(SeasonModel.fromJson(json), testSeasonModel);
  });

  test('fromJson should accept null text, dates and counts', () {
    final result = SeasonModel.fromJson({
      'id': 9,
      'season_number': 0,
      'episode_count': null,
      'name': null,
      'overview': null,
      'poster_path': null,
      'air_date': null,
    });
    expect(result.name, '');
    expect(result.episodeCount, 0);
    expect(result.airDate, isNull);
    expect(result.posterPath, isNull);
  });
}
