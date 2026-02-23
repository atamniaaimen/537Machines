import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for ios - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        return web;
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDXR7Z5i7OGgnmBu9mTenyjreNTaMTnVBE',
    appId: '1:392412464212:android:320e7031e5c0b4957f99c1',
    messagingSenderId: '392412464212',
    projectId: 'machines537app',
    storageBucket: 'machines537app.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBsZ8UyyoHfZX4UhKj_8z20JdPKMKiq2e8',
    appId: '1:392412464212:web:3364d64478254d797f99c1',
    messagingSenderId: '392412464212',
    projectId: 'machines537app',
    storageBucket: 'machines537app.firebasestorage.app',
    authDomain: 'machines537app.firebaseapp.com',
  );
}
