import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBu1kU1tpPZttEkwdlhWZcNc7PJ33L7u04',
    appId: '1:778522995717:web:your-web-app-id',
    messagingSenderId: '778522995717',
    projectId: 'kiq-wanderwise',
    authDomain: 'kiq-wanderwise.firebaseapp.com',
    storageBucket: 'kiq-wanderwise.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBu1kU1tpPZttEkwdlhWZcNc7PJ33L7u04',
    appId: '1:778522995717:android:358153f486691b767d406c',
    messagingSenderId: '778522995717',
    projectId: 'kiq-wanderwise',
    storageBucket: 'kiq-wanderwise.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyA5f5dFiO98hbIGqVk1OjWdkXb-NTfQ0Pg',
    appId: '1:778522995717:ios:ab19afdd171e5b107d406c',
    messagingSenderId: '778522995717',
    projectId: 'kiq-wanderwise',
    storageBucket: 'kiq-wanderwise.firebasestorage.app',
    iosBundleId: 'com.example.wanderwise',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyA5f5dFiO98hbIGqVk1OjWdkXb-NTfQ0Pg',
    appId: '1:778522995717:ios:ab19afdd171e5b107d406c',
    messagingSenderId: '778522995717',
    projectId: 'kiq-wanderwise',
    storageBucket: 'kiq-wanderwise.firebasestorage.app',
    iosBundleId: 'com.example.wanderwise',
  );
}
