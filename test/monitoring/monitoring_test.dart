import 'dart:ui' show ErrorCallback, PlatformDispatcher;

import 'package:ditonton/monitoring/monitoring.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  late FlutterExceptionHandler? previousFlutterHandler;
  late ErrorCallback? previousPlatformHandler;

  setUp(() {
    previousFlutterHandler = FlutterError.onError;
    previousPlatformHandler = PlatformDispatcher.instance.onError;
  });

  tearDown(() {
    FlutterError.onError = previousFlutterHandler;
    PlatformDispatcher.instance.onError = previousPlatformHandler;
  });

  group('Monitoring.installErrorHandlers', () {
    test('sends Flutter framework errors to the fatal recorder', () {
      final recorded = <FlutterErrorDetails>[];
      Monitoring.installErrorHandlers(
        recordFatal: recorded.add,
        recordError: (error, stack) {},
      );
      final details = FlutterErrorDetails(exception: StateError('framework'));

      FlutterError.onError!(details);

      expect(recorded, [details]);
    });

    test(
      'sends platform errors to the error recorder and reports them as handled',
      () {
        final recorded = <(Object, StackTrace)>[];
        Monitoring.installErrorHandlers(
          recordFatal: (details) {},
          recordError: (error, stack) => recorded.add((error, stack)),
        );
        final error = StateError('platform');

        final handled = PlatformDispatcher.instance.onError!(
          error,
          StackTrace.empty,
        );

        expect(handled, isTrue);
        expect(recorded, [(error, StackTrace.empty)]);
      },
    );

    test('does not call the other recorder', () {
      var fatalCalls = 0;
      var errorCalls = 0;
      Monitoring.installErrorHandlers(
        recordFatal: (details) => fatalCalls++,
        recordError: (error, stack) => errorCalls++,
      );

      FlutterError.onError!(FlutterErrorDetails(exception: StateError('a')));

      expect(fatalCalls, 1);
      expect(errorCalls, 0);
    });
  });
}
