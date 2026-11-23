import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tv_series/domain/entities/episode.dart';
import 'package:tv_series/presentation/bloc/season_detail/season_detail_bloc.dart';
import 'package:tv_series/presentation/pages/season_detail_args.dart';

class SeasonDetailPage extends StatefulWidget {
  static const routeName = seasonDetailRoute;

  final SeasonDetailArgs args;
  const SeasonDetailPage({super.key, required this.args});

  @override
  State<SeasonDetailPage> createState() => _SeasonDetailPageState();
}

class _SeasonDetailPageState extends State<SeasonDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<SeasonDetailBloc>().add(
      FetchSeasonDetail(widget.args.tvSeriesId, widget.args.seasonNumber),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.args.title)),
      body: BlocBuilder<SeasonDetailBloc, SeasonDetailState>(
        builder: (context, state) => switch (state) {
          SeasonDetailLoading() => const Center(
            child: CircularProgressIndicator(),
          ),
          SeasonDetailHasData(:final result) => ListView(
            padding: const EdgeInsets.all(8.0),
            children: [
              Text(result.name, style: kHeading6),
              for (final episode in result.episodes)
                _EpisodeItem(episode: episode),
            ],
          ),
          SeasonDetailError(:final message) => Center(
            key: const Key('error_message'),
            child: Text(message),
          ),
          SeasonDetailEmpty() => const SizedBox.shrink(),
        },
      ),
    );
  }
}

class _EpisodeItem extends StatelessWidget {
  const _EpisodeItem({required this.episode});

  final Episode episode;

  @override
  Widget build(BuildContext context) {
    final stillPath = episode.stillPath;
    return Card(
      key: Key('episode_item_${episode.episodeNumber}'),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (stillPath != null)
              CachedNetworkImage(
                imageUrl: '$baseImageUrl$stillPath',
                placeholder: (context, url) =>
                    const Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => const Icon(Icons.error),
              ),
            const SizedBox(height: 8),
            Text('${episode.episodeNumber}. ${episode.name}', style: kSubtitle),
            Text(episode.airDate ?? '-'),
            const SizedBox(height: 8),
            Text(episode.overview ?? '-'),
          ],
        ),
      ),
    );
  }
}
