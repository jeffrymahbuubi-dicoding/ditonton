import 'package:cached_network_image/cached_network_image.dart';
import 'package:core/core.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/presentation/pages/movie_detail_page.dart';
import 'package:movie/presentation/pages/popular_movies_page.dart';
import 'package:movie/presentation/pages/search_page.dart';
import 'package:movie/presentation/pages/top_rated_movies_page.dart';
import 'package:movie/presentation/bloc/now_playing_movies/now_playing_movies_bloc.dart';
import 'package:movie/presentation/bloc/popular_movies/popular_movies_bloc.dart';
import 'package:movie/presentation/bloc/top_rated_movies/top_rated_movies_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeMoviePage extends StatefulWidget {
  const HomeMoviePage({super.key});

  @override
  State<HomeMoviePage> createState() => _HomeMoviePageState();
}

class _HomeMoviePageState extends State<HomeMoviePage> {
  @override
  void initState() {
    super.initState();
    context.read<NowPlayingMoviesBloc>().add(const FetchNowPlayingMovies());
    context.read<PopularMoviesBloc>().add(const FetchPopularMovies());
    context.read<TopRatedMoviesBloc>().add(const FetchTopRatedMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: AppDrawer.moviesRoute),
      appBar: AppBar(
        title: Text('Ditonton'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamed(context, SearchPage.routeName);
            },
            icon: Icon(Icons.search),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Now Playing', style: kHeading6),
              BlocBuilder<NowPlayingMoviesBloc, NowPlayingMoviesState>(
                builder: (context, state) => switch (state) {
                  NowPlayingMoviesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  NowPlayingMoviesHasData(:final result) => MovieList(result),
                  NowPlayingMoviesError(:final message) => Text(message),
                  NowPlayingMoviesEmpty() => const SizedBox.shrink(),
                },
              ),
              _buildSubHeading(
                title: 'Popular',
                onTap: () =>
                    Navigator.pushNamed(context, PopularMoviesPage.routeName),
              ),
              BlocBuilder<PopularMoviesBloc, PopularMoviesState>(
                builder: (context, state) => switch (state) {
                  PopularMoviesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  PopularMoviesHasData(:final result) => MovieList(result),
                  PopularMoviesError(:final message) => Text(message),
                  PopularMoviesEmpty() => const SizedBox.shrink(),
                },
              ),
              _buildSubHeading(
                title: 'Top Rated',
                onTap: () =>
                    Navigator.pushNamed(context, TopRatedMoviesPage.routeName),
              ),
              BlocBuilder<TopRatedMoviesBloc, TopRatedMoviesState>(
                builder: (context, state) => switch (state) {
                  TopRatedMoviesLoading() => const Center(
                    child: CircularProgressIndicator(),
                  ),
                  TopRatedMoviesHasData(:final result) => MovieList(result),
                  TopRatedMoviesError(:final message) => Text(message),
                  TopRatedMoviesEmpty() => const SizedBox.shrink(),
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Row _buildSubHeading({required String title, required Function() onTap}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: kHeading6),
        InkWell(
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [Text('See More'), Icon(Icons.arrow_forward_ios)],
            ),
          ),
        ),
      ],
    );
  }
}

class MovieList extends StatelessWidget {
  final List<Movie> movies;

  const MovieList(this.movies, {super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Container(
            padding: const EdgeInsets.all(8),
            child: InkWell(
              onTap: () {
                Navigator.pushNamed(
                  context,
                  MovieDetailPage.routeName,
                  arguments: movie.id,
                );
              },
              child: ClipRRect(
                borderRadius: BorderRadius.all(Radius.circular(16)),
                child: CachedNetworkImage(
                  imageUrl: '$baseImageUrl${movie.posterPath}',
                  placeholder: (context, url) =>
                      Center(child: CircularProgressIndicator()),
                  errorWidget: (context, url, error) => Icon(Icons.error),
                ),
              ),
            ),
          );
        },
        itemCount: movies.length,
      ),
    );
  }
}
