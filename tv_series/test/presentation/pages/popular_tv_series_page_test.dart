import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/popular_tv_series/popular_tv_series_bloc.dart';
import 'package:tv_series/presentation/pages/popular_tv_series_page.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockGetPopularTvSeries mockUseCase;

  setUp(() {
    mockUseCase = MockGetPopularTvSeries();
  });

  Widget makeTestableWidget({RouteFactory? onGenerateRoute}) {
    return BlocProvider(
      create: (_) => PopularTvSeriesBloc(mockUseCase),
      child: MaterialApp(
        home: const PopularTvSeriesPage(),
        onGenerateRoute: onGenerateRoute,
      ),
    );
  }

  test('should use the frozen route name', () {
    expect(PopularTvSeriesPage.routeName, popularTvSeriesRoute);
  });

  testWidgets('fetches the list when the page opens', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => Right(testTvSeriesList));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('shows a progress bar while loading', (tester) async {
    final pending = Completer<Either<Failure, List<TvSeries>>>();
    when(mockUseCase.execute()).thenAnswer((_) => pending.future);

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('shows one card per TV series when loaded', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => Right(testTvSeriesList));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TvSeriesCard), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('shows a text when the loaded list is empty', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => const Right(<TvSeries>[]));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byKey(const Key('empty_message')), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('shows the message when the request failed', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => const Left(ServerFailure('Error message')));

    await tester.pumpWidget(makeTestableWidget());
    await tester.pump();

    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text('Error message'), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('tapping a card opens the detail route', (tester) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => Right(testTvSeriesList));
    RouteSettings? opened;

    await tester.pumpWidget(
      makeTestableWidget(
        onGenerateRoute: (settings) {
          opened = settings;
          return MaterialPageRoute(
            settings: settings,
            builder: (_) => const Scaffold(body: Text('opened')),
          );
        },
      ),
    );
    await tester.pump();
    await tester.tap(find.byType(TvSeriesCard));
    await tester.pump(const Duration(seconds: 1));

    expect(opened?.name, tvSeriesDetailRoute);
    expect(opened?.arguments, testTvSeries.id);
    verify(mockUseCase.execute()).called(1);
  });
}
