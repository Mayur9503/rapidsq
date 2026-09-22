import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class FastApiBackendService {
  String baseUrl;

  FastApiBackendService({String? customBaseUrl})
      : baseUrl = customBaseUrl ??
            const String.fromEnvironment(
              'BACKEND_URL',
              defaultValue: kIsWeb ? 'http://localhost:8000' : 'http://10.0.2.2:8000',
            );

  void setBaseUrl(String url) {
    baseUrl = url;
  }

  Map<String, String> _headers(String? idToken) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer ${idToken ?? "dev-test-token"}',
    };
  }

  /// Check FastAPI health
  Future<bool> checkHealth() async {
    try {
      final res = await http.get(Uri.parse('$baseUrl/health')).timeout(const Duration(seconds: 4));
      return res.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  /// POST /api/incidents
  Future<Map<String, dynamic>> createIncident({
    required double latitude,
    required double longitude,
    String? description,
    String category = 'selfSOS',
    String serviceType = 'ambulance',
    String priority = 'CRITICAL',
    String? locationTitle,
    String? idToken,
  }) async {
    final body = jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
      'description': description ?? 'Emergency SOS Alert',
      'category': category,
      'serviceType': serviceType,
      'priority': priority,
      'locationTitle': locationTitle ?? 'Current GPS Location',
    });

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/incidents'),
        headers: _headers(idToken),
        body: body,
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 201) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        throw 'Backend returned status ${res.statusCode}: ${res.body}';
      }
    } catch (e) {
      throw 'FastAPI dispatch failed: $e';
    }
  }

  /// POST /api/incidents/{incident_id}/respond
  Future<Map<String, dynamic>> respondToIncident({
    required String incidentId,
    required String action, // "ACCEPT" or "REJECT"
    String? idToken,
  }) async {
    final body = jsonEncode({'response': action});

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/incidents/$incidentId/respond'),
        headers: _headers(idToken ?? 'driver-token'),
        body: body,
      ).timeout(const Duration(seconds: 8));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        throw 'Backend response failed (${res.statusCode}): ${res.body}';
      }
    } catch (e) {
      throw 'FastAPI response failed: $e';
    }
  }

  /// POST /api/ambulances/main/location
  Future<Map<String, dynamic>> updateAmbulanceLocation({
    required double latitude,
    required double longitude,
    String? idToken,
  }) async {
    final body = jsonEncode({
      'latitude': latitude,
      'longitude': longitude,
    });

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/api/ambulances/main/location'),
        headers: _headers(idToken ?? 'driver-token'),
        body: body,
      ).timeout(const Duration(seconds: 6));

      if (res.statusCode == 200) {
        return jsonDecode(res.body) as Map<String, dynamic>;
      } else {
        throw 'Failed to update ambulance GPS (${res.statusCode})';
      }
    } catch (e) {
      throw 'FastAPI location update failed: $e';
    }
  }

  /// POST /api/devices/fcm-token
  Future<void> registerFcmToken({
    required String fcmToken,
    String? idToken,
  }) async {
    final body = jsonEncode({
      'fcmToken': fcmToken,
      'deviceType': 'ambulance',
    });

    try {
      await http.post(
        Uri.parse('$baseUrl/api/devices/fcm-token'),
        headers: _headers(idToken ?? 'driver-token'),
        body: body,
      ).timeout(const Duration(seconds: 6));
    } catch (e) {
      debugPrint('FastAPI FCM registration note: $e');
    }
  }
}
