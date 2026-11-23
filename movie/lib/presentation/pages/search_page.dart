import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:movie/presentation/bloc/movie_search/movie_search_bloc.dart';
import 'package:movie/presentation/widgets/movie_card_list.dart';
import 'package:material_ui/material_ui.dart';

class SearchPage extends StatelessWidget {
  static const routeName = searchMoviesRoute;

  const SearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Search')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              onChanged: (query) {
                context.read<MovieSearchBloc>().add(
                  MovieSearchQueryChanged(query),
                );
              },
              decoration: InputDecoration(
                hintText: 'Search title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
            ),
            SizedBox(height: 16),
            Text('Search Result', style: kHeading6),
            BlocBuilder<MovieSearchBloc, MovieSearchState>(
              builder: (context, state) => switch (state) {
                MovieSearchLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                MovieSearchHasData(:final result) => Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(8),
                    itemBuilder: (context, index) => MovieCard(result[index]),
                    itemCount: result.length,
                  ),
                ),
                MovieSearchError(:final message) => Expanded(
                  child: Center(
                    key: const Key('error_message'),
                    child: Text(message),
                  ),
                ),
                MovieSearchEmpty() => Expanded(child: Container()),
              },
            ),
          ],
        ),
      ),
    );
  }
}
