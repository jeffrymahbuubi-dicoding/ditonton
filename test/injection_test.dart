import 'package:core/core.dart';
import 'package:ditonton/injection.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:movie/movie.dart';
import 'package:tv_series/tv_series.dart';

void main() {
  late http.Client client;

  setUp(() {
    client = MockClient((_) async => http.Response('{}', 200));
    init(client: client);
  });

  tearDown(() async {
    await locator.reset();
  });

  group('init', () {
    test('resolves every movie Bloc', () {
      expect(locator<NowPlayingMoviesBloc>(), isA<NowPlayingMoviesBloc>());
      expect(locator<PopularMoviesBloc>(), isA<PopularMoviesBloc>());
      expect(locator<TopRatedMoviesBloc>(), isA<TopRatedMoviesBloc>());
      expect(locator<MovieDetailBloc>(), isA<MovieDetailBloc>());
      expect(
        locator<MovieRecommendationsBloc>(),
        isA<MovieRecommendationsBloc>(),
      );
      expect(
        locator<MovieWatchlistStatusBloc>(),
        isA<MovieWatchlistStatusBloc>(),
      );
      expect(locator<WatchlistMoviesBloc>(), isA<WatchlistMoviesBloc>());
      expect(locator<MovieSearchBloc>(), isA<MovieSearchBloc>());
    });

    test('resolves every TV series Bloc', () {
      expect(locator<NowPlayingTvSeriesBloc>(), isA<NowPlayingTvSeriesBloc>());
      expect(locator<PopularTvSeriesBloc>(), isA<PopularTvSeriesBloc>());
      expect(locator<TopRatedTvSeriesBloc>(), isA<TopRatedTvSeriesBloc>());
      expect(locator<TvSeriesDetailBloc>(), isA<TvSeriesDetailBloc>());
      expect(
        locator<TvSeriesRecommendationsBloc>(),
        isA<TvSeriesRecommendationsBloc>(),
      );
      expect(locator<SeasonDetailBloc>(), isA<SeasonDetailBloc>());
      expect(
        locator<TvSeriesWatchlistStatusBloc>(),
        isA<TvSeriesWatchlistStatusBloc>(),
      );
      expect(locator<WatchlistTvSeriesBloc>(), isA<WatchlistTvSeriesBloc>());
      expect(locator<TvSeriesSearchBloc>(), isA<TvSeriesSearchBloc>());
    });

    test('creates a new Bloc on every request', () {
      expect(
        identical(locator<TvSeriesDetailBloc>(), locator<TvSeriesDetailBloc>()),
        isFalse,
      );
      expect(
        identical(locator<MovieDetailBloc>(), locator<MovieDetailBloc>()),
        isFalse,
      );
    });

    test('resolves some use cases', () {
      expect(locator<GetNowPlayingTvSeries>(), isA<GetNowPlayingTvSeries>());
      expect(locator<GetTvSeriesDetail>(), isA<GetTvSeriesDetail>());
      expect(locator<GetSeasonDetail>(), isA<GetSeasonDetail>());
      expect(locator<GetWatchlistTvSeries>(), isA<GetWatchlistTvSeries>());
      expect(locator<SearchMovies>(), isA<SearchMovies>());
    });

    test('resolves the repositories and data sources', () {
      expect(locator<MovieRepository>(), isA<MovieRepository>());
      expect(locator<TvSeriesRepository>(), isA<TvSeriesRepository>());
      expect(locator<MovieRemoteDataSource>(), isA<MovieRemoteDataSource>());
      expect(locator<MovieLocalDataSource>(), isA<MovieLocalDataSource>());
      expect(
        locator<TvSeriesRemoteDataSource>(),
        isA<TvSeriesRemoteDataSource>(),
      );
      expect(
        locator<TvSeriesLocalDataSource>(),
        isA<TvSeriesLocalDataSource>(),
      );
    });

    test('shares one database helper and the client that was passed in', () {
      expect(locator<DatabaseHelper>(), same(locator<DatabaseHelper>()));
      expect(locator<http.Client>(), same(client));
    });

    test('shares one TV series repository', () {
      expect(
        locator<TvSeriesRepository>(),
        same(locator<TvSeriesRepository>()),
      );
    });
  });
}
