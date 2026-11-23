import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:ditonton/presentation/pages/watchlist_movies_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/movie.dart';
import 'package:tv_series/tv_series.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../dummy_data/tv_series_dummy_objects.dart';
import 'watchlist_movies_page_test.mocks.dart';

@GenerateMocks([GetWatchlistMovies, GetWatchlistTvSeries])
void main() {
  late MockGetWatchlistMovies mockMovies;
  late MockGetWatchlistTvSeries mockTvSeries;

  setUp(() {
    mockMovies = MockGetWatchlistMovies();
    mockTvSeries = MockGetWatchlistTvSeries();
    when(mockTvSeries.execute())
        .thenAnswer((_) async => const Right([testWatchlistTvSeries]));
  });

  Widget makeTestableWidget() {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => WatchlistMoviesBloc(mockMovies)),
        BlocProvider(create: (_) => WatchlistTvSeriesBloc(mockTvSeries)),
      ],
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        home: const WatchlistMoviesPage(),
      ),
    );
  }

  testWidgets('Page should fetch the movie watchlist and show two tabs', (
    tester,
  ) async {
    when(mockMovies.execute())
        .thenAnswer((_) async => Right([testWatchlistMovie]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    verify(mockMovies.execute()).called(1);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.byKey(const Key('watchlist_tv_series_tab')), findsOneWidget);
  });

  testWidgets('Movies tab should display progress bar while loading', (
    tester,
  ) async {
    final pending = Completer<Either<Failure, List<Movie>>>();
    when(mockMovies.execute()).thenAnswer((_) => pending.future);

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(mockMovies.execute()).called(1);
  });

  testWidgets('Movies tab should display the saved movies', (tester) async {
    when(mockMovies.execute())
        .thenAnswer((_) async => Right([testWatchlistMovie]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byType(MovieCard), findsOneWidget);
    verify(mockMovies.execute()).called(1);
  });

  testWidgets('Movies tab should display the message when failed', (
    tester,
  ) async {
    when(mockMovies.execute())
        .thenAnswer((_) async => const Left(DatabaseFailure("Can't get data")));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text("Can't get data"), findsOneWidget);
    verify(mockMovies.execute()).called(1);
  });

  testWidgets('TV Series tab should display the saved series', (tester) async {
    when(mockMovies.execute())
        .thenAnswer((_) async => Right([testWatchlistMovie]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.tap(find.byKey(const Key('watchlist_tv_series_tab')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    await tester.pump();

    verify(mockTvSeries.execute()).called(1);
    expect(find.byType(TvSeriesCard), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
  });

  testWidgets('Page should reload the movies when it is shown again', (
    tester,
  ) async {
    when(mockMovies.execute()).thenAnswer((_) async => const Right([]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();
    verify(mockMovies.execute()).called(1);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute(builder: (_) => const Text('other')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    navigator.pop();
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    verify(mockMovies.execute()).called(1);
  });
}
