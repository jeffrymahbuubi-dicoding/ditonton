import 'package:core/core.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:tv_series/data/datasources/tv_series_local_data_source.dart';
import 'package:tv_series/data/datasources/tv_series_remote_data_source.dart';

@GenerateMocks(
  [TvSeriesRemoteDataSource, TvSeriesLocalDataSource, DatabaseHelper],
  customMocks: [MockSpec<http.Client>(as: #MockHttpClient)],
)
void main() {}
