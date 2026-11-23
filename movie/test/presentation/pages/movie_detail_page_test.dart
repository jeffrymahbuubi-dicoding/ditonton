import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/domain/entities/movie_detail.dart';
import 'package:movie/presentation/bloc/movie_detail/movie_detail_bloc.dart';
import 'package:movie/presentation/bloc/movie_recommendations/movie_recommendations_bloc.dart';
import 'package:movie/presentation/bloc/movie_watchlist_status/movie_watchlist_status_bloc.dart';
import 'package:movie/presentation/pages/movie_detail_page.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetMovieDetail mockDetail;
  late MockGetMovieRecommendations mockRecommendations;
  late MockGetWatchListStatus mockStatus;
  late MockSaveWatchlist mockSave;
  late MockRemoveWatchlist mockRemove;
  late bool inWatchlist;

  setUp(() {
    mockDetail = MockGetMovieDetail();
    mockRecommendations = MockGetMovieRecommendations();
    mockStatus = MockGetWatchListStatus();
    mockSave = MockSaveWatchlist();
    mockRemove = MockRemoveWatchlist();
    inWatchlist = false;
    when(mockStatus.execute(1)).thenAnswer((_) async => inWatchlist);
  });

  void stubDetail([MovieDetail? detail]) {
    when(mockDetail.execute(1))
        .thenAnswer((_) async => Right(detail ?? testMovieDetail));
  }

  void stubRecommendations(List<Movie> movies) {
    when(mockRecommendations.execute(1)).thenAnswer((_) async => Right(movies));
  }

  Widget providers(Widget child) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => MovieDetailBloc(mockDetail)),
        BlocProvider(
          create: (_) => MovieRecommendationsBloc(mockRecommendations),
        ),
        BlocProvider(
          create: (_) =>
              MovieWatchlistStatusBloc(mockStatus, mockSave, mockRemove),
        ),
      ],
      child: child,
    );
  }

  Future<void> pumpPage(WidgetTester tester) async {
    await tester.pumpWidget(
      providers(const MaterialApp(home: MovieDetailPage(id: 1))),
    );
    await tester.pump();
    await tester.pump();
  }

  void verifyFetched() {
    verify(mockDetail.execute(1)).called(1);
    verify(mockRecommendations.execute(1)).called(1);
    verify(mockStatus.execute(1)).called(greaterThanOrEqualTo(1));
  }

  testWidgets('Page should fetch detail, recommendations and status', (
    tester,
  ) async {
    stubDetail();
    stubRecommendations(<Movie>[]);

    await pumpPage(tester);

    verifyFetched();
    expect(find.text('title'), findsOneWidget);
  });

  testWidgets(
    'Watchlist button should display add icon when movie not added to watchlist',
    (WidgetTester tester) async {
      stubDetail();
      stubRecommendations(<Movie>[]);

      await pumpPage(tester);

      expect(find.byIcon(Icons.add), findsOneWidget);
      expect(find.byIcon(Icons.check), findsNothing);
      verifyFetched();
    },
  );

  testWidgets(
    'Watchlist button should display check icon when movie is added to watchlist',
    (WidgetTester tester) async {
      stubDetail();
      stubRecommendations(<Movie>[]);
      inWatchlist = true;

      await pumpPage(tester);

      expect(find.byIcon(Icons.check), findsOneWidget);
      expect(find.byIcon(Icons.add), findsNothing);
      verifyFetched();
    },
  );

  testWidgets('Add button tap should save the movie and show a Snackbar', (
    WidgetTester tester,
  ) async {
    stubDetail();
    stubRecommendations(<Movie>[]);
    when(mockSave.execute(testMovieDetail)).thenAnswer((_) async {
      inWatchlist = true;
      return const Right('Added to Watchlist');
    });

    await pumpPage(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    verify(mockSave.execute(testMovieDetail)).called(1);
    verifyNever(mockRemove.execute(any));
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Added to Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.check), findsOneWidget);
  });

  testWidgets('Add button tap should show an AlertDialog when it failed', (
    WidgetTester tester,
  ) async {
    stubDetail();
    stubRecommendations(<Movie>[]);
    when(mockSave.execute(testMovieDetail))
        .thenAnswer((_) async => const Left(DatabaseFailure('Failed')));

    await pumpPage(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    verify(mockSave.execute(testMovieDetail)).called(1);
    expect(find.byType(AlertDialog), findsOneWidget);
    expect(find.text('Failed'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('The same failure should be shown again on the next tap', (
    WidgetTester tester,
  ) async {
    stubDetail();
    stubRecommendations(<Movie>[]);
    when(mockSave.execute(testMovieDetail))
        .thenAnswer((_) async => const Left(DatabaseFailure('Failed')));

    await pumpPage(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();
    expect(find.byType(AlertDialog), findsOneWidget);

    Navigator.of(tester.element(find.byType(AlertDialog))).pop();
    await tester.pump(const Duration(seconds: 1));
    expect(find.byType(AlertDialog), findsNothing);

    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    verify(mockSave.execute(testMovieDetail)).called(2);
    expect(find.byType(AlertDialog), findsOneWidget);
  });

  testWidgets('Remove button tap should remove the movie and show a Snackbar', (
    WidgetTester tester,
  ) async {
    stubDetail();
    stubRecommendations(<Movie>[]);
    inWatchlist = true;
    when(mockRemove.execute(testMovieDetail)).thenAnswer((_) async {
      inWatchlist = false;
      return const Right('Removed from Watchlist');
    });

    await pumpPage(tester);
    await tester.tap(find.byType(FilledButton));
    await tester.pump();
    await tester.pump();

    verify(mockRemove.execute(testMovieDetail)).called(1);
    verifyNever(mockSave.execute(any));
    expect(find.text('Removed from Watchlist'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsOneWidget);
  });

  testWidgets('Page should display progress bar while the movie is loading', (
    WidgetTester tester,
  ) async {
    final pending = Completer<Either<Failure, MovieDetail>>();
    when(mockDetail.execute(1)).thenAnswer((_) => pending.future);
    stubRecommendations(<Movie>[]);

    await pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
    verifyFetched();
  });

  testWidgets('Page should display the message when the movie failed to load', (
    WidgetTester tester,
  ) async {
    when(mockDetail.execute(1))
        .thenAnswer((_) async => const Left(ServerFailure('Failed to load')));
    stubRecommendations(<Movie>[]);

    await pumpPage(tester);

    expect(find.text('Failed to load'), findsOneWidget);
    verifyFetched();
  });

  testWidgets('Page should display the genres and the duration', (
    WidgetTester tester,
  ) async {
    stubDetail(
      MovieDetail(
        adult: false,
        backdropPath: null,
        genres: [
          Genre(id: 1, name: 'Action'),
          Genre(id: 2, name: 'Drama'),
        ],
        id: 1,
        originalTitle: 'originalTitle',
        overview: 'overview',
        posterPath: 'posterPath',
        releaseDate: 'releaseDate',
        runtime: 125,
        title: 'title',
        voteAverage: 8,
        voteCount: 1,
      ),
    );
    stubRecommendations(<Movie>[]);

    await pumpPage(tester);

    expect(find.text('Action, Drama'), findsOneWidget);
    expect(find.text('2h 5m'), findsOneWidget);
    verifyFetched();
  });

  testWidgets('Page should display minutes only for a short movie', (
    WidgetTester tester,
  ) async {
    stubDetail(
      MovieDetail(
        adult: false,
        backdropPath: null,
        genres: <Genre>[],
        id: 1,
        originalTitle: 'originalTitle',
        overview: 'overview',
        posterPath: 'posterPath',
        releaseDate: 'releaseDate',
        runtime: 45,
        title: 'title',
        voteAverage: 8,
        voteCount: 1,
      ),
    );
    stubRecommendations(<Movie>[]);

    await pumpPage(tester);

    expect(find.text('45m'), findsOneWidget);
    verifyFetched();
  });

  testWidgets('Recommendations should display progress bar when loading', (
    WidgetTester tester,
  ) async {
    final pending = Completer<Either<Failure, List<Movie>>>();
    stubDetail();
    when(mockRecommendations.execute(1)).thenAnswer((_) => pending.future);

    await pumpPage(tester);

    expect(find.byType(CircularProgressIndicator), findsNWidgets(2));
    verifyFetched();
  });

  testWidgets('Recommendations should display the message when failed', (
    WidgetTester tester,
  ) async {
    stubDetail();
    when(
      mockRecommendations.execute(1),
    ).thenAnswer((_) async => const Left(ServerFailure('No recommendations')));

    await pumpPage(tester);

    expect(find.text('No recommendations'), findsOneWidget);
    verifyFetched();
  });

  testWidgets('Tapping a recommendation should open its detail page', (
    WidgetTester tester,
  ) async {
    stubDetail();
    stubRecommendations(testMovieList);

    await tester.pumpWidget(
      providers(
        MaterialApp(
          home: const MovieDetailPage(id: 1),
          onGenerateRoute: (settings) {
            if (settings.name == MovieDetailPage.routeName) {
              return MaterialPageRoute(
                builder: (_) => Text('opened ${settings.arguments}'),
              );
            }
            return null;
          },
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    final recommendation = find.descendant(
      of: find.byType(ListView),
      matching: find.byType(InkWell),
    );
    await tester.ensureVisible(recommendation);
    await tester.tap(recommendation);
    await tester.pumpAndSettle();

    expect(find.text('opened 557'), findsOneWidget);
    verifyFetched();
  });

  testWidgets('Back button should leave the detail page', (
    WidgetTester tester,
  ) async {
    stubDetail();
    stubRecommendations(<Movie>[]);

    await tester.pumpWidget(
      providers(
        MaterialApp(
          home: Builder(
            builder: (context) => TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const MovieDetailPage(id: 1)),
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
    expect(find.byType(MovieDetailPage), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(MovieDetailPage), findsNothing);
    verifyFetched();
  });
}
