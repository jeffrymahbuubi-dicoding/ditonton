import 'package:core/utils/utils.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('routeObserver should be one shared RouteObserver', () {
    expect(routeObserver, isA<RouteObserver<ModalRoute>>());
    expect(routeObserver, same(routeObserver));
  });
}
