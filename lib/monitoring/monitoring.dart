import 'package:ditonton/firebase_options.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

class Monitoring {
  const Monitoring._();

  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    final crashlytics = FirebaseCrashlytics.instance;
    installErrorHandlers(
      recordFatal: crashlytics.recordFlutterFatalError,
      recordError: (error, stack) =>
          crashlytics.recordError(error, stack, fatal: true),
    );
  }

  static NavigatorObserver analyticsObserver() =>
      FirebaseAnalyticsObserver(analytics: FirebaseAnalytics.instance);

  @visibleForTesting
  static void installErrorHandlers({
    required void Function(FlutterErrorDetails details) recordFatal,
    required void Function(Object error, StackTrace stack) recordError,
  }) {
    FlutterError.onError = recordFatal;
    PlatformDispatcher.instance.onError = (error, stack) {
      recordError(error, stack);
      return true;
    };
  }
}
