import 'package:dartz/dartz.dart';
import 'package:core/core.dart';
import 'package:tv_series/domain/entities/season_detail.dart';
import 'package:tv_series/domain/repositories/tv_series_repository.dart';

class GetSeasonDetail {
  const GetSeasonDetail(this.repository);

  final TvSeriesRepository repository;

  Future<Either<Failure, SeasonDetail>> execute(
    int tvSeriesId,
    int seasonNumber,
  ) {
    return repository.getSeasonDetail(tvSeriesId, seasonNumber);
  }
}
