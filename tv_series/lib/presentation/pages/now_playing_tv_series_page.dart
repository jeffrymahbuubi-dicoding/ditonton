import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tv_series/presentation/bloc/now_playing_tv_series/now_playing_tv_series_bloc.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';

class NowPlayingTvSeriesPage extends StatefulWidget {
  static const routeName = nowPlayingTvSeriesRoute;

  const NowPlayingTvSeriesPage({super.key});

  @override
  State<NowPlayingTvSeriesPage> createState() => _NowPlayingTvSeriesPageState();
}

class _NowPlayingTvSeriesPageState extends State<NowPlayingTvSeriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<NowPlayingTvSeriesBloc>().add(const FetchNowPlayingTvSeries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Now Playing TV Series')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<NowPlayingTvSeriesBloc, NowPlayingTvSeriesState>(
          builder: (context, state) => switch (state) {
            NowPlayingTvSeriesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            NowPlayingTvSeriesHasData(:final result) =>
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
            NowPlayingTvSeriesError(:final message) => Center(
              key: const Key('error_message'),
              child: Text(message),
            ),
            NowPlayingTvSeriesEmpty() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
