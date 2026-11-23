import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/movie.dart';
import 'package:tv_series/tv_series.dart';
import 'package:material_ui/material_ui.dart';

class WatchlistMoviesPage extends StatefulWidget {
  static const routeName = watchlistRoute;

  const WatchlistMoviesPage({super.key});

  @override
  State<WatchlistMoviesPage> createState() => _WatchlistMoviesPageState();
}

class _WatchlistMoviesPageState extends State<WatchlistMoviesPage>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<WatchlistMoviesBloc>().add(const FetchWatchlistMovies());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    context.read<WatchlistMoviesBloc>().add(const FetchWatchlistMovies());
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Watchlist'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Movies'),
              Tab(key: Key('watchlist_tv_series_tab'), text: 'TV Series'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: BlocBuilder<WatchlistMoviesBloc, WatchlistMoviesState>(
                builder: (context, state) => switch (state) {
                  WatchlistMoviesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  WatchlistMoviesHasData(:final result) => ListView.builder(
                    itemBuilder: (context, index) => MovieCard(result[index]),
                    itemCount: result.length,
                  ),
                  WatchlistMoviesError(:final message) => Center(
                    key: const Key('error_message'),
                    child: Text(message),
                  ),
                  WatchlistMoviesEmpty() => const SizedBox.shrink(),
                },
              ),
            ),
            const WatchlistTvSeriesList(),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
}
