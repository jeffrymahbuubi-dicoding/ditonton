import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:tv_series/domain/entities/tv_series.dart';
import 'package:tv_series/presentation/bloc/tv_series_search/tv_series_search_bloc.dart';
import 'package:tv_series/presentation/pages/tv_series_search_page.dart';
import 'package:tv_series/presentation/widgets/tv_series_card_list.dart';

import '../../dummy_data/tv_series_dummy_objects.dart';
import '../../helpers/tv_series_use_case_test_helper.mocks.dart';

void main() {
  late MockSearchTvSeries mockUseCase;

  setUp(() {
    mockUseCase = MockSearchTvSeries();
  });

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      BlocProvider(
        create: (_) => TvSeriesSearchBloc(mockUseCase),
        child: const MaterialApp(home: TvSeriesSearchPage()),
      ),
    );
  }

  Future<void> typeAndWait(WidgetTester tester, String text) async {
    await tester.enterText(
      find.byKey(const Key('tv_series_search_field')),
      text,
    );
    await tester.pump(TvSeriesSearchBloc.debounceDuration);
    await tester.pump();
  }

  test('should use the frozen route name', () {
    expect(TvSeriesSearchPage.routeName, tvSeriesSearchRoute);
  });

  testWidgets('shows no list before anything is typed', (tester) async {
    await pumpPage(tester);

    expect(find.byType(ListView), findsNothing);
    expect(find.text('Search Result'), findsOneWidget);
    verifyNever(mockUseCase.execute(any));
  });

  testWidgets('shows a progress bar while loading', (tester) async {
    final pending = Completer<Either<Failure, List<TvSeries>>>();
    when(mockUseCase.execute('thrones')).thenAnswer((_) => pending.future);

    await pumpPage(tester);
    await typeAndWait(tester, 'thrones');

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(mockUseCase.execute('thrones')).called(1);
  });

  testWidgets('shows one card per result when loaded', (tester) async {
    when(mockUseCase.execute('thrones'))
        .thenAnswer((_) async => Right(testTvSeriesList));

    await pumpPage(tester);
    await typeAndWait(tester, 'thrones');

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(TvSeriesCard), findsOneWidget);
    verify(mockUseCase.execute('thrones')).called(1);
  });

  testWidgets('shows a text when nothing matches', (tester) async {
    when(mockUseCase.execute('thrones'))
        .thenAnswer((_) async => const Right(<TvSeries>[]));

    await pumpPage(tester);
    await typeAndWait(tester, 'thrones');

    expect(find.byKey(const Key('empty_message')), findsOneWidget);
    expect(find.byType(ListView), findsNothing);
    verify(mockUseCase.execute('thrones')).called(1);
  });

  testWidgets('shows the message when the search failed', (tester) async {
    when(mockUseCase.execute('thrones')).thenAnswer(
      (_) async => const Left(ConnectionFailure('Failed to connect')),
    );

    await pumpPage(tester);
    await typeAndWait(tester, 'thrones');

    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text('Failed to connect'), findsOneWidget);
    verify(mockUseCase.execute('thrones')).called(1);
  });

  testWidgets('clearing the field shows no list again', (tester) async {
    when(mockUseCase.execute('thrones'))
        .thenAnswer((_) async => Right(testTvSeriesList));

    await pumpPage(tester);
    await typeAndWait(tester, 'thrones');
    await typeAndWait(tester, '');

    expect(find.byType(ListView), findsNothing);
    verify(mockUseCase.execute('thrones')).called(1);
  });

  testWidgets('searches only after the debounce time has passed', (
    tester,
  ) async {
    when(mockUseCase.execute('thrones'))
        .thenAnswer((_) async => Right(testTvSeriesList));

    await pumpPage(tester);
    await tester.enterText(
      find.byKey(const Key('tv_series_search_field')),
      'thrones',
    );
    await tester.pump(const Duration(milliseconds: 400));
    verifyNever(mockUseCase.execute(any));

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();
    verify(mockUseCase.execute('thrones')).called(1);
  });

  testWidgets('typing twice within the debounce time searches once', (
    tester,
  ) async {
    when(mockUseCase.execute('thrones'))
        .thenAnswer((_) async => Right(testTvSeriesList));

    await pumpPage(tester);
    await tester.enterText(
      find.byKey(const Key('tv_series_search_field')),
      'thr',
    );
    await tester.pump(const Duration(milliseconds: 200));
    await typeAndWait(tester, 'thrones');

    verify(mockUseCase.execute('thrones')).called(1);
    verifyNever(mockUseCase.execute('thr'));
  });
}
