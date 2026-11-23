import 'dart:convert';

import 'package:tv_series/data/models/tv_series_model.dart';
import 'package:tv_series/data/models/tv_series_response.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/tv_series_dummy_models.dart';
import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../json_reader.dart';

void main() {
  group('TvSeriesModel', () {
    test('toEntity should copy every field', () {
      expect(testTvSeriesModel.toEntity(), testTvSeries);
    });

    test('toJson and fromJson should round trip', () {
      final json = testTvSeriesModel.toJson();
      expect(json['poster_path'], testTvSeriesModel.posterPath);
      expect(json['first_air_date'], '2011-04-17');
      expect(TvSeriesModel.fromJson(json), testTvSeriesModel);
    });

    test('fromJson should accept null fields and an integer rating', () {
      final model = TvSeriesModel.fromJson({
        'id': 7,
        'name': null,
        'overview': null,
        'poster_path': null,
        'backdrop_path': null,
        'vote_average': 8,
        'vote_count': null,
        'first_air_date': null,
        'genre_ids': null,
      });
      expect(model.id, 7);
      expect(model.name, isNull);
      expect(model.posterPath, isNull);
      expect(model.voteAverage, 8.0);
      expect(model.genreIds, isNull);
      expect(model.toEntity().firstAirDate, isNull);
    });

    test('models with different ids should not be equal', () {
      final other = TvSeriesModel.fromJson({'id': 1, 'poster_path': 'x'});
      expect(other, isNot(testTvSeriesModel));
    });
  });

  group('TvSeriesResponse', () {
    test('fromJson should read the results of a popular response', () {
      final response = TvSeriesResponse.fromJson(
        json.decode(readJson('dummy_data/tv_popular.json')),
      );
      expect(response.tvSeriesList, hasLength(3));
      expect(response.tvSeriesList.first.name, isNotEmpty);
      expect(response.tvSeriesList.every((m) => m.posterPath != null), isTrue);
    });

    test('fromJson should leave out a series without a poster', () {
      final response = TvSeriesResponse.fromJson({
        'results': [
          {'id': 1, 'poster_path': null},
          {'id': 2, 'poster_path': '/a.jpg'},
        ],
      });
      expect(response.tvSeriesList.map((m) => m.id), [2]);
    });

    test('toJson should write the list under results', () {
      const response = TvSeriesResponse(tvSeriesList: [testTvSeriesModel]);
      expect(response.toJson(), {
        'results': [testTvSeriesModel.toJson()],
      });
      expect(TvSeriesResponse.fromJson(response.toJson()), response);
    });
  });
}
