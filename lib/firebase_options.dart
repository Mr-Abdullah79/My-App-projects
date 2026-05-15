import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb;

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
    // For Android, we can rely on google-services.json
    throw UnsupportedError(
      'DefaultFirebaseOptions are only defined for Web here. Android uses google-services.json.',
    );
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBJoP51AFJsbIBajSCjsuns7azpDnzxVuA',
    appId: '1:370840078368:web:1234567890abcdef',
    messagingSenderId: '370840078368',
    projectId: 'solar-app-e7896',
    storageBucket: 'solar-app-e7896.firebasestorage.app',
  );
}
