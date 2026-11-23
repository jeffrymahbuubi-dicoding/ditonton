import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/now_playing_tv_series/now_playing_tv_series_bloc.dart';
import 'package:tv_series/presentation/bloc/popular_tv_series/popular_tv_series_bloc.dart';
import 'package:tv_series/presentation/bloc/top_rated_tv_series/top_rated_tv_series_bloc.dart';

class HomeTvSeriesPage extends StatefulWidget {
  static const routeName = homeTvSeriesRoute;

  const HomeTvSeriesPage({super.key});

  @override
  State<HomeTvSeriesPage> createState() => _HomeTvSeriesPageState();
}

class _HomeTvSeriesPageState extends State<HomeTvSeriesPage> {
  @override
  void initState() {
    super.initState();
    context.read<NowPlayingTvSeriesBloc>().add(const FetchNowPlayingTvSeries());
    context.read<PopularTvSeriesBloc>().add(const FetchPopularTvSeries());
    context.read<TopRatedTvSeriesBloc>().add(const FetchTopRatedTvSeries());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: homeTvSeriesRoute),
      appBar: AppBar(
        title: const Text('Ditonton'),
        actions: [
          IconButton(
            key: const Key('tv_series_search_button'),
            onPressed: () {
              Navigator.pushNamed(context, tvSeriesSearchRoute);
            },
            icon: const Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSubHeading(
                title: 'Now Playing',
                seeMoreKey: const Key('see_more_now_playing'),
                onTap: () =>
                    Navigator.pushNamed(context, nowPlayingTvSeriesRoute),
              ),
              BlocBuilder<NowPlayingTvSeriesBloc, NowPlayingTvSeriesState>(
                builder: (context, state) => switch (state) {
                  NowPlayingTvSeriesLoading() => _buildLoading(),
                  NowPlayingTvSeriesHasData(:final result) => _buildList(
                    result,
                  ),
                  NowPlayingTvSeriesError(:final message) => Text(message),
                  NowPlayingTvSeriesEmpty() => const SizedBox.shrink(),
                },
              ),
              _buildSubHeading(
                title: 'Popular',
                seeMoreKey: const Key('see_more_popular'),
                onTap: () => Navigator.pushNamed(context, popularTvSeriesRoute),
              ),
              BlocBuilder<PopularTvSeriesBloc, PopularTvSeriesState>(
                builder: (context, state) => switch (state) {
                  PopularTvSeriesLoading() => _buildLoading(),
                  PopularTvSeriesHasData(:final result) => _buildList(result),
                  PopularTvSeriesError(:final message) => Text(message),
                  PopularTvSeriesEmpty() => const SizedBox.shrink(),
                },
              ),
              _buildSubHeading(
                title: 'Top Rated',
                seeMoreKey: const Key('see_more_top_rated'),
                onTap: () =>
                    Navigator.pushNamed(context, topRatedTvSeriesRoute),
              ),
              BlocBuilder<TopRatedTvSeriesBloc, TopRatedTvSeriesState>(
                builder: (context, state) => switch (state) {
                  TopRatedTvSeriesLoading() => _buildLoading(),
                  TopRatedTvSeriesHasData(:final result) => _buildList(result),
                  TopRatedTvSeriesError(:final message) => Text(message),
                  TopRatedTvSeriesEmpty() => const SizedBox.shrink(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoading() {
    return const Center(child: CircularProgressIndicator());
  }

  Widget _buildList(List<TvSeries> tvSeries) {
    if (tvSeries.isEmpty) {
      return const Text('No TV series found');
    }
    return TvSeriesList(tvSeries);
  }

  Row _buildSubHeading({
    required String title,
    required Key seeMoreKey,
    required Function() onTap,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: kHeading6),
        InkWell(
          key: seeMoreKey,
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.all(8.0),
            child: Row(
              children: [Text('See More'), Icon(Icons.arrow_forward_ios)],
            ),
          ),
        ),
      ],
    );
  }
}

class TvSeriesList extends StatelessWidget {
  const TvSeriesList(this.tvSeries, {super.key});

  final List<TvSeries> tvSeries;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final item = tvSeries[index];
          return Container(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  tvSeriesDetailRoute,
                  arguments: item.id,
                );
              },
              child: ClipRRect(
                borderRadius: const BorderRadius.all(Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: '$baseImageUrl${item.posterPath}',
                  placeholder: (context, url) =>
                      const Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
        itemCount: tvSeries.length,
      ),
    );
  }
}
