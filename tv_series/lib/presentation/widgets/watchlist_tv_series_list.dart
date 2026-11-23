import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tv_series/presentation/bloc/watchlist_tv_series/watchlist_tv_series_bloc.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';

class WatchlistTvSeriesList extends StatefulWidget {
  const WatchlistTvSeriesList({super.key});

  @override
  State<WatchlistTvSeriesList> createState() => _WatchlistTvSeriesListState();
}

class _WatchlistTvSeriesListState extends State<WatchlistTvSeriesList>
    with RouteAware {
  @override
  void initState() {
    super.initState();
    context.read<WatchlistTvSeriesBloc>().add(const FetchWatchlistTvSeries());
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)!);
  }

  @override
  void didPopNext() {
    context.read<WatchlistTvSeriesBloc>().add(const FetchWatchlistTvSeries());
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: BlocBuilder<WatchlistTvSeriesBloc, WatchlistTvSeriesState>(
        builder: (context, state) => switch (state) {
          WatchlistTvSeriesLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          WatchlistTvSeriesHasData(:final result) =>
            result.isEmpty
                ? const Center(
                    key: Key('empty_message'),
                    child: Text('No TV series in the watchlist yet'),
                  )
                : ListView.builder(
                    itemBuilder: (context, index) =>
                        TvSeriesCard(result[index]),
                    itemCount: result.length,
                  ),
          WatchlistTvSeriesError(:final message) => Center(
            key: const Key('error_message'),
            child: Text(message),
          ),
          WatchlistTvSeriesEmpty() => const SizedBox.shrink(),
        },
      ),
    );
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }
}
