import 'package:mockito/annotations.dart';
import 'package:tv_series/domain/usecases/get_now_playing_tv_series.dart';
import 'package:tv_series/domain/usecases/get_popular_tv_series.dart';
import 'package:tv_series/domain/usecases/get_season_detail.dart';
import 'package:tv_series/domain/usecases/get_top_rated_tv_series.dart';
import 'package:tv_series/domain/usecases/get_tv_series_detail.dart';
import 'package:tv_series/domain/usecases/get_tv_series_recommendations.dart';
import 'package:tv_series/domain/usecases/get_watchlist_tv_series.dart';
import 'package:tv_series/domain/usecases/get_watchlist_tv_series_status.dart';
import 'package:tv_series/domain/usecases/remove_watchlist_tv_series.dart';
import 'package:tv_series/domain/usecases/save_watchlist_tv_series.dart';
import 'package:tv_series/domain/usecases/search_tv_series.dart';

@GenerateMocks([
  GetNowPlayingTvSeries,
  GetPopularTvSeries,
  GetTopRatedTvSeries,
  GetWatchlistTvSeries,
  GetTvSeriesDetail,
  GetTvSeriesRecommendations,
  GetSeasonDetail,
  GetWatchlistTvSeriesStatus,
  SaveWatchlistTvSeries,
  RemoveWatchlistTvSeries,
  SearchTvSeries,
])
void main() {}
