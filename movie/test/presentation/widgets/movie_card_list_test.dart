import 'package:movie/domain/entities/movie.dart';
import 'package:movie/presentation/pages/movie_detail_page.dart';
import 'package:movie/presentation/widgets/movie_card_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../dummy_data/dummy_objects.dart';

void main() {
  Widget makeTestableWidget(Widget body) {
    return MaterialApp(
      home: Scaffold(body: body),
      onGenerateRoute: (settings) {
        if (settings.name == MovieDetailPage.routeName) {
          return MaterialPageRoute(
            builder: (_) => Text('opened ${settings.arguments}'),
          );
        }
        return null;
      },
    );
  }

  testWidgets('MovieCard should show the title and the overview', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(makeTestableWidget(MovieCard(testMovie)));

    expect(find.text('Spider-Man'), findsOneWidget);
    expect(find.textContaining('After being bitten'), findsOneWidget);
  });

  testWidgets('MovieCard should show a dash when title and overview are null', (
    WidgetTester tester,
  ) async {
    final movie = Movie.watchlist(
      id: 2,
      title: null,
      posterPath: null,
      overview: null,
    );

    await tester.pumpWidget(makeTestableWidget(MovieCard(movie)));

    expect(find.text('-'), findsNWidgets(2));
  });

  testWidgets('MovieCard should open the detail route with the movie id', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(makeTestableWidget(MovieCard(testMovie)));

    await tester.tap(find.byType(InkWell));
    await tester.pumpAndSettle();

    expect(find.text('opened 557'), findsOneWidget);
  });
}
