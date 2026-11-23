import 'package:flutter_test/flutter_test.dart';
import 'package:tv_series/presentation/pages/season_detail_args.dart';

void main() {
  test('SeasonDetailArgs keeps its fields', () {
    const args = SeasonDetailArgs(
      tvSeriesId: 1399,
      seasonNumber: 2,
      title: 'Game of Thrones',
    );

    expect(args.tvSeriesId, 1399);
    expect(args.seasonNumber, 2);
    expect(args.title, 'Game of Thrones');
  });
}
