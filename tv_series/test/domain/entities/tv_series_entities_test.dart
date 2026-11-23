import 'package:tv_series/domain/entities/episode.dart';
import 'package:tv_series/domain/entities/season.dart';
import 'package:tv_series/domain/entities/season_detail.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';

void main() {
  group('TvSeries', () {
    test('is equal when every field is equal', () {
      const other = TvSeries(
        id: 1399,
        name: 'Game of Thrones',
        overview: 'Seven noble families fight for control of the mythical land of Westeros.',
        posterPath: '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
        backdropPath: '/2OMB0ynKlyIenMJWI2Dy9IWT4c.jpg',
        voteAverage: 8.4,
        voteCount: 25000,
        firstAirDate: '2011-04-17',
        genreIds: [10765, 18],
      );
      expect(other, testTvSeries);
    });

    test('differs when one field differs', () {
      const other = TvSeries.watchlist(
        id: 1,
        name: 'Game of Thrones',
        overview: 'o',
        posterPath: '/p.jpg',
      );
      expect(other, isNot(testTvSeries));
    });

    test('the watchlist constructor leaves the other fields null', () {
      expect(testWatchlistTvSeries.id, 1399);
      expect(testWatchlistTvSeries.backdropPath, isNull);
      expect(testWatchlistTvSeries.voteAverage, isNull);
      expect(testWatchlistTvSeries.voteCount, isNull);
      expect(testWatchlistTvSeries.firstAirDate, isNull);
      expect(testWatchlistTvSeries.genreIds, isNull);
    });
  });

  group('TvSeriesDetail', () {
    test('is equal to a copy with the same fields', () {
      final other = TvSeriesDetail(
        id: testTvSeriesDetail.id,
        name: testTvSeriesDetail.name,
        overview: testTvSeriesDetail.overview,
        posterPath: testTvSeriesDetail.posterPath,
        backdropPath: testTvSeriesDetail.backdropPath,
        firstAirDate: testTvSeriesDetail.firstAirDate,
        voteAverage: testTvSeriesDetail.voteAverage,
        voteCount: testTvSeriesDetail.voteCount,
        numberOfSeasons: testTvSeriesDetail.numberOfSeasons,
        numberOfEpisodes: testTvSeriesDetail.numberOfEpisodes,
        genres: testTvSeriesDetail.genres,
        seasons: testTvSeriesDetail.seasons,
      );
      expect(other, testTvSeriesDetail);
    });

    test('differs when the seasons differ', () {
      const other = TvSeriesDetail(
        id: 1399,
        name: 'Game of Thrones',
        overview: 'Seven noble families fight for control of the mythical land of Westeros.',
        posterPath: '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
        backdropPath: '/2OMB0ynKlyIenMJWI2Dy9IWT4c.jpg',
        firstAirDate: '2011-04-17',
        voteAverage: 8.4,
        voteCount: 25000,
        numberOfSeasons: 8,
        numberOfEpisodes: 73,
        genres: [],
        seasons: [],
      );
      expect(other, isNot(testTvSeriesDetail));
    });
  });

  group('Season', () {
    test('is equal to a copy and differs by number', () {
      const copy = Season(
        id: 3624,
        seasonNumber: 1,
        episodeCount: 10,
        name: 'Season 1',
        overview: 'Trouble is brewing in the Seven Kingdoms of Westeros.',
        posterPath: '/wgfKiqzuMrFIkU1M68DDDY8kGC1.jpg',
        airDate: '2011-04-17',
      );
      const other = Season(
        id: 3624,
        seasonNumber: 2,
        episodeCount: 10,
        name: 'Season 1',
        overview: null,
        posterPath: null,
        airDate: null,
      );
      expect(copy, testSeason);
      expect(other, isNot(testSeason));
    });
  });

  group('Episode', () {
    test('is equal to a copy and differs by runtime', () {
      const copy = Episode(
        id: 63056,
        episodeNumber: 1,
        seasonNumber: 1,
        name: 'Winter Is Coming',
        overview:
            'Lord Eddard Stark is torn between his family and an old friend.',
        stillPath: '/9hGF3WUkBf7cSjMg0cdMDHJkByd.jpg',
        airDate: '2011-04-17',
        runtime: 62,
        voteAverage: 8.1,
      );
      const other = Episode(
        id: 63056,
        episodeNumber: 1,
        seasonNumber: 1,
        name: 'Winter Is Coming',
        overview: null,
        stillPath: null,
        airDate: null,
        runtime: null,
        voteAverage: 8.1,
      );
      expect(copy, testEpisode);
      expect(other, isNot(testEpisode));
    });
  });

  group('SeasonDetail', () {
    test('is equal to a copy and differs by episodes', () {
      const copy = SeasonDetail(
        id: 3624,
        seasonNumber: 1,
        name: 'Season 1',
        episodes: [testEpisode],
      );
      const other = SeasonDetail(
        id: 3624,
        seasonNumber: 1,
        name: 'Season 1',
        episodes: [],
      );
      expect(copy, testSeasonDetail);
      expect(other, isNot(testSeasonDetail));
    });
  });
}
