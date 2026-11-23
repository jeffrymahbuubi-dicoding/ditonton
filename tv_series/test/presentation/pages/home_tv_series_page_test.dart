import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/now_playing_tv_series/now_playing_tv_series_bloc.dart';
import 'package:tv_series/presentation/bloc/popular_tv_series/popular_tv_series_bloc.dart';
import 'package:tv_series/presentation/bloc/top_rated_tv_series/top_rated_tv_series_bloc.dart';
import 'package:tv_series/presentation/pages/home_tv_series_page.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetNowPlayingTvSeries mockNowPlaying;
  late MockGetPopularTvSeries mockPopular;
  late MockGetTopRatedTvSeries mockTopRated;
  late List<RouteSettings> opened;

  setUp(() {
    mockNowPlaying = MockGetNowPlayingTvSeries();
    mockPopular = MockGetPopularTvSeries();
    mockTopRated = MockGetTopRatedTvSeries();
    opened = [];
  });

  void stubAll(Either<Failure, List<TvSeries>> result) {
    when(mockNowPlaying.execute()).thenAnswer((_) async => result);
    when(mockPopular.execute()).thenAnswer((_) async => result);
    when(mockTopRated.execute()).thenAnswer((_) async => result);
  }

  void verifyFetched() {
    verify(mockNowPlaying.execute()).called(1);
    verify(mockPopular.execute()).called(1);
    verify(mockTopRated.execute()).called(1);
  }

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NowPlayingTvSeriesBloc(mockNowPlaying)),
          BlocProvider(create: (_) => PopularTvSeriesBloc(mockPopular)),
          BlocProvider(create: (_) => TopRatedTvSeriesBloc(mockTopRated)),
        ],
        child: MaterialApp(
          home: const HomeTvSeriesPage(),
          onGenerateRoute: (settings) {
            opened.add(settings);
            return MaterialPageRoute(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('opened')),
            );
          },
        ),
      ),
    );
  }

  test('should use the frozen route name', () {
    expect(HomeTvSeriesPage.routeName, homeTvSeriesRoute);
  });

  testWidgets('fetches the three lists when the page opens', (tester) async {
    stubAll(Right(testTvSeriesList));

    await pumpPage(tester);
    await tester.pump();

    verifyFetched();
  });

  testWidgets('shows the three headings and a progress bar per list', (
    tester,
  ) async {
    final pending = Completer<Either<Failure, List<TvSeries>>>();
    when(mockNowPlaying.execute()).thenAnswer((_) => pending.future);
    when(mockPopular.execute()).thenAnswer((_) => pending.future);
    when(mockTopRated.execute()).thenAnswer((_) => pending.future);

    await pumpPage(tester);
    await tester.pump();

    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(3));
    verifyFetched();
  });

  testWidgets('shows a poster list per section when loaded', (tester) async {
    stubAll(Right(testTvSeriesList));

    await pumpPage(tester);
    await tester.pump();

    expect(find.byType(TvSeriesList), findsNWidgets(3));
    verifyFetched();
  });

  testWidgets('shows a text per section when the lists are empty', (
    tester,
  ) async {
    stubAll(const Right(<TvSeries>[]));

    await pumpPage(tester);
    await tester.pump();

    expect(find.text('No TV series found'), findsNWidgets(3));
    expect(find.byType(TvSeriesList), findsNothing);
    verifyFetched();
  });

  testWidgets('shows the failure message of each section', (tester) async {
    when(
      mockNowPlaying.execute(),
    ).thenAnswer((_) async => const Left(ServerFailure('Now playing failed')));
    when(mockPopular.execute())
        .thenAnswer((_) async => const Left(ServerFailure('Popular failed')));
    when(mockTopRated.execute())
        .thenAnswer((_) async => const Left(ServerFailure('Top rated failed')));

    await pumpPage(tester);
    await tester.pump();

    expect(find.text('Now playing failed'), findsOneWidget);
    expect(find.text('Popular failed'), findsOneWidget);
    expect(find.text('Top rated failed'), findsOneWidget);
    verifyFetched();
  });

  for (final entry in {
    'see_more_now_playing': nowPlayingTvSeriesRoute,
    'see_more_popular': popularTvSeriesRoute,
    'see_more_top_rated': topRatedTvSeriesRoute,
  }.entries) {
    testWidgets('See More ${entry.key} opens ${entry.value}', (tester) async {
      final pending = Completer<Either<Failure, List<TvSeries>>>();
      when(mockNowPlaying.execute()).thenAnswer((_) => pending.future);
      when(mockPopular.execute()).thenAnswer((_) => pending.future);
      when(mockTopRated.execute()).thenAnswer((_) => pending.future);

      await pumpPage(tester);
      await tester.tap(find.byKey(Key(entry.key)));
      await tester.pump(const Duration(seconds: 1));

      expect(opened.last.name, entry.value);
      verifyFetched();
    });
  }

  testWidgets('the search button opens the search route', (tester) async {
    final pending = Completer<Either<Failure, List<TvSeries>>>();
    when(mockNowPlaying.execute()).thenAnswer((_) => pending.future);
    when(mockPopular.execute()).thenAnswer((_) => pending.future);
    when(mockTopRated.execute()).thenAnswer((_) => pending.future);

    await pumpPage(tester);
    await tester.tap(find.byKey(const Key('tv_series_search_button')));
    await tester.pump(const Duration(seconds: 1));

    expect(opened.last.name, tvSeriesSearchRoute);
    verifyFetched();
  });

  testWidgets('tapping a poster opens the detail route with the id', (
    tester,
  ) async {
    stubAll(Right(testTvSeriesList));

    await pumpPage(tester);
    await tester.pump();
    await tester.tap(
      find
          .descendant(
            of: find.byType(TvSeriesList).first,
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pump(const Duration(seconds: 1));

    expect(opened.last.name, tvSeriesDetailRoute);
    expect(opened.last.arguments, testTvSeries.id);
    verifyFetched();
  });

  testWidgets('the drawer marks TV Series as the current page', (tester) async {
    stubAll(const Right(<TvSeries>[]));

    await pumpPage(tester);
    await tester.pump();
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('tv_series_drawer_item')));
    await tester.pumpAndSettle();

    expect(opened, isEmpty);
    expect(find.byKey(const Key('tv_series_drawer_item')), findsNothing);
    verifyFetched();
  });
}
