import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform;

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are only configured for Android.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDAJtoVQN_SeA-9bvvmowHrTNHGDbSYLvY',
    appId: '1:437539823571:android:20297c43b4eb94686e9926',
    messagingSenderId: '437539823571',
    projectId: 'ditonton-3470c',
    storageBucket: 'ditonton-3470c.firebasestorage.app',
  );
}
