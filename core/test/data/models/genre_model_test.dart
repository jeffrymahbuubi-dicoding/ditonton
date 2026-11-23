import 'package:core/data/models/genre_model.dart';
import 'package:core/domain/entities/genre.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const tGenreModel = GenreModel(id: 28, name: 'Action');
  final tJson = {'id': 28, 'name': 'Action'};

  test('fromJson should read id and name', () {
    expect(GenreModel.fromJson(tJson), tGenreModel);
  });

  test('toJson should return a map with id and name', () {
    expect(tGenreModel.toJson(), tJson);
  });

  test('toEntity should return a Genre with the same values', () {
    expect(tGenreModel.toEntity(), const Genre(id: 28, name: 'Action'));
  });

  test('models with different values should not be equal', () {
    expect(const GenreModel(id: 28, name: 'Action'), tGenreModel);
    expect(const GenreModel(id: 12, name: 'Action'), isNot(tGenreModel));
  });
}
