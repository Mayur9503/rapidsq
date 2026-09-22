import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FirebaseMessagingService {
  FirebaseMessaging? get _messaging {
    try {
      if (Firebase.apps.isNotEmpty) {
        return FirebaseMessaging.instance;
      }
    } catch (_) {}
    return null;
  }

  /// Request notification permissions (vital for Android 13+ and iOS)
  Future<NotificationSettings?> requestPermission() async {
    final fcm = _messaging;
    if (fcm == null) return null;
    try {
      final settings = await fcm.requestPermission(
        alert: true,
        announcement: false,
        badge: true,
        carPlay: false,
        criticalAlert: true,
        provisional: false,
        sound: true,
      );
      return settings;
    } catch (e) {
      debugPrint('Notice requesting notification permission: $e');
      return null;
    }
  }

  /// Retrieve the real device FCM token
  Future<String?> getDeviceToken() async {
    final fcm = _messaging;
    if (fcm == null) return null;
    try {
      await requestPermission();
      final token = await fcm.getToken();
      return token;
    } catch (e) {
      debugPrint('Notice getting device FCM token: $e');
      return null;
    }
  }

  /// Stream of token refreshes
  Stream<String>? get onTokenRefresh => _messaging?.onTokenRefresh;

  /// Stream of foreground messages
  Stream<RemoteMessage>? get onMessage => FirebaseMessaging.onMessage;
}
