import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/season.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:tv_series/presentation/bloc/tv_series_detail/tv_series_detail_bloc.dart';
import 'package:tv_series/presentation/bloc/tv_series_recommendations/tv_series_recommendations_bloc.dart';
import 'package:tv_series/presentation/bloc/tv_series_watchlist_status/tv_series_watchlist_status_bloc.dart';
import 'package:tv_series/presentation/pages/season_detail_args.dart';
import 'package:tv_series/presentation/pages/tv_series_detail_page.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetTvSeriesDetail mockDetail;
  late MockGetTvSeriesRecommendations mockRecommendations;
  late MockGetWatchlistTvSeriesStatus mockStatus;
  late MockSaveWatchlistTvSeries mockSave;
  late MockRemoveWatchlistTvSeries mockRemove;

  const emptyDetail = TvSeriesDetail(
    id: 1,
    name: 'Name',
    overview: 'Overview',
    posterPath: null,
    backdropPath: null,
    firstAirDate: null,
    voteAverage: 7,
    voteCount: 1,
    numberOfSeasons: 0,
    numberOfEpisodes: 0,
    genres: [],
    seasons: [],
  );

  setUp(() {
    mockDetail = MockGetTvSeriesDetail();
    mockRecommendations = MockGetTvSeriesRecommendations();
    mockStatus = MockGetWatchlistTvSeriesStatus();
    mockSave = MockSaveWatchlistTvSeries();
    mockRemove = MockRemoveWatchlistTvSeries();
  });

  Widget makeTestableWidget(Widget body, {RouteFactory? onGenerateRoute}) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => TvSeriesDetailBloc(mockDetail)),
        BlocProvider(
          create: (_) => TvSeriesRecommendationsBloc(mockRecommendations),
        ),
        BlocProvider(
          create: (_) =>
              TvSeriesWatchlistStatusBloc(mockStatus, mockSave, mockRemove),
        ),
      ],
      child: MaterialApp(home: body, onGenerateRoute: onGenerateRoute),
    );
  }

  void arrangeLoaded({
    TvSeriesDetail detail = testTvSeriesDetail,
    bool inWatchlist = false,
    Either<Failure, List<TvSeries>> recommendations = const Right(<TvSeries>[]),
  }) {
    when(mockDetail.execute(detail.id)).thenAnswer((_) async => Right(detail));
    when(mockRecommendations.execute(detail.id))
        .thenAnswer((_) async => recommendations);
    when(mockStatus.execute(detail.id)).thenAnswer((_) async => inWatchlist);
  }

  Future<void> pumpDetail(
    WidgetTester tester,
    int id, {
    RouteFactory? onGenerateRoute,
  }) async {
    await tester.pumpWidget(
      makeTestableWidget(
        TvSeriesDetailPage(id: id),
        onGenerateRoute: onGenerateRoute,
      ),
    );
    await tester.pump();
  }

  testWidgets('Page should load the detail, recommendations and status', (
    tester,
  ) async {
    arrangeLoaded();

    await pumpDetail(tester, 1399);

    verify(mockDetail.execute(1399)).called(1);
    verify(mockRecommendations.execute(1399)).called(1);
    verify(mockStatus.execute(1399)).called(1);
  });

  testWidgets('Page should display name, overview, rating and genres', (
    tester,
  ) async {
    arrangeLoaded();

    await pumpDetail(tester, 1399);

    expect(find.text('Game of Thrones'), findsOneWidget);
    expect(find.text(testTvSeriesDetail.overview), findsOneWidget);
    expect(find.text('8.4'), findsOneWidget);
    expect(find.text('Drama'), findsOneWidget);
    expect(find.text('8 seasons, 73 episodes'), findsOneWidget);
    verify(mockDetail.execute(1399)).called(1);
  });

  testWidgets('Page should join several genres with a comma', (tester) async {
    arrangeLoaded(
      detail: const TvSeriesDetail(
        id: 1,
        name: 'Name',
        overview: 'Overview',
        posterPath: null,
        backdropPath: null,
        firstAirDate: null,
        voteAverage: 7,
        voteCount: 1,
        numberOfSeasons: 1,
        numberOfEpisodes: 1,
        genres: [
          Genre(id: 1, name: 'Action'),
          Genre(id: 2, name: 'Drama'),
        ],
        seasons: [],
      ),
    );

    await pumpDetail(tester, 1);

    expect(find.text('Action, Drama'), findsOneWidget);
    expect(find.byIcon(Icons.image_not_supported), findsOneWidget);
    verify(mockDetail.execute(1)).called(1);
  });

  testWidgets('Page should display progress bar while loading', (tester) async {
    final pending = Completer<Either<Failure, TvSeriesDetail>>();
    when(mockDetail.execute(1399)).thenAnswer((_) => pending.future);
    when(mockRecommendations.execute(1399))
        .thenAnswer((_) async => const Right(<TvSeries>[]));
    when(mockStatus.execute(1399)).thenAnswer((_) async => false);

    await pumpDetail(tester, 1399);

    expect(find.byType(CircularProgressIndicator), findsWidgets);
    expect(find.text('Game of Thrones'), findsNothing);
    verify(mockDetail.execute(1399)).called(1);
  });

  testWidgets('Page should display the message when loading failed', (
    tester,
  ) async {
    when(mockDetail.execute(1399))
        .thenAnswer((_) async => const Left(ServerFailure('Failed to load')));
    when(mockRecommendations.execute(1399))
        .thenAnswer((_) async => const Right(<TvSeries>[]));
    when(mockStatus.execute(1399)).thenAnswer((_) async => false);

    await pumpDetail(tester, 1399);

    expect(find.text('Failed to load'), findsOneWidget);
    verify(mockDetail.execute(1399)).called(1);
  });

  testWidgets('Watchlist button should display add icon when not added', (
    tester,
  ) async {
    arrangeLoaded();

    await pumpDetail(tester, 1399);

    expect(find.byIcon(Icons.add), findsOneWidget);
    expect(find.byIcon(Icons.check), findsNothing);
    verify(mockStatus.execute(1399)).called(1);
  });

  testWidgets('Watchlist button should display check icon when added', (
    tester,
  ) async {
    arrangeLoaded(inWatchlist: true);

    await pumpDetail(tester, 1399);

    expect(find.byIcon(Icons.check), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);
    verify(mockStatus.execute(1399)).called(1);
  });

  testWidgets('Watchlist button should display Snackbar when added', (
    tester,
  ) async {
    arrangeLoaded();
    when(mockSave.execute(testTvSeriesDetail))
        .thenAnswer((_) async => const Right('Added to Watchlist'));

    await pumpDetail(tester, 1399);
    when(mockStatus.execute(1399)).thenAnswer((_) async => true);
    await tester.tap(find.byKey(const Key('watchlist_button')));
    await tester.pump();
    await tester.pump();

    verify(mockSave.execute(testTvSeriesDetail)).called(1);
    verifyNever(mockRemove.execute(any));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Added to Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Watchlist button should remove the series when added', (
    tester,
  ) async {
    arrangeLoaded(inWatchlist: true);
    when(mockRemove.execute(testTvSeriesDetail))
        .thenAnswer((_) async => const Right('Removed from Watchlist'));

    await pumpDetail(tester, 1399);
    when(mockStatus.execute(1399)).thenAnswer((_) async => false);
    await tester.tap(find.byKey(const Key('watchlist_button')));
    await tester.pump();
    await tester.pump();

    verify(mockRemove.execute(testTvSeriesDetail)).called(1);
    verifyNever(mockSave.execute(any));
    expect(find.text('Removed from Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Watchlist button should display AlertDialog when it failed', (
    tester,
  ) async {
    arrangeLoaded();
    when(mockSave.execute(testTvSeriesDetail))
        .thenAnswer((_) async => const Left(DatabaseFailure('Failed')));

    await pumpDetail(tester, 1399);
    await tester.tap(find.byKey(const Key('watchlist_button')));
    await tester.pump();
    await tester.pump();

    verify(mockSave.execute(testTvSeriesDetail)).called(1);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
  });

  testWidgets('Page should list the seasons', (tester) async {
    arrangeLoaded(
      detail: const TvSeriesDetail(
        id: 1399,
        name: 'Game of Thrones',
        overview: 'Overview',
        posterPath: '/poster.jpg',
        backdropPath: null,
        firstAirDate: '2011-04-17',
        voteAverage: 8.4,
        voteCount: 1,
        numberOfSeasons: 2,
        numberOfEpisodes: 12,
        genres: [],
        seasons: [
          testSeason,
          Season(
            id: 2,
            seasonNumber: 2,
            episodeCount: 2,
            name: 'Season 2',
            overview: null,
            posterPath: null,
            airDate: null,
          ),
        ],
      ),
    );

    await pumpDetail(tester, 1399);

    expect(find.byKey(const Key('season_item_1')), findsOneWidget);
    expect(find.byKey(const Key('season_item_2')), findsOneWidget);
    expect(find.text('Season 1'), findsOneWidget);
    expect(find.text('10 episodes - 2011-04-17'), findsOneWidget);
    expect(find.text('2 episodes'), findsOneWidget);
    verify(mockDetail.execute(1399)).called(1);
  });

  testWidgets('Tapping a season should open its episodes page', (tester) async {
    arrangeLoaded();
    Object? arguments;

    await pumpDetail(
      tester,
      1399,
      onGenerateRoute: (settings) {
        if (settings.name == seasonDetailRoute) {
          arguments = settings.arguments;
          return MaterialPageRoute(builder: (_) => const Text('season page'));
        }
        return null;
      },
    );
    await tester.ensureVisible(find.byKey(const Key('season_item_1')));
    await tester.tap(find.byKey(const Key('season_item_1')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('season page'), findsOneWidget);
    final args = arguments as SeasonDetailArgs;
    expect(args.tvSeriesId, 1399);
    expect(args.seasonNumber, 1);
    expect(args.title, 'Game of Thrones');
    verify(mockDetail.execute(1399)).called(1);
  });

  testWidgets('Recommendations should display progress bar when loading', (
    tester,
  ) async {
    final pending = Completer<Either<Failure, List<TvSeries>>>();
    when(mockDetail.execute(1))
        .thenAnswer((_) async => const Right(emptyDetail));
    when(mockRecommendations.execute(1)).thenAnswer((_) => pending.future);
    when(mockStatus.execute(1)).thenAnswer((_) async => false);

    await pumpDetail(tester, 1);

    expect(
      find.descendant(
        of: find.byType(SingleChildScrollView),
        matching: find.byType(CircularProgressIndicator),
      ),
      findsOneWidget,
    );
    verify(mockRecommendations.execute(1)).called(1);
  });

  testWidgets('Recommendations should display the message when failed', (
    tester,
  ) async {
    arrangeLoaded(
      recommendations: const Left(ServerFailure('No recommendations')),
    );

    await pumpDetail(tester, 1399);

    expect(find.text('No recommendations'), findsOneWidget);
    verify(mockRecommendations.execute(1399)).called(1);
  });

  testWidgets('Recommendations should display nothing while empty', (
    tester,
  ) async {
    arrangeLoaded();

    await pumpDetail(tester, 1399);

    expect(find.text('Recommendations'), findsOneWidget);
    expect(find.byType(ListView), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(ListView),
        matching: find.byType(InkWell),
      ),
      findsNothing,
    );
    verify(mockRecommendations.execute(1399)).called(1);
  });

  testWidgets('Tapping a recommendation should open its detail page', (
    tester,
  ) async {
    arrangeLoaded(recommendations: Right(testTvSeriesList));

    await pumpDetail(
      tester,
      1399,
      onGenerateRoute: (settings) {
        if (settings.name == tvSeriesDetailRoute) {
          return MaterialPageRoute(
            builder: (_) => Text('opened ${settings.arguments}'),
          );
        }
        return null;
      },
    );

    final recommendation = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(recommendation);
    await tester.tap(recommendation);
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('opened 1399'), findsOneWidget);
    verify(mockRecommendations.execute(1399)).called(1);
  });

  testWidgets('A recommendation without a poster shows a placeholder icon', (
    tester,
  ) async {
    arrangeLoaded(
      recommendations: const Right([
        TvSeries(
          id: 5,
          name: 'No poster',
          overview: null,
          posterPath: null,
          backdropPath: null,
          voteAverage: null,
          voteCount: null,
          firstAirDate: null,
          genreIds: null,
        ),
      ]),
    );

    await pumpDetail(tester, 1399);

    final recommendation = find.descendant(
      of: find.byType(ListView),
      matching: find.byIcon(Icons.image_not_supported),
    );
    expect(recommendation, findsOneWidget);
    verify(mockRecommendations.execute(1399)).called(1);
  });

  testWidgets('Back button should leave the detail page', (tester) async {
    arrangeLoaded();

    await tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => TvSeriesDetailBloc(mockDetail)),
          BlocProvider(
            create: (_) => TvSeriesRecommendationsBloc(mockRecommendations),
          ),
          BlocProvider(
            create: (_) =>
                TvSeriesWatchlistStatusBloc(mockStatus, mockSave, mockRemove),
          ),
        ],
        child: MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const TvSeriesDetailPage(id: 1399),
                ),
              ),
              child: const Text('open'),
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(TvSeriesDetailPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(TvSeriesDetailPage), findsNothing);
    verify(mockDetail.execute(1399)).called(1);
  });
}
