import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCRnXX60vJtdYpFLX_ccYhmslJMbYP-tsE',
    appId: '1:451233568547:android:111ad17abb41ea90b4de96',
    messagingSenderId: '451233568547',
    projectId: 'agroverse-b1743',
    storageBucket: 'agroverse-b1743.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_IOS_API_KEY',
    appId: 'YOUR_IOS_APP_ID',
    messagingSenderId: '451233568547',
    projectId: 'agroverse-b1743',
    storageBucket: 'agroverse-b1743.firebasestorage.app',
    iosBundleId: 'com.example.flutterApplicationModel1',
  );
}
