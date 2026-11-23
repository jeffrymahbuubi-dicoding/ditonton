import 'package:ditonton/main.dart' as entry;
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('the entry point is an async function without parameters', () {
    expect(entry.main, isA<Future<void> Function()>());
  });
}
