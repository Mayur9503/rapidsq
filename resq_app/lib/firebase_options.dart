// File generated for ResQ Firebase integration.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with ResQ Firebase app.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDq7oppAzByfUCwAQJSXtJhv4n9toEHdrY',
    appId: '1:1061336940640:web:82d9ae3137fe9204e38305',
    messagingSenderId: '1061336940640',
    projectId: 'rapidsq-firebase',
    storageBucket: 'rapidsq-firebase.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDq7oppAzByfUCwAQJSXtJhv4n9toEHdrY',
    appId: '1:1061336940640:android:82d9ae3137fe9204e38305',
    messagingSenderId: '1061336940640',
    projectId: 'rapidsq-firebase',
    storageBucket: 'rapidsq-firebase.firebasestorage.app',
  );
}
