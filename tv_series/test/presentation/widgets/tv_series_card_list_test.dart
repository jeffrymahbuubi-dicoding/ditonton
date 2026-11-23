import 'package:core/core.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';

void main() {
  Widget makeApp({void Function(RouteSettings)? onRoute}) {
    return MaterialApp(
      home: const Scaffold(body: TvSeriesCard(testTvSeries)),
      onGenerateRoute: (settings) {
        onRoute?.call(settings);
        return MaterialPageRoute(
          settings: settings,
          builder: (_) => const Scaffold(body: Text('opened')),
        );
      },
    );
  }

  testWidgets('shows the name and the overview', (tester) async {
    await tester.pumpWidget(makeApp());

    expect(find.text('Game of Thrones'), findsOneWidget);
    expect(
      find.text(
        'Seven noble families fight for control of the mythical land of Westeros.',
      ),
      findsOneWidget,
    );
  });

  testWidgets('shows dashes when name and overview are missing', (
    tester,
  ) async {
    const empty = TvSeries.watchlist(
      id: 1,
      name: null,
      overview: null,
      posterPath: null,
    );
    await tester.pumpWidget(
      const MaterialApp(home: Scaffold(body: TvSeriesCard(empty))),
    );

    expect(find.text('-'), findsNWidgets(2));
  });

  testWidgets('a tap opens the detail route with the id', (tester) async {
    RouteSettings? pushed;
    await tester.pumpWidget(
      makeApp(
        onRoute: (settings) {
          pushed = settings;
        },
      ),
    );

    await tester.tap(find.byType(TvSeriesCard));
    await tester.pump();

    expect(pushed?.name, tvSeriesDetailRoute);
    expect(pushed?.arguments, 1399);
  });
}
