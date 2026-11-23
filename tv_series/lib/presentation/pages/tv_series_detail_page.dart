import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tv_series/domain/entities/season.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:tv_series/presentation/bloc/tv_series_detail/tv_series_detail_bloc.dart';
import 'package:tv_series/presentation/bloc/tv_series_recommendations/tv_series_recommendations_bloc.dart';
import 'package:tv_series/presentation/bloc/tv_series_watchlist_status/tv_series_watchlist_status_bloc.dart';
import 'package:tv_series/presentation/pages/season_detail_args.dart';

class TvSeriesDetailPage extends StatefulWidget {
  static const routeName = tvSeriesDetailRoute;

  final int id;
  const TvSeriesDetailPage({super.key, required this.id});

  @override
  State<TvSeriesDetailPage> createState() => _TvSeriesDetailPageState();
}

class _TvSeriesDetailPageState extends State<TvSeriesDetailPage> {
  @override
  void initState() {
    super.initState();
    context.read<TvSeriesDetailBloc>().add(FetchTvSeriesDetail(widget.id));
    context.read<TvSeriesRecommendationsBloc>().add(
      FetchTvSeriesRecommendations(widget.id),
    );
    context.read<TvSeriesWatchlistStatusBloc>().add(
      LoadTvSeriesWatchlistStatus(widget.id),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<
      TvSeriesWatchlistStatusBloc,
      TvSeriesWatchlistStatusState
    >(
      listenWhen: (previous, current) =>
          current.message.isNotEmpty && current.message != previous.message,
      listener: (context, state) {
        final message = state.message;
        if (message == TvSeriesWatchlistStatusBloc.watchlistAddSuccessMessage ||
            message ==
                TvSeriesWatchlistStatusBloc.watchlistRemoveSuccessMessage) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text(message)));
        } else {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(content: Text(message)),
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<TvSeriesDetailBloc, TvSeriesDetailState>(
          builder: (context, state) => switch (state) {
            TvSeriesDetailLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TvSeriesDetailHasData(:final result) => SafeArea(
              child: TvSeriesDetailContent(result),
            ),
            TvSeriesDetailError(:final message) => Center(child: Text(message)),
            TvSeriesDetailEmpty() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}

class TvSeriesDetailContent extends StatelessWidget {
  final TvSeriesDetail tvSeries;

  const TvSeriesDetailContent(this.tvSeries, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Stack(
      children: [
        _Poster(path: tvSeries.posterPath, width: screenWidth),
        Container(
          margin: const EdgeInsets.only(top: 48 + 8),
          child: DraggableScrollableSheet(
            builder: (context, scrollController) {
              return Container(
                decoration: const BoxDecoration(
                  color: kRichBlack,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                ),
                padding: const EdgeInsets.only(left: 16, top: 16, right: 16),
                child: Stack(
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 16),
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(tvSeries.name, style: kHeading5),
                            BlocBuilder<
                              TvSeriesWatchlistStatusBloc,
                              TvSeriesWatchlistStatusState
                            >(
                              builder: (context, status) => FilledButton(
                                key: const Key('watchlist_button'),
                                onPressed: () {
                                  context
                                      .read<TvSeriesWatchlistStatusBloc>()
                                      .add(
                                        status.isAdded
                                            ? RemoveTvSeriesFromWatchlist(
                                                tvSeries,
                                              )
                                            : AddTvSeriesToWatchlist(tvSeries),
                                      );
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    status.isAdded
                                        ? const Icon(Icons.check)
                                        : const Icon(Icons.add),
                                    const Text('Watchlist'),
                                  ],
                                ),
                              ),
                            ),
                            Text(_showGenres(tvSeries.genres)),
                            Text(
                              '${tvSeries.numberOfSeasons} seasons, '
                              '${tvSeries.numberOfEpisodes} episodes',
                            ),
                            Row(
                              children: [
                                RatingBarIndicator(
                                  rating: tvSeries.voteAverage / 2,
                                  itemCount: 5,
                                  itemBuilder: (context, index) => const Icon(
                                    Icons.star,
                                    color: kMikadoYellow,
                                  ),
                                  itemSize: 24,
                                ),
                                Text('${tvSeries.voteAverage}'),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text('Overview', style: kHeading6),
                            Text(tvSeries.overview),
                            const SizedBox(height: 16),
                            Text('Seasons', style: kHeading6),
                            for (final season in tvSeries.seasons)
                              _SeasonItem(
                                tvSeriesId: tvSeries.id,
                                title: tvSeries.name,
                                season: season,
                              ),
                            const SizedBox(height: 16),
                            Text('Recommendations', style: kHeading6),
                            const _Recommendations(),
                          ],
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.topCenter,
                      child: Container(
                        color: Colors.white,
                        height: 4,
                        width: 48,
                      ),
                    ),
                  ],
                ),
              );
            },
            minChildSize: 0.25,
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: CircleAvatar(
            backgroundColor: kRichBlack,
            foregroundColor: Colors.white,
            child: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ),
      ],
    );
  }

  String _showGenres(List<Genre> genres) {
    return genres.map((genre) => genre.name).join(', ');
  }
}

class _SeasonItem extends StatelessWidget {
  const _SeasonItem({
    required this.tvSeriesId,
    required this.title,
    required this.season,
  });

  final int tvSeriesId;
  final String title;
  final Season season;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      key: Key('season_item_${season.seasonNumber}'),
      onTap: () {
        Navigator.pushNamed(
          context,
          seasonDetailRoute,
          arguments: SeasonDetailArgs(
            tvSeriesId: tvSeriesId,
            seasonNumber: season.seasonNumber,
            title: title,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.all(Radius.circular(8)),
              child: _Poster(path: season.posterPath, width: 48),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(season.name, style: kSubtitle),
                  Text(
                    '${season.episodeCount} episodes'
                    '${season.airDate == null ? '' : ' - ${season.airDate}'}',
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _Recommendations extends StatelessWidget {
  const _Recommendations();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<
      TvSeriesRecommendationsBloc,
      TvSeriesRecommendationsState
    >(
      builder: (context, state) => switch (state) {
        TvSeriesRecommendationsLoading() => const Center(
          child: CircularProgressIndicator(),
        ),
        TvSeriesRecommendationsError(:final message) => Text(message),
        TvSeriesRecommendationsHasData(:final result) => SizedBox(
          height: 150,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemBuilder: (context, index) {
              final TvSeries tvSeries = result[index];
              return Padding(
                padding: const EdgeInsets.all(4.0),
                child: InkWell(
                  onTap: () {
                    Navigator.pushReplacementNamed(
                      context,
                      tvSeriesDetailRoute,
                      arguments: tvSeries.id,
                    );
                  },
                  child: ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(8)),
                    child: _Poster(path: tvSeries.posterPath),
                  ),
                ),
              );
            },
            itemCount: result.length,
          ),
        ),
        TvSeriesRecommendationsEmpty() => Container(),
      },
    );
  }
}

class _Poster extends StatelessWidget {
  const _Poster({required this.path, this.width});

  final String? path;
  final double? width;

  @override
  Widget build(BuildContext context) {
    if (path == null) {
      return SizedBox(
        width: width,
        child: const Center(child: Icon(Icons.image_not_supported)),
      );
    }
    return CachedNetworkImage(
      imageUrl: '$baseImageUrl$path',
      width: width,
      placeholder: (context, url) =>
          const Center(child: CircularProgressIndicator()),
      errorWidget: (context, url, error) => const Icon(Icons.error),
    );
  }
}
