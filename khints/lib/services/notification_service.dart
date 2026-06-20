import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

final notificationServiceProvider = Provider<NotificationService>((ref) {
  return NotificationService();
});

class NotificationService {
  FirebaseMessaging? _messaging;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) return;
    try {
      _messaging = FirebaseMessaging.instance;
      NotificationSettings settings = await _messaging!.requestPermission(
        alert: true, badge: true, sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.authorized ||
          settings.authorizationStatus == AuthorizationStatus.provisional) {
        final fcmToken = await _messaging!.getToken();
        if (fcmToken != null) await _saveToken(fcmToken);
        _messaging!.onTokenRefresh.listen(_saveToken);
        FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
      }
    } catch (e) {
      debugPrint('FCM init skipped: $e');
    }
    _initialized = true;
  }

  Future<void> _saveToken(String token) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'fcmToken': token, 'notificationsEnabled': true}, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> toggleNotifications(bool enable) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final data = <String, dynamic>{'notificationsEnabled': enable};
      if (enable) {
        if (_messaging == null) return;
        final token = await _messaging!.getToken();
        if (token != null) data['fcmToken'] = token;
      }
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set(data, SetOptions(merge: true));
    } catch (_) {}
  }

  void _handleForegroundMessage(RemoteMessage message) {
    debugPrint('FCM foreground: ${message.notification?.title}');
  }

  Future<void> sendToAll(String title, String body) async {
    try {
      final response = await http.post(
        Uri.parse('https://khints.onrender.com/notify'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'title': title, 'body': body}),
      );
      if (response.statusCode == 200) {
        debugPrint('Notification envoyée via Render');
      } else {
        debugPrint('Erreur Render: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('sendToAll error: $e');
      // Fallback: essayer de lire la clé depuis Firestore
      try {
        final doc = await FirebaseFirestore.instance.collection('config').doc('fcm').get();
        if (!doc.exists) return;
        final data = doc.data()!;
        final serverKey = data['serverKey'] as String?;
        if (serverKey == null || serverKey.isEmpty) return;

        final users = await FirebaseFirestore.instance
            .collection('users')
            .where('notificationsEnabled', isEqualTo: true)
            .get();
        for (final user in users.docs) {
          final token = user.data()['fcmToken'] as String?;
          if (token == null || token.isEmpty) continue;
          await _sendToDevice(token, title, body, serverKey);
        }
      } catch (e2) {
        debugPrint('Fallback error: $e2');
      }
    }
  }

  Future<bool> _sendToDevice(String token, String title, String body, String serverKey) async {
    try {
      final response = await http.post(
        Uri.parse('https://fcm.googleapis.com/fcm/send'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'key=$serverKey',
        },
        body: jsonEncode({
          'to': token,
          'notification': {'title': title, 'body': body},
          'priority': 'high',
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('sendToDevice error: $e');
      return false;
    }
  }
}
