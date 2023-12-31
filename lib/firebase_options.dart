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
    apiKey: 'AIzaSyCsmgvhqT1RphK45cJ7ATSNR_SttkP-8oc',
    appId: '1:774879907799:web:47e772dc6b053ae6294592',
    messagingSenderId: '774879907799',
    projectId: 'chat-app-6fa3d',
    authDomain: 'chat-app-6fa3d.firebaseapp.com',
    storageBucket: 'chat-app-6fa3d.appspot.com',
    measurementId: 'G-5DVM2K8K0L',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCAZBp5pQ2opbDaqcGQBiadMoqyIu8tlSI',
    appId: '1:774879907799:android:1632118f2b5c622e294592',
    messagingSenderId: '774879907799',
    projectId: 'chat-app-6fa3d',
    storageBucket: 'chat-app-6fa3d.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAP8EENXbGWpwN96350IVH07UK-owSzOvw',
    appId: '1:774879907799:ios:b4b93c6f5d449f50294592',
    messagingSenderId: '774879907799',
    projectId: 'chat-app-6fa3d',
    storageBucket: 'chat-app-6fa3d.appspot.com',
    iosBundleId: 'com.example.flutterChatApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAP8EENXbGWpwN96350IVH07UK-owSzOvw',
    appId: '1:774879907799:ios:8164b8f2e8df53b4294592',
    messagingSenderId: '774879907799',
    projectId: 'chat-app-6fa3d',
    storageBucket: 'chat-app-6fa3d.appspot.com',
    iosBundleId: 'com.example.flutterChatApp.RunnerTests',
  );
}
