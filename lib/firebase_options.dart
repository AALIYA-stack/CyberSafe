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
    apiKey: 'AIzaSyDcV-NIS-XhI80knzy02kyB5hP7mkP8HAc',
    appId: '1:757210727625:web:3e8ea00a6b09c4feb53918',
    messagingSenderId: '757210727625',
    projectId: 'cybersafeapp-project',
    authDomain: 'cybersafeapp-project.firebaseapp.com',
    storageBucket: 'cybersafeapp-project.firebasestorage.app',
    measurementId: 'G-Z8XDX9NB5D',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyC6buAV59GPfwDdg2SQia7sCoP6V7C3QhA',
    appId: '1:757210727625:android:cd2d63f4a6947dd8b53918',
    messagingSenderId: '757210727625',
    projectId: 'cybersafeapp-project',
    storageBucket: 'cybersafeapp-project.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBuux0dwSu7WWI16tBrZA_WHXOy2G37l7Q',
    appId: '1:247267297773:ios:1462c4eac8db99ae547fe4',
    messagingSenderId: '247267297773',
    projectId: 'cybersafeapp-cda9c',
    storageBucket: 'cybersafeapp-cda9c.firebasestorage.app',
    iosBundleId: 'com.example.projectCybersafeApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBuux0dwSu7WWI16tBrZA_WHXOy2G37l7Q',
    appId: '1:247267297773:ios:1462c4eac8db99ae547fe4',
    messagingSenderId: '247267297773',
    projectId: 'cybersafeapp-cda9c',
    storageBucket: 'cybersafeapp-cda9c.firebasestorage.app',
    iosBundleId: 'com.example.projectCybersafeApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyC-0pAd7mBfqPAMnYkLDMIAPgQv9Lpvehk',
    appId: '1:247267297773:web:fbccf170b5073331547fe4',
    messagingSenderId: '247267297773',
    projectId: 'cybersafeapp-cda9c',
    authDomain: 'cybersafeapp-cda9c.firebaseapp.com',
    storageBucket: 'cybersafeapp-cda9c.firebasestorage.app',
    measurementId: 'G-TW6TEWH45T',
  );
}
