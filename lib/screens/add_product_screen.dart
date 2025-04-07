import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:intl/intl.dart';

class AddProductScreen extends StatefulWidget {
  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications = FlutterLocalNotificationsPlugin();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  DateTime? _selectedDate;

  @override
  void initState() {
    super.initState();
    _initializeNotifications();
    _checkAndSendExpiryNotifications();
  }

  void _initializeNotifications() async {
    const AndroidInitializationSettings androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const InitializationSettings settings =
    InitializationSettings(android: androidSettings);
    await _localNotifications.initialize(settings);
    _firebaseMessaging.requestPermission();
  }

  Future<void> _checkAndSendExpiryNotifications() async {
    final now = DateTime.now();
    final snapshot = await _firestore.collection('expiry_items').get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      DateTime expiryDate = DateFormat('yyyy-MM-dd').parse(data['expiryDate']);
      int daysLeft = expiryDate.difference(now).inDays;

      if (daysLeft <= 2 && data['notificationSent'] == false) {
        _sendLocalNotification(data['name'], daysLeft);
        _firestore.collection('expiry_items').doc(doc.id).update({'notificationSent': true});
      }
    }
  }

  void _sendLocalNotification(String itemName, int daysLeft) async {
    const AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
      'expiry_channel', 'Expiry Notifications',
      importance: Importance.high, priority: Priority.high,
    );
    const NotificationDetails platformDetails = NotificationDetails(android: androidDetails);
    await _localNotifications.show(
        0, 'Expiry Alert!', '$itemName is expiring in $daysLeft days!', platformDetails);
  }

  void _addExpiryItem(String name, String quantity, DateTime expiryDate) {
    _firestore.collection('expiry_items').add({
      'name': name,
      'quantity': quantity.isNotEmpty ? quantity : 'Not specified',
      'expiryDate': DateFormat('yyyy-MM-dd').format(expiryDate),
      'notificationSent': false,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Product", style: TextStyle(color: Colors.white)),
        backgroundColor: Color(0xFFBBB696),
      ),
      body: Container(
        padding: EdgeInsets.all(12),
        color: Color(0xFFF8F5E4),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              elevation: 3,
              child: Padding(
                padding: EdgeInsets.all(12),
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      decoration: InputDecoration(
                        labelText: "Item Name",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.fastfood, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 10),
                    TextField(
                      controller: _quantityController,
                      decoration: InputDecoration(
                        labelText: "Quantity (e.g., 2 liters)",
                        filled: true,
                        fillColor: Colors.white,
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.scale, color: Colors.grey),
                      ),
                    ),
                    SizedBox(height: 10),
                    ElevatedButton.icon(
                      icon: Icon(Icons.calendar_today),
                      label: Text(_selectedDate == null ? "Select Expiry Date" : "Selected: ${DateFormat('yyyy-MM-dd').format(_selectedDate!)}"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFFBBB696),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: () async {
                        DateTime? pickedDate = await showDatePicker(
                          context: context,
                          initialDate: DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2101),
                        );
                        if (pickedDate != null) {
                          setState(() => _selectedDate = pickedDate);
                        }
                      },
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (_nameController.text.isNotEmpty && _selectedDate != null) {
                          _addExpiryItem(_nameController.text, _quantityController.text, _selectedDate!);
                          _nameController.clear();
                          _quantityController.clear();
                          setState(() => _selectedDate = null);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                        elevation: 4,
                      ),
                      child: Text("Add Item"),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
