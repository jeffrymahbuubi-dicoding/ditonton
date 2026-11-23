import 'package:tv_series/data/models/episode_model.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/tv_series_dummy_models.dart';
import '../../dummy_data/tv_series_dummy_objects.dart';

void main() {
  test('toEntity should copy every field', () {
    expect(testEpisodeModel.toEntity(), testEpisode);
  });

  test('toJson and fromJson should round trip', () {
    final json = testEpisodeModel.toJson();
    expect(json['episode_number'], 1);
    expect(json['still_path'], '/9hGF3WUkBf7cSjMg0cdMDHJkByd.jpg');
    expect(EpisodeModel.fromJson(json), testEpisodeModel);
  });

  test('fromJson should accept null runtime, dates, pictures and rating', () {
    final result = EpisodeModel.fromJson({
      'id': 3,
      'episode_number': 2,
      'season_number': 1,
      'name': null,
      'overview': null,
      'still_path': null,
      'air_date': null,
      'runtime': null,
      'vote_average': null,
    });
    expect(result.name, '');
    expect(result.runtime, isNull);
    expect(result.stillPath, isNull);
    expect(result.airDate, isNull);
    expect(result.voteAverage, 0);
  });

  test('fromJson should convert an integer rating to double', () {
    final result = EpisodeModel.fromJson({
      'id': 3,
      'episode_number': 2,
      'season_number': 1,
      'name': 'x',
      'vote_average': 7,
    });
    expect(result.voteAverage, 7.0);
  });
}
