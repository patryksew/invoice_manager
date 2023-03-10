// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
    apiKey: 'AIzaSyCWYCh726cTp8Dpx7g55mgh0oLOPSL172I',
    appId: '1:1062144150607:web:94105c2166e67f7aa0ae3a',
    messagingSenderId: '1062144150607',
    projectId: 'invoice-manager-a768c',
    authDomain: 'invoice-manager-a768c.firebaseapp.com',
    storageBucket: 'invoice-manager-a768c.appspot.com',
    measurementId: 'G-K1QZDPP7YG',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCzhSJ5q6xn1nZ7EmWWYQ_CFQdQSQFacJE',
    appId: '1:1062144150607:android:e566ea5b3a51dcbba0ae3a',
    messagingSenderId: '1062144150607',
    projectId: 'invoice-manager-a768c',
    storageBucket: 'invoice-manager-a768c.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCfRnPcwYvMBVG4uahVJknxFx6xw73OBEc',
    appId: '1:1062144150607:ios:a60a233d0b0461b4a0ae3a',
    messagingSenderId: '1062144150607',
    projectId: 'invoice-manager-a768c',
    storageBucket: 'invoice-manager-a768c.appspot.com',
    iosClientId: '1062144150607-p8rvu6qs01nhuico8n595cuo5tm6seou.apps.googleusercontent.com',
    iosBundleId: 'com.example.invoiceManager',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCfRnPcwYvMBVG4uahVJknxFx6xw73OBEc',
    appId: '1:1062144150607:ios:a60a233d0b0461b4a0ae3a',
    messagingSenderId: '1062144150607',
    projectId: 'invoice-manager-a768c',
    storageBucket: 'invoice-manager-a768c.appspot.com',
    iosClientId: '1062144150607-p8rvu6qs01nhuico8n595cuo5tm6seou.apps.googleusercontent.com',
    iosBundleId: 'com.example.invoiceManager',
  );
}
