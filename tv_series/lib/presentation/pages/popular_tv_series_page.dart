import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tv_series/presentation/bloc/popular_tv_series/popular_tv_series_bloc.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';

class PopularTvSeriesPage extends StatefulWidget {
  static const routeName = popularTvSeriesRoute;

  const PopularTvSeriesPage({super.key});

  @override
  State<PopularTvSeriesPage> createState() => _PopularTvSeriesPageState();
}

class _PopularTvSeriesPageState extends State<PopularTvSeriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<PopularTvSeriesBloc>().add(const FetchPopularTvSeries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Popular TV Series')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<PopularTvSeriesBloc, PopularTvSeriesState>(
          builder: (context, state) => switch (state) {
            PopularTvSeriesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PopularTvSeriesHasData(:final result) =>
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
            PopularTvSeriesError(:final message) => Center(
              key: const Key('error_message'),
              child: Text(message),
            ),
            PopularTvSeriesEmpty() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
