import 'dart:async';

import 'package:bloc_test/bloc_test.dart';
import 'package:core/core.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:movie/presentation/bloc/movie_detail/movie_detail_bloc.dart';
import 'package:movie/domain/entities/movie_detail.dart';

import '../../../dummy_data/dummy_objects.dart';
import '../../../helpers/test_helper.mocks.dart';

void main() {
  late MockGetMovieDetail mockUseCase;
  late MovieDetailBloc bloc;

  const tId = 1;

  final tExpected = MovieDetail(
    adult: false,
    backdropPath: 'backdropPath',
    genres: [Genre(id: 1, name: 'Action')],
    id: 1,
    originalTitle: 'originalTitle',
    overview: 'overview',
    posterPath: 'posterPath',
    releaseDate: 'releaseDate',
    runtime: 120,
    title: 'title',
    voteAverage: 1,
    voteCount: 1,
  );

  setUp(() {
    mockUseCase = MockGetMovieDetail();
    bloc = MovieDetailBloc(mockUseCase);
  });

  tearDown(() async {
    await bloc.close();
  });

  test('initial state should be empty', () {
    expect(bloc.state, const MovieDetailEmpty());
  });

  blocTest<MovieDetailBloc, MovieDetailState>(
    'emits loading then data when the use case succeeds',
    build: () {
      when(mockUseCase.execute(tId))
          .thenAnswer((_) async => Right(testMovieDetail));
      return bloc;
    },
    act: (bloc) => bloc.add(FetchMovieDetail(tId)),
    expect: () => [const MovieDetailLoading(), MovieDetailHasData(tExpected)],
    verify: (_) {
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  blocTest<MovieDetailBloc, MovieDetailState>(
    'emits loading then error when the use case fails',
    build: () {
      when(mockUseCase.execute(tId))
          .thenAnswer((_) async => const Left(ServerFailure('Server Failure')));
      return bloc;
    },
    act: (bloc) => bloc.add(FetchMovieDetail(tId)),
    expect: () => [
      const MovieDetailLoading(),
      const MovieDetailError('Server Failure'),
    ],
    verify: (_) {
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  test(
    'a closed bloc is not written to when the use case answers late',
    () async {
      final pending = Completer<Either<Failure, MovieDetail>>();
      when(mockUseCase.execute(tId)).thenAnswer((_) => pending.future);

      bloc.add(FetchMovieDetail(tId));
      await Future<void>.delayed(Duration.zero);
      final closing = bloc.close();
      await Future<void>.delayed(const Duration(milliseconds: 10));
      pending.complete(Right(testMovieDetail));
      await closing;

      expect(bloc.state, const MovieDetailLoading());
      verify(mockUseCase.execute(tId)).called(1);
    },
  );

  test('events are equal when their ids are equal', () {
    expect(const FetchMovieDetail(1), const FetchMovieDetail(1));
    expect(const FetchMovieDetail(1), isNot(const FetchMovieDetail(2)));
    expect(const FetchMovieDetail(1).props, [1]);
  });
}
