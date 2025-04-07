import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // 🔹 Add product with expiry date to Firestore
  Future<String?> addProduct(String name, DateTime expiryDate) async {
    try {
      String? userId = _auth.currentUser?.uid;
      if (userId == null) throw Exception("User not logged in");

      await _firestore.collection("products").add({
        "name": name,
        "expiryDate": Timestamp.fromDate(expiryDate),  // ✅ Store as Firestore Timestamp
        "notificationSent": false,  // Prevent duplicate alerts
        "userId": userId,  // ✅ Store user ID for personalized notifications
        "createdAt": FieldValue.serverTimestamp(), // 🔹 Store creation time
      });

      return "Product added successfully!";
    } catch (e) {
      print("❌ Error adding product: $e");
      return null;
    }
  }
}
