import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/episode.dart';
import 'package:tv_series/domain/entities/season_detail.dart';
import 'package:tv_series/presentation/bloc/season_detail/season_detail_bloc.dart';
import 'package:tv_series/presentation/pages/season_detail_args.dart';
import 'package:tv_series/presentation/pages/season_detail_page.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetSeasonDetail mockUseCase;

  const args = SeasonDetailArgs(
    tvSeriesId: 1399,
    seasonNumber: 1,
    title: 'Game of Thrones',
  );

  setUp(() {
    mockUseCase = MockGetSeasonDetail();
  });

  Widget makeTestableWidget() {
    return BlocProvider(
      create: (_) => SeasonDetailBloc(mockUseCase),
      child: const MaterialApp(home: SeasonDetailPage(args: args)),
    );
  }

  testWidgets('Page should fetch the season of the arguments', (tester) async {
    final pending = Completer<Either<Failure, SeasonDetail>>();
    when(mockUseCase.execute(1399, 1)).thenAnswer((_) => pending.future);

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    verify(mockUseCase.execute(1399, 1)).called(1);
    expect(find.text('Game of Thrones'), findsOneWidget);
  });

  testWidgets('Page should display progress bar while loading', (tester) async {
    final pending = Completer<Either<Failure, SeasonDetail>>();
    when(mockUseCase.execute(1399, 1)).thenAnswer((_) => pending.future);

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(mockUseCase.execute(1399, 1)).called(1);
  });

  testWidgets('Page should display the episodes when loaded', (tester) async {
    when(mockUseCase.execute(1399, 1))
        .thenAnswer((_) async => const Right(testSeasonDetail));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.text('Season 1'), findsOneWidget);
    expect(find.byKey(const Key('episode_item_1')), findsOneWidget);
    expect(find.text('1. Winter Is Coming'), findsOneWidget);
    expect(find.text('2011-04-17'), findsOneWidget);
    expect(find.text(testEpisode.overview!), findsOneWidget);
    verify(mockUseCase.execute(1399, 1)).called(1);
  });

  testWidgets('Page should display dashes for missing episode data', (
    tester,
  ) async {
    when(mockUseCase.execute(1399, 1)).thenAnswer(
      (_) async => const Right(
        SeasonDetail(
          id: 1,
          seasonNumber: 1,
          name: 'Season 1',
          episodes: [
            Episode(
              id: 2,
              episodeNumber: 2,
              seasonNumber: 1,
              name: 'Second',
              overview: null,
              stillPath: null,
              airDate: null,
              runtime: null,
              voteAverage: 0,
            ),
          ],
        ),
      ),
    );

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.text('2. Second'), findsOneWidget);
    expect(find.text('-'), findsNWidgets(2));
    verify(mockUseCase.execute(1399, 1)).called(1);
  });

  testWidgets('Page should display the message when loading failed', (
    tester,
  ) async {
    when(mockUseCase.execute(1399, 1))
        .thenAnswer((_) async => const Left(ServerFailure('Failed to load')));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text('Failed to load'), findsOneWidget);
    verify(mockUseCase.execute(1399, 1)).called(1);
  });
}
