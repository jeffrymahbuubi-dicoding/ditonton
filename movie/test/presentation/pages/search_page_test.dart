import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/presentation/bloc/movie_search/movie_search_bloc.dart';
import 'package:movie/presentation/pages/search_page.dart';
import 'package:movie/presentation/widgets/movie_card_list.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockSearchMovies mockUseCase;

  setUp(() {
    mockUseCase = MockSearchMovies();
  });

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      BlocProvider(
        create: (_) => MovieSearchBloc(mockUseCase),
        child: const MaterialApp(home: SearchPage()),
      ),
    );
  }

  Future<void> typeAndWait(WidgetTester tester, String text) async {
    await tester.enterText(find.byType(TextField), text);
    await tester.pump(MovieSearchBloc.debounceDuration);
    await tester.pump();
  }

  testWidgets('Page should display no list before anything is typed', (
    WidgetTester tester,
  ) async {
    await pumpPage(tester);

    expect(find.byType(ListView), findsNothing);
    expect(find.text('Search Result'), findsOneWidget);
    verifyNever(mockUseCase.execute(any));
  });

  testWidgets('Page should display center progress bar when loading', (
    WidgetTester tester,
  ) async {
    final pending = Completer<Either<Failure, List<Movie>>>();
    when(mockUseCase.execute('spiderman')).thenAnswer((_) => pending.future);

    await pumpPage(tester);
    await typeAndWait(tester, 'spiderman');

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(mockUseCase.execute('spiderman')).called(1);
  });

  testWidgets('Page should display one MovieCard per result when loaded', (
    WidgetTester tester,
  ) async {
    when(mockUseCase.execute('spiderman'))
        .thenAnswer((_) async => Right(testMovieList));

    await pumpPage(tester);
    await typeAndWait(tester, 'spiderman');

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(MovieCard), findsOneWidget);
    verify(mockUseCase.execute('spiderman')).called(1);
  });

  testWidgets('Page should display the message when the search failed', (
    WidgetTester tester,
  ) async {
    when(mockUseCase.execute('spiderman')).thenAnswer(
      (_) async => const Left(ConnectionFailure('Failed to connect')),
    );

    await pumpPage(tester);
    await typeAndWait(tester, 'spiderman');

    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text('Failed to connect'), findsOneWidget);
    verify(mockUseCase.execute('spiderman')).called(1);
  });

  testWidgets('Typing should search only after the debounce time', (
    WidgetTester tester,
  ) async {
    when(mockUseCase.execute('spiderman'))
        .thenAnswer((_) async => Right(testMovieList));

    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'spiderman');
    await tester.pump(const Duration(milliseconds: 400));

    verifyNever(mockUseCase.execute(any));

    await tester.pump(const Duration(milliseconds: 100));
    await tester.pump();

    verify(mockUseCase.execute('spiderman')).called(1);
  });

  testWidgets('Typing quickly should search only for the last text', (
    WidgetTester tester,
  ) async {
    when(mockUseCase.execute('spiderman'))
        .thenAnswer((_) async => Right(testMovieList));

    await pumpPage(tester);
    await tester.enterText(find.byType(TextField), 'spi');
    await tester.pump(const Duration(milliseconds: 200));
    await typeAndWait(tester, 'spiderman');

    verify(mockUseCase.execute('spiderman')).called(1);
    verifyNever(mockUseCase.execute('spi'));
  });

  testWidgets('Clearing the text should remove the results', (
    WidgetTester tester,
  ) async {
    when(mockUseCase.execute('spiderman'))
        .thenAnswer((_) async => Right(testMovieList));

    await pumpPage(tester);
    await typeAndWait(tester, 'spiderman');
    expect(find.byType(MovieCard), findsOneWidget);

    await typeAndWait(tester, '');

    expect(find.byType(MovieCard), findsNothing);
    verify(mockUseCase.execute('spiderman')).called(1);
  });
}
