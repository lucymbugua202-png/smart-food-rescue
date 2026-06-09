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
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyD6i8VIpGAHo0q2To0XyMkP2_vxHJJ0Jtk',
    appId: '1:51644822800:web:cfa1e4fd149a2974142195',
    messagingSenderId: '51644822800',
    projectId: 'smart-food-rescue-fa0a9',
    authDomain: 'smart-food-rescue-fa0a9.firebaseapp.com',
    storageBucket: 'smart-food-rescue-fa0a9.firebasestorage.app',
    measurementId: 'YOUR_MEASUREMENT_ID', // You can get this from Firebase console
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD6i8VIpGAHo0q2To0XyMkP2_vxHJJ0Jtk',
    appId: '1:51644822800:android:YOUR_ANDROID_APP_ID', // You'll need to add an Android app in Firebase
    messagingSenderId: '51644822800',
    projectId: 'smart-food-rescue-fa0a9',
    storageBucket: 'smart-food-rescue-fa0a9.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyD6i8VIpGAHo0q2To0XyMkP2_vxHJJ0Jtk',
    appId: '1:51644822800:ios:YOUR_IOS_APP_ID', // You'll need to add an iOS app in Firebase
    messagingSenderId: '51644822800',
    projectId: 'smart-food-rescue-fa0a9',
    storageBucket: 'smart-food-rescue-fa0a9.firebasestorage.app',
    iosClientId: 'YOUR_IOS_CLIENT_ID',
    iosBundleId: 'com.example.smartFoodRescue',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyD6i8VIpGAHo0q2To0XyMkP2_vxHJJ0Jtk',
    appId: '1:51644822800:ios:YOUR_MACOS_APP_ID',
    messagingSenderId: '51644822800',
    projectId: 'smart-food-rescue-fa0a9',
    storageBucket: 'smart-food-rescue-fa0a9.firebasestorage.app',
    iosClientId: 'YOUR_MACOS_CLIENT_ID',
    iosBundleId: 'com.example.smartFoodRescue',
  );
}
