import 'package:ditonton/firebase_options.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DefaultFirebaseOptions', () {
    tearDown(() => debugDefaultTargetPlatformOverride = null);

    test('gives the Android options with every field filled', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.android;

      final options = DefaultFirebaseOptions.currentPlatform;

      expect(options, DefaultFirebaseOptions.android);
      expect(options.apiKey, isNotEmpty);
      expect(options.appId, isNotEmpty);
      expect(options.messagingSenderId, isNotEmpty);
      expect(options.projectId, isNotEmpty);
    });

    test('has no options for the other platforms', () {
      debugDefaultTargetPlatformOverride = TargetPlatform.iOS;

      expect(
        () => DefaultFirebaseOptions.currentPlatform,
        throwsUnsupportedError,
      );
    });
  });
}
