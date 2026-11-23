import 'package:core/utils/failure.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('every failure should keep its message in props', () {
    expect(const ServerFailure('server').props, ['server']);
    expect(const ConnectionFailure('connection').props, ['connection']);
    expect(const DatabaseFailure('database').props, ['database']);
    expect(const SslFailure('certificate').props, ['certificate']);
  });

  test('failures of the same kind and message should be equal', () {
    expect(const SslFailure('certificate'), const SslFailure('certificate'));
    expect(const SslFailure('certificate'), isNot(const SslFailure('other')));
  });

  test('failures of different kinds should not be equal', () {
    expect(const SslFailure('message'), isNot(const ServerFailure('message')));
  });
}
