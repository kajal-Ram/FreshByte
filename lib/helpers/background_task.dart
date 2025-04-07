import 'package:flutter/foundation.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_background_service_android/flutter_background_service_android.dart';
import 'notifications_helper.dart';

class BackgroundTask {
  // ✅ Start Background Task Every 5 Minutes
  static Future<void> startBackgroundTask() async {
    final service = FlutterBackgroundService();

    service.configure(
      androidConfiguration: AndroidConfiguration(
        onStart: onStart,
        autoStart: true,
        isForegroundMode: true,
      ),
      iosConfiguration: IosConfiguration(
        onForeground: onStart,
        onBackground: onIosBackground,
      ),
    );

    service.startService();
  }
}

// ✅ Runs Every 5 Minutes to Check for Expiry
void onStart(ServiceInstance service) {
  service.on('update').listen((event) async {
    await NotificationHelper.checkAndSendExpiryNotification();
  });

  service.invoke('update');
}

// ✅ Required for iOS
@pragma('vm:entry-point')
Future<bool> onIosBackground(ServiceInstance service) async {
  return true;
}
