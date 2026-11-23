import 'package:tv_series/domain/repositories/tv_series_repository.dart';

class GetWatchlistTvSeriesStatus {
  const GetWatchlistTvSeriesStatus(this.repository);

  final TvSeriesRepository repository;

  Future<bool> execute(int id) {
    return repository.isAddedToWatchlist(id);
  }
}
