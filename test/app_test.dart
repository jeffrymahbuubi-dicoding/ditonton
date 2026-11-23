import 'package:core/core.dart';
import 'package:ditonton/injection.dart' as di;
import 'package:ditonton/app.dart';
import 'package:about/about.dart';
import 'package:movie/movie.dart';
import 'package:tv_series/tv_series.dart';
import 'package:ditonton/presentation/pages/watchlist_movies_page.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:material_ui/material_ui.dart';

import 'json_reader.dart';

class _FakeDatabaseHelper extends Fake implements DatabaseHelper {
  @override
  Future<List<Map<String, dynamic>>> getWatchlistMovies() async => [];

  @override
  Future<List<Map<String, dynamic>>> getWatchlistTvSeries() async => [];

  @override
  Future<Map<String, dynamic>?> getMovieById(int id) async => null;

  @override
  Future<Map<String, dynamic>?> getTvSeriesById(int id) async => null;
}

http.Client _fakeClient() {
  return MockClient((request) async {
    final path = request.url.path;
    var body = '{"results": []}';
    if (RegExp(r'/tv/\d+/season/\d+$').hasMatch(path)) {
      body = readJson('dummy_data/tv_season_detail.json');
    } else if (RegExp(r'/tv/\d+$').hasMatch(path)) {
      body = readJson('dummy_data/tv_detail.json');
    } else if (RegExp(r'/movie/\d+$').hasMatch(path)) {
      body = readJson('dummy_data/movie_detail.json');
    }
    return http.Response(
      body,
      200,
      headers: {'content-type': 'application/json; charset=utf-8'},
    );
  });
}

class _RecordingObserver extends NavigatorObserver {
  final pushed = <String?>[];

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    pushed.add(route.settings.name);
  }
}

void main() {
  setUp(() {
    di.init(client: _fakeClient());
    di.locator.allowReassignment = true;
    di.locator.registerLazySingleton<DatabaseHelper>(_FakeDatabaseHelper.new);
  });

  tearDown(() async {
    await di.locator.reset();
  });

  Future<void> pumpApp(WidgetTester tester) async {
    await tester.pumpWidget(MyApp(navigatorObservers: [routeObserver]));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> open(
    WidgetTester tester,
    String name, {
    Object? arguments,
  }) async {
    final navigator = tester.state<NavigatorState>(
      find.byType(Navigator).first,
    );
    navigator.pushNamed(name, arguments: arguments);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
  }

  testWidgets('reports the pushed routes to the given observers', (
    tester,
  ) async {
    final observer = _RecordingObserver();
    await tester.pumpWidget(MyApp(navigatorObservers: [observer]));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    await open(tester, aboutRoute);

    expect(observer.pushed, contains(aboutRoute));
    expect(find.byType(AboutPage), findsOneWidget);
  });

  testWidgets('starts on the movie home page', (tester) async {
    await pumpApp(tester);

    expect(find.byType(HomeMoviePage), findsOneWidget);
  });

  final routes = <String, (String, Object?, Type)>{
    'movie home': ('/home', null, HomeMoviePage),
    'popular movies': (PopularMoviesPage.routeName, null, PopularMoviesPage),
    'top rated movies': (
      TopRatedMoviesPage.routeName,
      null,
      TopRatedMoviesPage,
    ),
    'movie detail': (MovieDetailPage.routeName, 557, MovieDetailPage),
    'movie search': (SearchPage.routeName, null, SearchPage),
    'watchlist': (WatchlistMoviesPage.routeName, null, WatchlistMoviesPage),
    'about': (AboutPage.routeName, null, AboutPage),
    'TV series home': (homeTvSeriesRoute, null, HomeTvSeriesPage),
    'popular TV series': (popularTvSeriesRoute, null, PopularTvSeriesPage),
    'top rated TV series': (topRatedTvSeriesRoute, null, TopRatedTvSeriesPage),
    'now playing TV series': (
      nowPlayingTvSeriesRoute,
      null,
      NowPlayingTvSeriesPage,
    ),
    'TV series search': (tvSeriesSearchRoute, null, TvSeriesSearchPage),
    'TV series detail': (tvSeriesDetailRoute, 1399, TvSeriesDetailPage),
    'season detail': (
      seasonDetailRoute,
      const SeasonDetailArgs(
        tvSeriesId: 1399,
        seasonNumber: 1,
        title: 'Game of Thrones',
      ),
      SeasonDetailPage,
    ),
  };

  routes.forEach((label, route) {
    testWidgets('onGenerateRoute opens the $label page', (tester) async {
      await pumpApp(tester);

      await open(tester, route.$1, arguments: route.$2);

      expect(find.byType(route.$3), findsWidgets);
    });
  });

  testWidgets('onGenerateRoute shows a message for an unknown route', (
    tester,
  ) async {
    await pumpApp(tester);

    await open(tester, '/does-not-exist');

    expect(find.text('Page not found :('), findsOneWidget);
  });
}
