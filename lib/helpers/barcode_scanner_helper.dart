import 'dart:convert';
import 'dart:io'; // For handling network errors
import 'package:http/http.dart' as http;

Future<String> fetchProductName(String barcode) async {
  final String url = "https://world.openfoodfacts.org/api/v0/product/$barcode.json";

  try {
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      var data = json.decode(response.body);

      // Check if product exists and contains a valid name
      if (data["product"] is Map && data["product"]["product_name"] is String) {
        return data["product"]["product_name"];
      } else {
        return "Product not found";
      }
    } else {
      return "Error: ${response.statusCode}";
    }
  } on SocketException {
    return "No Internet Connection";
  } catch (e) {
    return "Error fetching product: $e";
  }
}
