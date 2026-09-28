// File generated for GreenBin linking directly to Firebase project: greenbin-41080
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your GreenBin Firebase apps.
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
        return windows;
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
    apiKey: 'AIzaSyAet2nrQbVUtYXFHzwxw_kSHcKxjy36FQY',
    appId: '1:82679842411:web:6e52f4b48245eeb8cc932e',
    messagingSenderId: '82679842411',
    projectId: 'greenbin-41080',
    authDomain: 'greenbin-41080.firebaseapp.com',
    storageBucket: 'greenbin-41080.firebasestorage.app',
    measurementId: 'G-ZV6L7Y1RQG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCC06pnYCrvEgQUWjlyS2MUNK6-_otIJg4',
    appId: '1:82679842411:android:bc5c4292c8b39d44cc932e',
    messagingSenderId: '82679842411',
    projectId: 'greenbin-41080',
    storageBucket: 'greenbin-41080.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyALVjWcBk3U3N3HZAn1-JC9NATJN8xgT_c',
    appId: '1:82679842411:ios:158464c64bc78ad4cc932e',
    messagingSenderId: '82679842411',
    projectId: 'greenbin-41080',
    storageBucket: 'greenbin-41080.firebasestorage.app',
    iosBundleId: 'com.example.greenbin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyALVjWcBk3U3N3HZAn1-JC9NATJN8xgT_c',
    appId: '1:82679842411:ios:158464c64bc78ad4cc932e',
    messagingSenderId: '82679842411',
    projectId: 'greenbin-41080',
    storageBucket: 'greenbin-41080.firebasestorage.app',
    iosBundleId: 'com.example.greenbin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAet2nrQbVUtYXFHzwxw_kSHcKxjy36FQY',
    appId: '1:82679842411:web:6e52f4b48245eeb8cc932e',
    messagingSenderId: '82679842411',
    projectId: 'greenbin-41080',
    authDomain: 'greenbin-41080.firebaseapp.com',
    storageBucket: 'greenbin-41080.firebasestorage.app',
  );
}
