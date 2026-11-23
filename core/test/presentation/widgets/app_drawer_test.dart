import 'package:core/utils/routes.dart';
import 'package:core/presentation/widgets/app_drawer.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

void main() {
  late List<RouteSettings> opened;

  setUp(() {
    opened = [];
  });

  Future<void> pumpDrawer(WidgetTester tester, String currentRoute) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(drawer: AppDrawer(currentRoute: currentRoute)),
        onGenerateRoute: (settings) {
          opened.add(settings);
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(body: Text('opened')),
          );
        },
      ),
    );
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
  }

  testWidgets('lists the four entries', (tester) async {
    await pumpDrawer(tester, AppDrawer.moviesRoute);

    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('TV Series'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    expect(find.byKey(const Key('tv_series_drawer_item')), findsOneWidget);
    expect(find.byKey(const Key('watchlist_drawer_item')), findsOneWidget);
  });

  testWidgets('the entry of the current page only closes the drawer', (
    tester,
  ) async {
    await pumpDrawer(tester, AppDrawer.moviesRoute);

    await tester.tap(find.byKey(const Key('movies_drawer_item')));
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(find.byType(AppDrawer), findsNothing);
  });

  testWidgets('TV Series replaces the movie home', (tester) async {
    await pumpDrawer(tester, AppDrawer.moviesRoute);

    await tester.tap(find.byKey(const Key('tv_series_drawer_item')));
    await tester.pumpAndSettle();

    expect(opened.last.name, homeTvSeriesRoute);
    expect(find.text('opened'), findsOneWidget);
    expect(find.byType(AppDrawer), findsNothing);
  });

  testWidgets('Movies replaces the TV series home', (tester) async {
    await pumpDrawer(tester, homeTvSeriesRoute);

    await tester.tap(find.byKey(const Key('movies_drawer_item')));
    await tester.pumpAndSettle();

    expect(opened.last.name, AppDrawer.moviesRoute);
  });

  testWidgets('Watchlist opens the watchlist route', (tester) async {
    await pumpDrawer(tester, AppDrawer.moviesRoute);

    await tester.tap(find.byKey(const Key('watchlist_drawer_item')));
    await tester.pumpAndSettle();

    expect(opened.last.name, watchlistRoute);
  });

  testWidgets('About opens the about route', (tester) async {
    await pumpDrawer(tester, AppDrawer.moviesRoute);

    await tester.tap(find.byKey(const Key('about_drawer_item')));
    await tester.pumpAndSettle();

    expect(opened.last.name, aboutRoute);
  });
}
