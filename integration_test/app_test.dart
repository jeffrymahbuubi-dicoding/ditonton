import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:ditonton/main.dart' as app;
import 'package:ditonton/presentation/pages/watchlist_movies_page.dart';
import 'package:tv_series/tv_series.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie/movie.dart';

/// Drives the real app against TMDB: one movie flow (search as you type,
/// detail, watchlist), then the TV series home, lists, detail, season,
/// watchlist and search. It leaves the watchlist as it found it. The app
/// starts once, because the service locator is registered once per process.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  /// Pumps in small steps until [finder] matches, or fails after [timeout].
  Future<void> pumpUntilFound(
    WidgetTester tester,
    Finder finder, {
    Duration timeout = const Duration(seconds: 60),
  }) async {
    final end = DateTime.now().add(timeout);
    while (DateTime.now().isBefore(end)) {
      await tester.pump(const Duration(milliseconds: 500));
      if (finder.evaluate().isNotEmpty) {
        return;
      }
    }
    expect(finder, findsWidgets, reason: 'not shown within $timeout');
  }

  Future<void> openDrawer(WidgetTester tester) async {
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pump(const Duration(seconds: 1));
  }

  Future<void> tapAndLoad(WidgetTester tester, Finder finder) async {
    await tester.ensureVisible(finder);
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(finder);
    await tester.pump(const Duration(seconds: 1));
  }

  Finder keyStartsWith(String prefix) => find.byWidgetPredicate((widget) {
    final key = widget.key;
    return key is ValueKey<String> && key.value.startsWith(prefix);
  });

  Finder watchlistIcon(IconData icon) => find.descendant(
    of: find.byKey(const Key('watchlist_button')),
    matching: find.byIcon(icon),
  );

  Future<void> movieFlow(WidgetTester tester) async {
    await pumpUntilFound(tester, find.byType(CachedNetworkImage));

    // Search as you type: the result appears after the debounce.
    await tester.tap(find.byIcon(Icons.search));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(SearchPage));
    await tester.enterText(find.byType(TextField), 'spider');
    await tester.pump(MovieSearchBloc.debounceDuration);
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntilFound(tester, find.byType(MovieCard));

    // Detail of the first result.
    await tester.tap(find.byType(MovieCard).first);
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.text('Overview'));
    await pumpUntilFound(tester, find.text('Recommendations'));

    // Start from a clean state, add to the watchlist, then remove again.
    final button = find.widgetWithText(FilledButton, 'Watchlist');
    Finder movieIcon(IconData icon) =>
        find.descendant(of: button, matching: find.byIcon(icon));
    if (movieIcon(Icons.check).evaluate().isNotEmpty) {
      await tester.tap(button);
      await pumpUntilFound(tester, find.text('Removed from Watchlist'));
    }
    await tester.tap(button);
    await pumpUntilFound(tester, find.text('Added to Watchlist'));
    expect(movieIcon(Icons.check), findsOneWidget);
    await tester.tap(button);
    await pumpUntilFound(tester, find.text('Removed from Watchlist'));
    expect(movieIcon(Icons.add), findsOneWidget);

    // Back to the movies home.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(seconds: 1));
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(HomeMoviePage));
  }

  testWidgets('movie and TV series flows', (tester) async {
    await app.main();
    await tester.pump(const Duration(seconds: 2));

    // Movies home first, then the drawer opens the TV series home.
    await pumpUntilFound(tester, find.text('Now Playing'));
    await movieFlow(tester);
    await openDrawer(tester);
    await tester.tap(find.byKey(const Key('tv_series_drawer_item')));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(HomeTvSeriesPage));

    // The three sections show posters.
    await pumpUntilFound(tester, find.byType(TvSeriesList));
    await pumpUntilFound(tester, find.byType(CachedNetworkImage));
    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
    expect(find.byType(TvSeriesList), findsNWidgets(3));

    // "See More" of the popular list, then its first card.
    await tester.tap(find.byKey(const Key('see_more_popular')));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(PopularTvSeriesPage));
    await pumpUntilFound(tester, find.byType(TvSeriesCard));
    await tester.tap(find.byType(TvSeriesCard).first);
    await tester.pump(const Duration(seconds: 1));

    // Detail: name, overview, seasons and recommendations.
    await pumpUntilFound(tester, find.byType(TvSeriesDetailContent));
    await pumpUntilFound(tester, find.text('Recommendations'));
    final nameFinder = find.byWidgetPredicate(
      (widget) => widget is Text && widget.style == kHeading5,
    );
    final name = tester.widget<Text>(nameFinder.first).data!;
    expect(name, isNotEmpty);
    expect(find.text('Overview'), findsOneWidget);
    expect(find.text('Seasons'), findsOneWidget);
    expect(keyStartsWith('season_item_'), findsWidgets);

    // Start from a clean watchlist state for this series.
    await pumpUntilFound(tester, find.byKey(const Key('watchlist_button')));
    if (watchlistIcon(Icons.check).evaluate().isNotEmpty) {
      await tapAndLoad(tester, find.byKey(const Key('watchlist_button')));
      await tester.pump(const Duration(seconds: 2));
    }
    expect(watchlistIcon(Icons.add), findsOneWidget);

    // Season and its episodes.
    await tapAndLoad(tester, keyStartsWith('season_item_').first);
    await pumpUntilFound(tester, find.byType(SeasonDetailPage));
    await pumpUntilFound(tester, keyStartsWith('episode_item_'));
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(TvSeriesDetailContent));

    // Add to the watchlist.
    await tapAndLoad(tester, find.byKey(const Key('watchlist_button')));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.text('Added to Watchlist'));
    expect(watchlistIcon(Icons.check), findsOneWidget);

    // Back to the TV series home: detail, popular list, home.
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(seconds: 1));
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(HomeTvSeriesPage));

    // Watchlist, TV series tab shows the series.
    await openDrawer(tester);
    await tester.tap(find.byKey(const Key('watchlist_drawer_item')));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(WatchlistMoviesPage));
    await tester.tap(find.byKey(const Key('watchlist_tv_series_tab')));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.text(name));

    // Open it and remove it from the watchlist.
    await tester.tap(find.text(name).first);
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(TvSeriesDetailContent));
    await pumpUntilFound(tester, watchlistIcon(Icons.check));
    await tapAndLoad(tester, find.byKey(const Key('watchlist_button')));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.text('Removed from Watchlist'));
    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump(const Duration(seconds: 1));

    // The watchlist reloads and no longer holds the series.
    await pumpUntilFound(tester, find.byType(WatchlistMoviesPage));
    await tester.pump(const Duration(seconds: 2));
    expect(find.text(name), findsNothing);

    // Search "game".
    await tester.pageBack();
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(HomeTvSeriesPage));
    // The drawer that opened the watchlist is still open: close it by
    // tapping its barrier at the right edge.
    final screen = tester.getSize(find.byType(MaterialApp));
    await tester.tapAt(Offset(screen.width - 4, screen.height / 2));
    await tester.pump(const Duration(seconds: 1));
    await tester.tap(find.byKey(const Key('tv_series_search_button')));
    await tester.pump(const Duration(seconds: 1));
    await pumpUntilFound(tester, find.byType(TvSeriesSearchPage));
    await tester.enterText(
      find.byKey(const Key('tv_series_search_field')),
      'game',
    );
    await tester.pump(TvSeriesSearchBloc.debounceDuration);
    await tester.pump(const Duration(milliseconds: 500));
    await pumpUntilFound(tester, find.byType(TvSeriesCard));
    expect(find.byType(TvSeriesCard), findsWidgets);
  });
}
