import 'package:about/about.dart';
import 'package:core/core.dart';
import 'package:cupertino_ui/cupertino_ui.dart';
import 'package:ditonton/injection.dart' as di;
import 'package:ditonton/presentation/pages/watchlist_movies_page.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:movie/movie.dart';
import 'package:tv_series/tv_series.dart';

class MyApp extends StatelessWidget {
  const MyApp({required this.navigatorObservers, super.key});

  final List<NavigatorObserver> navigatorObservers;

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => di.locator<NowPlayingMoviesBloc>()),
        BlocProvider(create: (_) => di.locator<PopularMoviesBloc>()),
        BlocProvider(create: (_) => di.locator<TopRatedMoviesBloc>()),
        BlocProvider(create: (_) => di.locator<MovieDetailBloc>()),
        BlocProvider(create: (_) => di.locator<MovieRecommendationsBloc>()),
        BlocProvider(create: (_) => di.locator<MovieWatchlistStatusBloc>()),
        BlocProvider(create: (_) => di.locator<WatchlistMoviesBloc>()),
        BlocProvider(create: (_) => di.locator<MovieSearchBloc>()),
        BlocProvider(create: (_) => di.locator<NowPlayingTvSeriesBloc>()),
        BlocProvider(create: (_) => di.locator<PopularTvSeriesBloc>()),
        BlocProvider(create: (_) => di.locator<TopRatedTvSeriesBloc>()),
        BlocProvider(create: (_) => di.locator<TvSeriesDetailBloc>()),
        BlocProvider(create: (_) => di.locator<TvSeriesRecommendationsBloc>()),
        BlocProvider(create: (_) => di.locator<SeasonDetailBloc>()),
        BlocProvider(create: (_) => di.locator<TvSeriesWatchlistStatusBloc>()),
        BlocProvider(create: (_) => di.locator<WatchlistTvSeriesBloc>()),
        BlocProvider(create: (_) => di.locator<TvSeriesSearchBloc>()),
      ],
      child: MaterialApp(
        title: 'Ditonton',
        theme: ThemeData.dark().copyWith(
          colorScheme: kColorScheme,
          primaryColor: kRichBlack,
          scaffoldBackgroundColor: kRichBlack,
          textTheme: kTextTheme,
          drawerTheme: kDrawerTheme,
        ),
        home: HomeMoviePage(),
        navigatorObservers: navigatorObservers,
        onGenerateRoute: (RouteSettings settings) {
          switch (settings.name) {
            case homeMoviesRoute:
              return MaterialPageRoute(
                builder: (_) => HomeMoviePage(),
                settings: settings,
              );
            case PopularMoviesPage.routeName:
              return CupertinoPageRoute(
                builder: (_) => PopularMoviesPage(),
                settings: settings,
              );
            case TopRatedMoviesPage.routeName:
              return CupertinoPageRoute(
                builder: (_) => TopRatedMoviesPage(),
                settings: settings,
              );
            case MovieDetailPage.routeName:
              final id = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => MovieDetailPage(id: id),
                settings: settings,
              );
            case SearchPage.routeName:
              return CupertinoPageRoute(
                builder: (_) => SearchPage(),
                settings: settings,
              );
            case WatchlistMoviesPage.routeName:
              return MaterialPageRoute(
                builder: (_) => WatchlistMoviesPage(),
                settings: settings,
              );
            case AboutPage.routeName:
              return MaterialPageRoute(
                builder: (_) => AboutPage(),
                settings: settings,
              );
            case HomeTvSeriesPage.routeName:
              return MaterialPageRoute(
                builder: (_) => const HomeTvSeriesPage(),
                settings: settings,
              );
            case PopularTvSeriesPage.routeName:
              return CupertinoPageRoute(
                builder: (_) => const PopularTvSeriesPage(),
                settings: settings,
              );
            case TopRatedTvSeriesPage.routeName:
              return CupertinoPageRoute(
                builder: (_) => const TopRatedTvSeriesPage(),
                settings: settings,
              );
            case NowPlayingTvSeriesPage.routeName:
              return CupertinoPageRoute(
                builder: (_) => const NowPlayingTvSeriesPage(),
                settings: settings,
              );
            case TvSeriesSearchPage.routeName:
              return CupertinoPageRoute(
                builder: (_) => const TvSeriesSearchPage(),
                settings: settings,
              );
            case TvSeriesDetailPage.routeName:
              final id = settings.arguments as int;
              return MaterialPageRoute(
                builder: (_) => TvSeriesDetailPage(id: id),
                settings: settings,
              );
            case SeasonDetailPage.routeName:
              final args = settings.arguments as SeasonDetailArgs;
              return MaterialPageRoute(
                builder: (_) => SeasonDetailPage(args: args),
                settings: settings,
              );
            default:
              return MaterialPageRoute(
                builder: (_) {
                  return Scaffold(
                    body: Center(child: Text('Page not found :(')),
                  );
                },
                settings: settings,
              );
          }
        },
      ),
    );
  }
}
