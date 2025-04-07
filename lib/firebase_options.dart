import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    } else if (Platform.isIOS || Platform.isMacOS) {
      return ios;
    } else if (Platform.isAndroid) {
      return android;
    } else {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for this platform.',
      );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: "AIzaSyBRLXHmwv00-NI0u2nWznHKFuMR5Q_blt4",
    //authDomain: "flutter-project.firebaseapp.com",
    projectId: "freshbyte-462d2",
    messagingSenderId: "711075642652",
    appId: "1:711075642652:android:53705af363d1b98caa0ed9",
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: "AIzaSyBRLXHmwv00-NI0u2nWznHKFuMR5Q_blt4",
    //authDomain: "flutter-project.firebaseapp.com",
    projectId: "freshbyte-462d2",
    messagingSenderId: "711075642652",
    appId: "1:711075642652:android:53705af363d1b98caa0ed9",
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: "AIzaSyBRLXHmwv00-NI0u2nWznHKFuMR5Q_blt4",
    //authDomain: "flutter-project.firebaseapp.com",
    projectId: "freshbyte-462d2",
    messagingSenderId: "711075642652",
    appId: "1:711075642652:android:53705af363d1b98caa0ed9",
    // storageBucket: "your-android-storage-bucket",
  );
}
