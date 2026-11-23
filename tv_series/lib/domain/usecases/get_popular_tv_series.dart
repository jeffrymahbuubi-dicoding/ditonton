import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/domain/repositories/tv_series_repository.dart';

class GetPopularTvSeries {
  const GetPopularTvSeries(this.repository);

  final TvSeriesRepository repository;

  Future<Either<Failure, List<TvSeries>>> execute() {
    return repository.getPopularTvSeries();
  }
}
