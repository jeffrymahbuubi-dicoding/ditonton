import 'package:core/core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_ui/material_ui.dart';
import 'package:tv_series/presentation/bloc/tv_series_search/tv_series_search_bloc.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';

class TvSeriesSearchPage extends StatelessWidget {
  static const routeName = tvSeriesSearchRoute;

  const TvSeriesSearchPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search TV Series')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              key: const Key('tv_series_search_field'),
              onChanged: (query) {
                context.read<TvSeriesSearchBloc>().add(
                  TvSeriesSearchQueryChanged(query),
                );
              },
              decoration: const InputDecoration(
                hintText: 'Search title',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              textInputAction: TextInputAction.search,
            ),
            const SizedBox(height: 16),
            Text('Search Result', style: kHeading6),
            BlocBuilder<TvSeriesSearchBloc, TvSeriesSearchState>(
              builder: (context, state) => switch (state) {
                TvSeriesSearchLoading() => const Center(
                  child: CircularProgressIndicator(),
                ),
                TvSeriesSearchHasData(:final result) =>
                  result.isEmpty
                      ? const Expanded(
                          child: Center(
                            key: Key('empty_message'),
                            child: Text('No TV series found'),
                          ),
                        )
                      : Expanded(
                          child: ListView.builder(
                            padding: const EdgeInsets.all(8),
                            itemBuilder: (context, index) =>
                                TvSeriesCard(result[index]),
                            itemCount: result.length,
                          ),
                        ),
                TvSeriesSearchError(:final message) => Expanded(
                  child: Center(
                    key: const Key('error_message'),
                    child: Text(message),
                  ),
                ),
                TvSeriesSearchEmpty() => Expanded(child: Container()),
              },
            ),
          ],
        ),
      ),
    );
  }
}
