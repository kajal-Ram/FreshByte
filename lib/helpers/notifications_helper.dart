import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;

class NotificationHelper {
  static final FlutterLocalNotificationsPlugin _notificationsPlugin =
  FlutterLocalNotificationsPlugin();

  // ✅ Initialize Local Notifications
  static Future<void> initializeNotifications() async {
    tz.initializeTimeZones();

    const AndroidInitializationSettings androidInit =
    AndroidInitializationSettings('@mipmap/ic_launcher');

    const InitializationSettings initSettings =
    InitializationSettings(android: androidInit);

    await _notificationsPlugin.initialize(initSettings);
  }

  // ✅ Optimized Firestore Query for Expiry Check
  static Future<void> checkAndSendExpiryNotification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    final now = DateTime.now();
    final expiryThreshold = now.add(const Duration(days: 2));

    QuerySnapshot products = await FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('products')
        .where('expiryDate', isLessThanOrEqualTo: expiryThreshold)
        .get();

    for (var product in products.docs) {
      DateTime expiryDate = (product['expiryDate'] as Timestamp).toDate();
      String productName = product['name'];

      if (expiryDate.difference(DateTime.now()).inDays <= 2) {
        await showNotification(productName);
      }
    }
  }

  // ✅ Show Local Notification
  static Future<void> showNotification(String productName) async {
    const AndroidNotificationDetails androidDetails =
    AndroidNotificationDetails(
      'expiry_channel_id', 'Expiry Notifications',
      channelDescription: 'Alerts for expiring products',
      importance: Importance.high,
      priority: Priority.high,
    );

    const NotificationDetails platformDetails =
    NotificationDetails(android: androidDetails);

    await _notificationsPlugin.show(
      0, // Notification ID
      'Expiry Reminder',
      '$productName expires in 2 days!',
      platformDetails,
    );
  }
}
