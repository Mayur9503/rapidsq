import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../models/emergency_request.dart';

class DeviceLocationService {
  /// Fetches real device GPS coordinates with timeout and permission requests
  static Future<EmergencyLocation?> getCurrentCoordinates() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Device location services are disabled.');
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          debugPrint('Device location permission denied.');
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        debugPrint('Device location permissions permanently denied.');
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );

      return EmergencyLocation(
        latitude: position.latitude,
        longitude: position.longitude,
        title: 'Current GPS Coordinates',
        subtitle: 'Lat: ${position.latitude.toStringAsFixed(5)}, Lng: ${position.longitude.toStringAsFixed(5)}',
      );
    } catch (e) {
      debugPrint('Notice acquiring real GPS fix: $e');
      return null;
    }
  }
}
