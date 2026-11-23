import 'package:core/utils/routes.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the movie route names are the frozen strings', () {
    expect(homeMoviesRoute, '/home');
    expect(popularMoviesRoute, '/popular-movie');
    expect(topRatedMoviesRoute, '/top-rated-movie');
    expect(movieDetailRoute, '/detail');
    expect(searchMoviesRoute, '/search');
    expect(watchlistRoute, '/watchlist-movie');
    expect(aboutRoute, '/about');
  });

  test('the TV series route names are the frozen strings', () {
    expect(homeTvSeriesRoute, '/tv-series');
    expect(popularTvSeriesRoute, '/popular-tv-series');
    expect(topRatedTvSeriesRoute, '/top-rated-tv-series');
    expect(nowPlayingTvSeriesRoute, '/now-playing-tv-series');
    expect(tvSeriesDetailRoute, '/tv-series-detail');
    expect(tvSeriesSearchRoute, '/search-tv-series');
    expect(seasonDetailRoute, '/season-detail');
  });
}
