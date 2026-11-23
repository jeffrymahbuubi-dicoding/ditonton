import 'package:core/utils/exception.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('DatabaseException should keep its message', () {
    expect(DatabaseException('no table').message, 'no table');
  });

  test('ServerException should be an Exception', () {
    expect(ServerException(), isA<Exception>());
  });
}
