import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/repositories/tv_series_repository.dart';

class GetNowPlayingTvSeries {
  const GetNowPlayingTvSeries(this.repository);

  final TvSeriesRepository repository;

  Future<Either<Failure, List<TvSeries>>> execute() {
    return repository.getNowPlayingTvSeries();
  }
}
