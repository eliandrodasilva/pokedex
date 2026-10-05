// Arquivo de configuração do Firebase.
// Substitua ou execute `flutterfire configure` para vincular automaticamente com o seu projeto no Firebase Console.
// ignore_for_file: type=lint
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
        return ios;
      case TargetPlatform.windows:
        return windows;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCrfQaU6FzWIWUhC-sdhuMHtIQOI76TFAU',
    appId: '1:816967633374:web:3aee1e6b8fff3487e0754f',
    messagingSenderId: '816967633374',
    projectId: 'pokedex-app-515df',
    authDomain: 'pokedex-app-515df.firebaseapp.com',
    storageBucket: 'pokedex-app-515df.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCuQZGzhTzvc9qktz-mu6YQU9McMbgpoJM',
    appId: '1:816967633374:android:e702fe1478c04fabe0754f',
    messagingSenderId: '816967633374',
    projectId: 'pokedex-app-515df',
    storageBucket: 'pokedex-app-515df.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'YOUR_API_KEY',
    appId: '1:000000000000:ios:0000000000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'pokedex-demo',
    storageBucket: 'pokedex-demo.firebasestorage.app',
    iosBundleId: 'com.example.pokedex',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCrfQaU6FzWIWUhC-sdhuMHtIQOI76TFAU',
    appId: '1:816967633374:web:016651c5d8db9f15e0754f',
    messagingSenderId: '816967633374',
    projectId: 'pokedex-app-515df',
    authDomain: 'pokedex-app-515df.firebaseapp.com',
    storageBucket: 'pokedex-app-515df.firebasestorage.app',
  );
}
