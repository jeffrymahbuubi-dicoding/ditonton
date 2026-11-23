import 'package:tv_series/data/models/episode_model.dart';
import 'package:core/core.dart';
import 'package:tv_series/data/models/season_detail_model.dart';
import 'package:tv_series/data/models/season_model.dart';
import 'package:tv_series/data/models/tv_series_detail_model.dart';
import 'package:tv_series/data/models/tv_series_model.dart';
import 'package:tv_series/data/models/tv_series_table.dart';

const testTvSeriesModel = TvSeriesModel(
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

const testSeasonModel = SeasonModel(
  id: 3624,
  seasonNumber: 1,
  episodeCount: 10,
  name: 'Season 1',
  overview: 'Trouble is brewing in the Seven Kingdoms of Westeros.',
  posterPath: '/wgfKiqzuMrFIkU1M68DDDY8kGC1.jpg',
  airDate: '2011-04-17',
);

const testEpisodeModel = EpisodeModel(
  id: 63056,
  episodeNumber: 1,
  seasonNumber: 1,
  name: 'Winter Is Coming',
  overview: 'Lord Eddard Stark is torn between his family and an old friend.',
  stillPath: '/9hGF3WUkBf7cSjMg0cdMDHJkByd.jpg',
  airDate: '2011-04-17',
  runtime: 62,
  voteAverage: 8.1,
);

const testSeasonDetailResponse = SeasonDetailResponse(
  id: 3624,
  seasonNumber: 1,
  name: 'Season 1',
  episodes: [testEpisodeModel],
);

const testTvSeriesDetailResponse = TvSeriesDetailResponse(
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
  genres: [GenreModel(id: 18, name: 'Drama')],
  seasons: [testSeasonModel],
);

const testTvSeriesTable = TvSeriesTable(
  id: 1399,
  name: 'Game of Thrones',
  posterPath: '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
  overview: 'Seven noble families fight for control of the mythical land of Westeros.',
);

final testTvSeriesMap = {
  'id': 1399,
  'name': 'Game of Thrones',
  'posterPath': '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
  'overview': 'Seven noble families fight for control of the mythical land of Westeros.',
};
