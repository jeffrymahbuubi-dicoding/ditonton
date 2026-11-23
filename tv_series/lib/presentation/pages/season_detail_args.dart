class SeasonDetailArgs {
  const SeasonDetailArgs({
    required this.tvSeriesId,
    required this.seasonNumber,
    required this.title,
  });

  final int tvSeriesId;
  final int seasonNumber;
  final String title;
}
