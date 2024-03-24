// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
    apiKey: 'AIzaSyBx7hnDyC5BEQEzHuvtXuMr2qjD_lUXw-g',
    appId: '1:372899048216:web:98176d2fb2ee6e7309cc6d',
    messagingSenderId: '372899048216',
    projectId: 'borla-8866b',
    authDomain: 'borla-8866b.firebaseapp.com',
    databaseURL: 'https://borla-8866b-default-rtdb.firebaseio.com',
    storageBucket: 'borla-8866b.appspot.com',
    measurementId: 'G-LVSZSWG87B',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDnIhWDi6C_CduK5cHsZ1ZUP-cz4y5QQFY',
    appId: '1:372899048216:android:631040aa10d9c1e209cc6d',
    messagingSenderId: '372899048216',
    projectId: 'borla-8866b',
    databaseURL: 'https://borla-8866b-default-rtdb.firebaseio.com',
    storageBucket: 'borla-8866b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAXTzdZvDGKnzJ_zdzayQOSHIgJEsdE9ic',
    appId: '1:372899048216:ios:cf8209a5a1942a5809cc6d',
    messagingSenderId: '372899048216',
    projectId: 'borla-8866b',
    databaseURL: 'https://borla-8866b-default-rtdb.firebaseio.com',
    storageBucket: 'borla-8866b.appspot.com',
    androidClientId: '372899048216-11jnd6p491fjkftgti3udq9l0iebqg9m.apps.googleusercontent.com',
    iosClientId: '372899048216-e2ccdo7q03146co98bgg639v5bil6hjs.apps.googleusercontent.com',
    iosBundleId: 'com.malcolm.borlawms',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAXTzdZvDGKnzJ_zdzayQOSHIgJEsdE9ic',
    appId: '1:372899048216:ios:97639b934c025a1a09cc6d',
    messagingSenderId: '372899048216',
    projectId: 'borla-8866b',
    databaseURL: 'https://borla-8866b-default-rtdb.firebaseio.com',
    storageBucket: 'borla-8866b.appspot.com',
    androidClientId: '372899048216-11jnd6p491fjkftgti3udq9l0iebqg9m.apps.googleusercontent.com',
    iosClientId: '372899048216-baphrc9ncu30ljsbtrdgqg0p1uop3ham.apps.googleusercontent.com',
    iosBundleId: 'com.malcolm.borlawms.RunnerTests',
  );
}
