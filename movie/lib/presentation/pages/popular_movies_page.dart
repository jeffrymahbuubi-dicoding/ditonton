import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/presentation/bloc/popular_movies/popular_movies_bloc.dart';
import 'package:movie/presentation/widgets/movie_card_list.dart';
import 'package:material_ui/material_ui.dart';

class PopularMoviesPage extends StatefulWidget {
  static const routeName = popularMoviesRoute;

  const PopularMoviesPage({super.key});

  @override
  State<PopularMoviesPage> createState() => _PopularMoviesPageState();
}

class _PopularMoviesPageState extends State<PopularMoviesPage> {
  @override
  void initState() {
    super.initState();
    context.read<PopularMoviesBloc>().add(const FetchPopularMovies());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Popular Movies')),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: BlocBuilder<PopularMoviesBloc, PopularMoviesState>(
          builder: (context, state) => switch (state) {
            PopularMoviesLoading() => const Center(
              child: CircularProgressIndicator(),
            ),
            PopularMoviesHasData(:final result) => ListView.builder(
              itemBuilder: (context, index) => MovieCard(result[index]),
              itemCount: result.length,
            ),
            PopularMoviesError(:final message) => Center(
              key: const Key('error_message'),
              child: Text(message),
            ),
            PopularMoviesEmpty() => const SizedBox.shrink(),
          },
        ),
      ),
    );
  }
}
