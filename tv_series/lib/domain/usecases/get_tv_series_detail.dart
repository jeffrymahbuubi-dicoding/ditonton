import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/entities/tv_series_detail.dart';
import 'package:tv_series/domain/repositories/tv_series_repository.dart';

class GetTvSeriesDetail {
  const GetTvSeriesDetail(this.repository);

  final TvSeriesRepository repository;

  Future<Either<Failure, TvSeriesDetail>> execute(int id) {
    return repository.getTvSeriesDetail(id);
  }
}
