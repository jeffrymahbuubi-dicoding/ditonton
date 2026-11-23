import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/watchlist_tv_series/watchlist_tv_series_bloc.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';
import 'package:tv_series/presentation/widgets/watchlist_tv_series_list.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetWatchlistTvSeries mockUseCase;

  setUp(() {
    mockUseCase = MockGetWatchlistTvSeries();
  });

  Widget makeTestableWidget() {
    return BlocProvider(
      create: (_) => WatchlistTvSeriesBloc(mockUseCase),
      child: MaterialApp(
        navigatorObservers: [routeObserver],
        home: const Scaffold(body: WatchlistTvSeriesList()),
      ),
    );
  }

  testWidgets('Should fetch the watchlist when shown', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => const Right(<TvSeries>[]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('Should display progress bar while loading', (tester) async {
    final pending = Completer<Either<Failure, List<TvSeries>>>();
    when(mockUseCase.execute()).thenAnswer((_) => pending.future);

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('Should display the series when loaded', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => const Right([testWatchlistTvSeries]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byType(TvSeriesCard), findsOneWidget);
    expect(find.text('Game of Thrones'), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('Should display a text when the watchlist is empty', (
    tester,
  ) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => const Right(<TvSeries>[]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byKey(const Key('empty_message')), findsOneWidget);
    expect(find.byType(TvSeriesCard), findsNothing);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('Should display the message when loading failed', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => const Left(DatabaseFailure("Can't get data")));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text("Can't get data"), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('Should reload when the route is shown again', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => const Right(<TvSeries>[]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();
    verify(mockUseCase.execute()).called(1);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    navigator.push(MaterialPageRoute(builder: (_) => const Text('other')));
    await tester.pumpAndSettle();
    navigator.pop();
    await tester.pumpAndSettle();

    verify(mockUseCase.execute()).called(1);
  });
}
