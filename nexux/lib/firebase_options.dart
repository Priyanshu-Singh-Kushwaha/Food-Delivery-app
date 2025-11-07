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
    apiKey: 'AIzaSyArDlwrx-bCXJmfuhb6TJZufn6TK2gKYMw',
    appId: '1:667294670739:web:d5aa868a4186dc40551266',
    messagingSenderId: '667294670739',
    projectId: 'nexux-6969f',
    authDomain: 'nexux-6969f.firebaseapp.com',
    storageBucket: 'nexux-6969f.firebasestorage.app',
    measurementId: 'G-53PX0K98SK',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4tBpw_sXFV6V9jJWDh_9Ruyn3rverMTc',
    appId: '1:667294670739:android:25058c7febaf2ffc551266',
    messagingSenderId: '667294670739',
    projectId: 'nexux-6969f',
    storageBucket: 'nexux-6969f.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyB-aSDebXtatNxMuccqB5_8tOjLyEHmyck',
    appId: '1:667294670739:ios:2fd1ab25624a81a2551266',
    messagingSenderId: '667294670739',
    projectId: 'nexux-6969f',
    storageBucket: 'nexux-6969f.firebasestorage.app',
    iosBundleId: 'com.example.nexux',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyB-aSDebXtatNxMuccqB5_8tOjLyEHmyck',
    appId: '1:667294670739:ios:2fd1ab25624a81a2551266',
    messagingSenderId: '667294670739',
    projectId: 'nexux-6969f',
    storageBucket: 'nexux-6969f.firebasestorage.app',
    iosBundleId: 'com.example.nexux',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyArDlwrx-bCXJmfuhb6TJZufn6TK2gKYMw',
    appId: '1:667294670739:web:c9fcfe55c88f65c0551266',
    messagingSenderId: '667294670739',
    projectId: 'nexux-6969f',
    authDomain: 'nexux-6969f.firebaseapp.com',
    storageBucket: 'nexux-6969f.firebasestorage.app',
    measurementId: 'G-5ZBHEKD7EK',
  );

}