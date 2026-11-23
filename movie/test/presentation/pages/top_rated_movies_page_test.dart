import 'dart:async';

import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/domain/entities/movie.dart';
import 'package:movie/presentation/bloc/top_rated_movies/top_rated_movies_bloc.dart';
import 'package:movie/presentation/pages/top_rated_movies_page.dart';
import 'package:movie/presentation/widgets/movie_card_list.dart';

import '../../dummy_data/dummy_objects.dart';
import '../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetTopRatedMovies mockUseCase;

  setUp(() {
    mockUseCase = MockGetTopRatedMovies();
  });

  Future<void> pumpPage(WidgetTester tester) {
    return tester.pumpWidget(
      BlocProvider(
        create: (_) => TopRatedMoviesBloc(mockUseCase),
        child: const MaterialApp(home: TopRatedMoviesPage()),
      ),
    );
  }

  testWidgets('Page should display center progress bar when loading', (
    WidgetTester tester,
  ) async {
    final pending = Completer<Either<Failure, List<Movie>>>();
    when(mockUseCase.execute()).thenAnswer((_) => pending.future);

    await pumpPage(tester);
    await tester.pump();

    expect(find.byType(Center), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('Page should display ListView when the list is empty', (
    WidgetTester tester,
  ) async {
    when(mockUseCase.execute()).thenAnswer((_) async => const Right(<Movie>[]));

    await pumpPage(tester);
    await tester.pump();

    expect(find.byType(ListView), findsOneWidget);
    expect(find.byType(MovieCard), findsNothing);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('Page should display one MovieCard per movie when loaded', (
    WidgetTester tester,
  ) async {
    when(mockUseCase.execute()).thenAnswer((_) async => Right(testMovieList));

    await pumpPage(tester);
    await tester.pump();

    expect(find.byType(MovieCard), findsOneWidget);
    expect(find.text('Spider-Man'), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });

  testWidgets('Page should display text with message when Error', (
    WidgetTester tester,
  ) async {
    when(mockUseCase.execute())
        .thenAnswer((_) async => const Left(ServerFailure('Error message')));

    await pumpPage(tester);
    await tester.pump();

    expect(find.byKey(const Key('error_message')), findsOneWidget);
    expect(find.text('Error message'), findsOneWidget);
    verify(mockUseCase.execute()).called(1);
  });
}
