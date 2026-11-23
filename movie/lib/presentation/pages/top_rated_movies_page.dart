import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/presentation/bloc/top_rated_movies/top_rated_movies_bloc.dart';
import 'package:movie/presentation/widgets/movie_card_list.dart';
import 'package:material_ui/material_ui.dart';

class TopRatedMoviesPage extends StatefulWidget {
  static const routeName = topRatedMoviesRoute;

  const TopRatedMoviesPage({super.key});

  @override
  State<TopRatedMoviesPage> createState() => _TopRatedMoviesPageState();
}

class _TopRatedMoviesPageState extends State<TopRatedMoviesPage> {
  @override
  void initState() {
    super.initState();
    context.read<TopRatedMoviesBloc>().add(const FetchTopRatedMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Top Rated Movies')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<TopRatedMoviesBloc, TopRatedMoviesState>(
          builder: (context, state) => switch (state) {
            TopRatedMoviesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            TopRatedMoviesHasData(:final result) => ListView.builder(
              itemBuilder: (context, index) => MovieCard(result[index]),
              itemCount: result.length,
            ),
            TopRatedMoviesError(:final message) => Center(
              key: const Key('error_message'),
              child: Text(message),
            ),
            TopRatedMoviesEmpty() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
