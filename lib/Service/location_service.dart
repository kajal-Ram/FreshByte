import 'package:geolocator/geolocator.dart';

class LocationService {
  // Method to check location permission
  Future<bool> checkLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      // Request permission if denied
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        return false;
      } else if (permission == LocationPermission.deniedForever) {
        return false;
      } else {
        return true;
      }
    } else if (permission == LocationPermission.deniedForever) {
      return false;
    } else {
      return true;
    }
  }
}
