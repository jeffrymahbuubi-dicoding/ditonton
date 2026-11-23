import 'dart:convert';

import 'package:core/core.dart';
import 'package:movie/data/models/movie_detail_model.dart';
import 'package:movie/domain/entities/movie_detail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../json_reader.dart';

void main() {
  const tResponse = MovieDetailResponse(
    adult: false,
    backdropPath: '/path.jpg',
    budget: 100,
    genres: [GenreModel(id: 1, name: 'Action')],
    homepage: 'https://google.com',
    id: 1,
    imdbId: 'imdb1',
    originalLanguage: 'en',
    originalTitle: 'Original Title',
    overview: 'Overview',
    popularity: 1,
    posterPath: '/path.jpg',
    releaseDate: '2020-05-05',
    revenue: 12000,
    runtime: 120,
    status: 'Status',
    tagline: 'Tagline',
    title: 'Title',
    video: false,
    voteAverage: 1,
    voteCount: 1,
  );

  final tJson = json.decode(
    readJson('dummy_data/movie_detail.json'),
  ) as Map<String, dynamic>;

  test('fromJson should read every field of the detail JSON', () {
    expect(MovieDetailResponse.fromJson(tJson), tResponse);
  });

  test('toJson should write the fields back with the API keys', () {
    final result = tResponse.toJson();
    expect(result['backdrop_path'], '/path.jpg');
    expect(result['imdb_id'], 'imdb1');
    expect(result['vote_count'], 1);
    expect(result['genres'], [
      {'id': 1, 'name': 'Action'},
    ]);
    expect(MovieDetailResponse.fromJson(result), tResponse);
  });

  test('toEntity should return a MovieDetail', () {
    const expected = MovieDetail(
      adult: false,
      backdropPath: '/path.jpg',
      genres: [Genre(id: 1, name: 'Action')],
      id: 1,
      originalTitle: 'Original Title',
      overview: 'Overview',
      posterPath: '/path.jpg',
      releaseDate: '2020-05-05',
      runtime: 120,
      title: 'Title',
      voteAverage: 1,
      voteCount: 1,
    );
    expect(tResponse.toEntity(), expected);
  });
}
