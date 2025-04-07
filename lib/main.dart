import 'dart:ui' show DartPluginRegistrant;

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'package:flutter/services.dart';
import 'firebase_options.dart';
import 'helpers/notifications_helper.dart';
import 'View/login_screen.dart';
import 'View/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationHelper.initializeNotifications();
  await startBackgroundService();

  runApp(const MyApp());
}

// ✅ Start Background Service
Future<void> startBackgroundService() async {
  final service = FlutterBackgroundService();

  service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      autoStart: true,
      isForegroundMode: true,
      notificationChannelId: "background_service",
      foregroundServiceNotificationId: 999, // ✅ Keeps it persistent
      initialNotificationTitle: "Expiry Checker",
      initialNotificationContent: "Running in background...",
    ),
    iosConfiguration: IosConfiguration(
      onForeground: onStart,
      onBackground: onIosBackground,
    ),
  );

  service.startService();
}

// ✅ iOS Background Execution Handler
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  DartPluginRegistrant.ensureInitialized(); // ✅ Required for Flutter Plugins
  return true;
}

// ✅ Runs Every 5 Minutes to Check for Expiry
@pragma('vm:entry-point')
void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized(); // ✅ Required for Flutter Plugins

  if (service is AndroidServiceInstance) {
    service.setAsForegroundService(); // ✅ Prevents Android from stopping it
  }

  service.on('update').listen((event) async {
    await NotificationHelper.checkAndSendExpiryNotification();
  });

  service.invoke('update');

  // ✅ Keep running every 5 minutes
  service.on('stopService').listen((event) {
    service.stopSelf();
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AuthCheck(),
    );
  }
}

class AuthCheck extends StatelessWidget {
  const AuthCheck({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.active) {
          if (snapshot.hasData) {
            return const HomeScreen();
          }
          return const LoginScreen();
        }
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      },
    );
  }
}
