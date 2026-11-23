import 'package:tv_series/tv_series.dart';
import 'package:core/core.dart';

const testTvSeries = TvSeries(
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

final testTvSeriesList = [testTvSeries];

const testSeason = Season(
  id: 3624,
  seasonNumber: 1,
  episodeCount: 10,
  name: 'Season 1',
  overview: 'Trouble is brewing in the Seven Kingdoms of Westeros.',
  posterPath: '/wgfKiqzuMrFIkU1M68DDDY8kGC1.jpg',
  airDate: '2011-04-17',
);

const testEpisode = Episode(
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

const testSeasonDetail = SeasonDetail(
  id: 3624,
  seasonNumber: 1,
  name: 'Season 1',
  episodes: [testEpisode],
);

const testTvSeriesDetail = TvSeriesDetail(
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
  genres: [Genre(id: 18, name: 'Drama')],
  seasons: [testSeason],
);

const testWatchlistTvSeries = TvSeries.watchlist(
  id: 1399,
  name: 'Game of Thrones',
  overview: 'Seven noble families fight for control of the mythical land of Westeros.',
  posterPath: '/1XS1oqL89opfnbLl8WnZY1O1uJx.jpg',
);
