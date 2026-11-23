import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tv_series/presentation/bloc/top_rated_tv_series/top_rated_tv_series_bloc.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';

class TopRatedTvSeriesPage extends StatefulWidget {
  static const routeName = topRatedTvSeriesRoute;

  const TopRatedTvSeriesPage({super.key});

  @override
  State<TopRatedTvSeriesPage> createState() => _TopRatedTvSeriesPageState();
}

class _TopRatedTvSeriesPageState extends State<TopRatedTvSeriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<TopRatedTvSeriesBloc>().add(const FetchTopRatedTvSeries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Top Rated TV Series')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<TopRatedTvSeriesBloc, TopRatedTvSeriesState>(
          builder: (context, state) => switch (state) {
            TopRatedTvSeriesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TopRatedTvSeriesHasData(:final result) =>
              result.isEmpty
                  ? const Center(
                      key: Key('empty_message'),
                      child: Text('No TV series found'),
                    )
                  : ListView.builder(
                      itemBuilder: (context, index) =>
                          TvSeriesCard(result[index]),
                      itemCount: result.length,
                    ),
            TopRatedTvSeriesError(:final message) => Center(
              key: const Key('error_message'),
              child: Text(message),
            ),
            TopRatedTvSeriesEmpty() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
