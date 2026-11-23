import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/presentation/bloc/now_playing_movies/now_playing_movies_bloc.dart';
import 'package:movie/presentation/bloc/popular_movies/popular_movies_bloc.dart';
import 'package:movie/presentation/bloc/top_rated_movies/top_rated_movies_bloc.dart';
import 'package:movie/presentation/pages/home_movie_page.dart';
import 'package:movie/presentation/pages/movie_detail_page.dart';
import 'package:movie/presentation/pages/popular_movies_page.dart';
import 'package:movie/presentation/pages/search_page.dart';
import 'package:movie/presentation/pages/top_rated_movies_page.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetNowPlayingMovies mockNowPlaying;
  late MockGetPopularMovies mockPopular;
  late MockGetTopRatedMovies mockTopRated;
  late List<RouteSettings> opened;

  setUp(() {
    mockNowPlaying = MockGetNowPlayingMovies();
    mockPopular = MockGetPopularMovies();
    mockTopRated = MockGetTopRatedMovies();
    opened = [];
  });

  void stubAll(Either<Failure, List<Movie>> result) {
    when(mockNowPlaying.execute()).thenAnswer((_) async => result);
    when(mockPopular.execute()).thenAnswer((_) async => result);
    when(mockTopRated.execute()).thenAnswer((_) async => result);
  }

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      MultiBlocProvider(
        providers: [
          BlocProvider(create: (_) => NowPlayingMoviesBloc(mockNowPlaying)),
          BlocProvider(create: (_) => PopularMoviesBloc(mockPopular)),
          BlocProvider(create: (_) => TopRatedMoviesBloc(mockTopRated)),
        ],
        child: MaterialApp(
          home: const HomeMoviePage(),
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

  testWidgets('fetches the three lists when the page opens', (tester) async {
    stubAll(Right(testMovieList));

    await pumpPage(tester);
    await tester.pump();

    verify(mockNowPlaying.execute()).called(1);
    verify(mockPopular.execute()).called(1);
    verify(mockTopRated.execute()).called(1);
  });

  testWidgets('shows the three headings and a progress bar per list', (
    tester,
  ) async {
    final pending = Completer<Either<Failure, List<Movie>>>();
    when(mockNowPlaying.execute()).thenAnswer((_) => pending.future);
    when(mockPopular.execute()).thenAnswer((_) => pending.future);
    when(mockTopRated.execute()).thenAnswer((_) => pending.future);

    await pumpPage(tester);
    await tester.pump();

    expect(find.text('Now Playing'), findsOneWidget);
    expect(find.text('Popular'), findsOneWidget);
    expect(find.text('Top Rated'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsNWidgets(3));
    verify(mockNowPlaying.execute()).called(1);
    verify(mockPopular.execute()).called(1);
    verify(mockTopRated.execute()).called(1);
  });

  testWidgets('shows a poster list per section when loaded', (tester) async {
    stubAll(Right(testMovieList));

    await pumpPage(tester);
    await tester.pump();

    expect(find.byType(MovieList), findsNWidgets(3));
    verify(mockNowPlaying.execute()).called(1);
    verify(mockPopular.execute()).called(1);
    verify(mockTopRated.execute()).called(1);
  });

  testWidgets('shows the failure message of each section', (tester) async {
    when(
      mockNowPlaying.execute(),
    ).thenAnswer((_) async => const Left(ServerFailure('Now playing failed')));
    when(mockPopular.execute())
        .thenAnswer((_) async => const Left(ServerFailure('Popular failed')));
    when(mockTopRated.execute())
        .thenAnswer((_) async => const Left(SslFailure('Top rated failed')));

    await pumpPage(tester);
    await tester.pump();

    expect(find.text('Now playing failed'), findsOneWidget);
    expect(find.text('Popular failed'), findsOneWidget);
    expect(find.text('Top rated failed'), findsOneWidget);
    verify(mockNowPlaying.execute()).called(1);
    verify(mockPopular.execute()).called(1);
    verify(mockTopRated.execute()).called(1);
  });

  testWidgets('the search button opens the search route', (tester) async {
    stubAll(Right(testMovieList));

    await pumpPage(tester);
    await tester.tap(find.byIcon(Icons.search));
    await tester.pumpAndSettle();

    expect(opened.last.name, SearchPage.routeName);
    verify(mockNowPlaying.execute()).called(1);
  });

  testWidgets('the first See More opens the popular page', (tester) async {
    stubAll(Right(testMovieList));

    await pumpPage(tester);
    await tester.tap(find.text('See More').at(0));
    await tester.pumpAndSettle();

    expect(opened.last.name, PopularMoviesPage.routeName);
    verify(mockPopular.execute()).called(1);
  });

  testWidgets('the second See More opens the top rated page', (tester) async {
    stubAll(Right(testMovieList));

    await pumpPage(tester);
    await tester.tap(find.text('See More').at(1));
    await tester.pumpAndSettle();

    expect(opened.last.name, TopRatedMoviesPage.routeName);
    verify(mockTopRated.execute()).called(1);
  });

  testWidgets('tapping a poster opens the movie detail with the id', (
    tester,
  ) async {
    stubAll(Right(testMovieList));

    await pumpPage(tester);
    await tester.pump();
    await tester.tap(
      find
          .descendant(
            of: find.byType(MovieList).first,
            matching: find.byType(InkWell),
          )
          .first,
    );
    await tester.pumpAndSettle();

    expect(opened.last.name, MovieDetailPage.routeName);
    expect(opened.last.arguments, 557);
    verify(mockNowPlaying.execute()).called(1);
  });

  testWidgets('the drawer is the shared AppDrawer with all four entries', (
    tester,
  ) async {
    stubAll(const Right(<Movie>[]));

    await pumpPage(tester);
    tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
    await tester.pump(const Duration(seconds: 1));

    expect(find.byType(AppDrawer), findsOneWidget);
    expect(find.text('Movies'), findsOneWidget);
    expect(find.text('TV Series'), findsOneWidget);
    expect(find.text('Watchlist'), findsOneWidget);
    expect(find.text('About'), findsOneWidget);
    verify(mockNowPlaying.execute()).called(1);
  });
}
